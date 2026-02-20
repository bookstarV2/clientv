import 'dart:convert';
import 'dart:io';
import 'package:bookstar/modules/auth/view_model/auth_state.dart';
import 'package:bookstar/modules/auth/view_model/auth_view_model.dart';
import 'package:bookstar/modules/notification/model/fcm_token_create_request.dart';
import 'package:bookstar/modules/notification/repository/notification_repository.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bookstar/common/router/router.dart'; // rootNavigatorKey import
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_service.g.dart';

// 백그라운드 메시지 핸들러 (최상위 레벨 함수여야 함)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // 백그라운드에서 메시지 수신 시 처리 로직
  // Firebase.initializeApp()이 필요한 경우 여기서 호출해야 할 수도 있음
  debugPrint("Handling a background message: ${message.messageId}");
  debugPrint("Background message data: ${message.data}");
  // backgroundHandler에서는 UI 업데이트나 복잡한 라우팅은 지양
  // 필요한 경우 local notification을 띄우거나 데이터 저장
}

@Riverpod(keepAlive: true)
NotificationService notificationService(Ref ref) {
  return NotificationService(ref);
}

class NotificationService {
  final Ref _ref;

  NotificationService(this._ref);

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // 초기화 함수
  Future<void> initialize() async {
    // 1. 권한 요청 (iOS)
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      debugPrint('User granted provisional permission');
    } else {
      debugPrint('User declined or has not accepted permission');
      return;
    }

    // 2. 백그라운드 핸들러 등록
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 3. 로컬 알림 플러그인 초기화
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );

    // 4. 포그라운드 메시지 수신 리스너 등록
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        debugPrint('Message also contained a notification: ${message.notification}');
        
        // 포그라운드에서도 시스템 알림 표시
        _showNotification(message);
      }
    });
    
    // 5. 알림 탭하여 앱이 열렸을 때 처리 (백그라운드/종료 상태에서)
    _setupInteractedMessage();
    
    // 6. FCM 토큰 가져오기 및 서버 등록 (로그인 시점에)
    // 앱 시작 시 토큰은 가져오되, 등록은 로그인 성공 시점에
    _ref.listen(authViewModelProvider, (previousState, nextState) async {
      final String? currentToken = await _firebaseMessaging.getToken();
      if (currentToken == null) {
        debugPrint("FCM Token is null, cannot register.");
        return;
      }
      
      if (previousState?.value is! AuthSuccess && nextState.value is AuthSuccess) {
        // 로그인 성공 시점에 토큰 등록 시도
        debugPrint("AuthSuccess detected. Attempting to register FCM token.");
        await _registerToken(currentToken);
      }
      // 토큰 갱신 리스너는 여기서 처리해도 무방 (로그인 상태를 항상 체크)
      _firebaseMessaging.onTokenRefresh.listen((newToken) async {
          debugPrint("FCM Token Refreshed: $newToken");
          await _registerToken(newToken); // 갱신된 토큰 등록
      });
    });
  }

  // FCM 토큰 서버 등록
  Future<void> _registerToken(String token) async {
    final authState = _ref.read(authViewModelProvider);
    
    // 로그인 상태가 아니거나 로딩 중이면 토큰 등록을 보류하거나 스킵
    // (나중에 로그인 성공 시 다시 호출하도록 로직 보완 필요할 수 있음)
    if (authState.value is! AuthSuccess) {
      debugPrint("User not logged in. Skipping FCM token registration.");
      return;
    }
    
    final userId = (authState.value as AuthSuccess).memberId;
    final deviceType = Platform.isAndroid ? 'ANDROID' : 'IOS';
    
    final request = FCMTokenCreateRequest(
      userId: userId,
      fcmToken: token,
      deviceType: deviceType,
    );

    debugPrint("FCM Token Registration Request Data:");
    debugPrint("  userId: ${request.userId}");
    debugPrint("  fcmToken: ${request.fcmToken}");
    debugPrint("  deviceType: ${request.deviceType}");


    try {
      await _ref.read(notificationRepositoryProvider).save(request);
      debugPrint("FCM Token registered successfully for user: $userId");
    } catch (e) {
      debugPrint("Failed to register FCM token: $e");
    }
  }

  // 포그라운드 알림 표시 함수
  Future<void> _showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await _flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      notificationDetails,
      payload: jsonEncode(message.data), // 데이터 페이로드를 전달
    );
  }

  // 알림 탭 핸들러 (앱이 이미 실행 중일 때)
  void _onDidReceiveNotificationResponse(NotificationResponse notificationResponse) {
    final String? payload = notificationResponse.payload;
    if (payload != null) {
      debugPrint('notification payload: $payload');
      _handleMessageData(jsonDecode(payload));
    }
  }

  // 알림 탭 처리 (앱이 종료되었거나 백그라운드 상태였을 때)
  Future<void> _setupInteractedMessage() async {
    // 1. 앱이 완전히 종료된 상태에서 알림을 눌러 실행된 경우
    RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();

    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // 2. 앱이 백그라운드 상태에서 알림을 눌러 포그라운드로 전환된 경우
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    debugPrint('Message clicked!');
    _handleMessageData(message.data);
  }

  // 데이터 페이로드 처리 및 화면 이동 로직 (라우터 연동 필요)
  void _handleMessageData(Map<String, dynamic> data) {
    debugPrint("Notification Data received: $data");

    // TODO: 여기서 데이터 파싱 및 라우팅 로직 구현
    // routerProvider 접근을 위해 BuildContext가 필요하며,
    // NotificationService가 직접 Riverpod Consumer가 아니므로
    // rootNavigatorKey를 통해 context를 얻어 GoRouter를 사용해야 합니다.
    final context = rootNavigatorKey.currentContext;
    if (context == null) {
      debugPrint("Router context not available for navigation.");
      return;
    }

    final String? notificationType = data['notificationType'];
    final String? metadataString = data['metadata'];
    
    debugPrint("Parsed Notification Type: $notificationType");
    debugPrint("Parsed Metadata String: $metadataString");
    
    if (metadataString != null) {
       try {
         final Map<String, dynamic> metadata = jsonDecode(metadataString);
         debugPrint("Parsed Metadata: $metadata");

         // GoRouter.of(context).go(...) 또는 push(...)를 사용하여 화면 이동
         // 예시:
         /*
         switch (notificationType) {
           case 'LIKE':
           case 'COMMENT':
           case 'REPLY':
             final diaryId = metadata['diaryId'];
             if (diaryId != null) {
               // 현재 일기 상세 라우트가 없으므로, 필요 시 GoRouter에 추가해야 함
               // GoRouter.of(context).push('/book-log/detail/$diaryId');
               debugPrint("Navigating to Diary Detail for diaryId: $diaryId (Currently commented out)");
             }
             break;
           case 'FOLLOW':
             final memberId = metadata['memberId'];
             if (memberId != null) {
               GoRouter.of(context).push('/profile/$memberId'); // 예시 라우트
               debugPrint("Navigating to Member Profile for memberId: $memberId (Currently commented out)");
             }
             break;
           case 'QUIZ_COMPLETED':
             final bookId = metadata['bookId'];
             final challengeId = metadata['challengeId'];
             if (bookId != null && challengeId != null) {
               GoRouter.of(context).push('/reading-challenge/detail/$bookId?challengeId=$challengeId');
               debugPrint("Navigating to Reading Challenge Detail for bookId: $bookId, challengeId: $challengeId (Currently commented out)");
             }
             break;
           default:
             debugPrint("Unknown notification type or no navigation defined for: $notificationType");
             break;
         }
         */
       } catch (e) {
         debugPrint("Error parsing metadata JSON: $e");
       }
    } else {
      debugPrint("No metadata found in notification payload.");
    }
  }
}

