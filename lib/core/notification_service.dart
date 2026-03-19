import 'dart:convert';
import 'dart:developer' as dev; // 추가
import 'dart:io';
import 'package:bookstar/modules/auth/view_model/auth_state.dart';
import 'package:bookstar/modules/auth/view_model/auth_view_model.dart';
import 'package:bookstar/modules/notification/model/fcm_token_create_request.dart';
import 'package:bookstar/modules/notification/repository/notification_repository.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bookstar/common/router/router.dart'; // rootNavigatorKey import
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_service.g.dart';

// 백그라운드 메시지 핸들러 (최상위 레벨 함수여야 함)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // 백그라운드에서 메시지 수신 시 처리 로직
  if (kDebugMode) {
    dev.log("Handling a background message: ${message.messageId}", name: 'NOTIFICATION');
    dev.log("Background message data: ${message.data}", name: 'NOTIFICATION');
  }
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
    // 1. 권한 요청 (iOS/Android 13+)
    _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    ).then((settings) {
      if (kDebugMode) {
        if (settings.authorizationStatus == AuthorizationStatus.authorized) {
          dev.log('User granted permission', name: 'NOTIFICATION');
        } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
          dev.log('User granted provisional permission', name: 'NOTIFICATION');
        } else {
          dev.log('User declined or has not accepted permission', name: 'NOTIFICATION');
        }
      }
    });

    // 2. 백그라운드 핸들러 등록 (main.dart에서 등록하는 것이 권장되지만, 여기서도 중복 등록 방지하며 처리)
    // FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

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

    // 안드로이드 알림 채널 생성 (중요!)
    final androidPlugin = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(const AndroidNotificationChannel(
        'high_importance_channel', // ID
        'High Importance Notifications', // 이름
        description: 'This channel is used for important notifications.',
        importance: Importance.max,
      ));
      if (kDebugMode) dev.log("Android Notification Channel created", name: 'NOTIFICATION');
    }

    _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );

    // 4. 포그라운드 메시지 수신 리스너 등록
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        dev.log('🔔 Got a message whilst in the foreground!', name: 'NOTIFICATION');
        dev.log('Message ID: ${message.messageId}', name: 'NOTIFICATION');
        dev.log('Data Payload:', name: 'NOTIFICATION');
        message.data.forEach((key, value) {
          dev.log('  $key: $value', name: 'NOTIFICATION');
        });
        
        if (message.notification != null) {
          dev.log('Notification Title: ${message.notification?.title}', name: 'NOTIFICATION');
          dev.log('Notification Body: ${message.notification?.body}', name: 'NOTIFICATION');
        }
      }
      
      // 알림 표시 시도 (데이터 메시지 및 알림 메시지 통합 처리)
      _showNotification(message);
    });
    
    // 5. 알림 탭하여 앱이 열렸을 때 처리 (백그라운드/종료 상태에서)
    _setupInteractedMessage();
    
    // 6. FCM 토큰 갱신 리스너 (한 번만 등록)
    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
        if (kDebugMode) dev.log("FCM Token Refreshed: $newToken", name: 'NOTIFICATION');
        await _registerToken(newToken);
    });

    // 7. 로그인 상태 변화 감시 및 토큰 등록 시도
    _ref.listen(authViewModelProvider, (previousState, nextState) async {
      // 로그인 성공 상태로 전환되거나, 이미 성공 상태인데 이전 정보가 없었을 때 실행
      final isNowSuccess = nextState.value is AuthSuccess;
      final wasNotSuccess = previousState?.value is! AuthSuccess;

      if (isNowSuccess && wasNotSuccess) {
        final String? currentToken = await _firebaseMessaging.getToken();
        if (currentToken != null) {
          if (kDebugMode) dev.log("AuthSuccess detected. Registering FCM token.", name: 'NOTIFICATION');
          // 비동기로 실행하여 초기화 흐름을 방해하지 않음
          _registerToken(currentToken);
        }
      }
    });

    // 8. 앱 시작 시 이미 로그인 상태인 경우 즉시 토큰 등록 확인
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final currentState = _ref.read(authViewModelProvider);
      if (currentState.value is AuthSuccess) {
        final String? currentToken = await _firebaseMessaging.getToken();
        if (currentToken != null) {
          if (kDebugMode) dev.log("User already logged in at startup. Registering FCM token.", name: 'NOTIFICATION');
          _registerToken(currentToken);
        }
      }
    });
  }

  // FCM 토큰 서버 등록 (재시도 로직 포함)
  Future<void> _registerToken(String token, {int retryCount = 0}) async {
    const int maxRetries = 3;
    final authState = _ref.read(authViewModelProvider);
    
    // 1. 로그인 상태 확인 (AuthSuccess가 아니면 등록 중단)
    if (authState.value is! AuthSuccess) {
      if (kDebugMode) dev.log("User not logged in. Skipping FCM token registration.", name: 'NOTIFICATION');
      return;
    }
    
    final userId = (authState.value as AuthSuccess).memberId;
    final deviceType = Platform.isAndroid ? 'ANDROID' : 'IOS';
    
    final request = FCMTokenCreateRequest(
      userId: userId,
      fcmToken: token,
      deviceType: deviceType,
    );

    try {
      await _ref.read(notificationRepositoryProvider).save(request);
      if (kDebugMode) dev.log("FCM Token registered successfully for user: $userId", name: 'NOTIFICATION');
    } catch (e) {
      if (kDebugMode) dev.log("Failed to register FCM token (Attempt ${retryCount + 1}/$maxRetries): $e", name: 'NOTIFICATION');
      
      // 2. 재시도 로직 (지수 백오프 적용: 2s, 4s, 8s...)
      if (retryCount < maxRetries) {
        final nextRetryDelay = Duration(seconds: (2 * (retryCount + 1)));
        if (kDebugMode) dev.log("Retrying FCM token registration in ${nextRetryDelay.inSeconds}s...", name: 'NOTIFICATION');
        
        Future.delayed(nextRetryDelay, () {
          // 재시도 시점에 다시 로그인 상태인지 확인하기 위해 재호출
          _registerToken(token, retryCount: retryCount + 1);
        });
      } else {
        if (kDebugMode) dev.log("Max retries reached. FCM token registration failed.", name: 'NOTIFICATION');
      }
    }
  }

  // 포그라운드 알림 표시 함수
  Future<void> _showNotification(RemoteMessage message) async {
    // 1. 제목과 내용 추출 (notification 객체 우선, 없으면 data 객체 확인)
    String? title = message.notification?.title ?? message.data['title'] ?? message.data['messageTitle'];
    String? body = message.notification?.body ?? message.data['body'] ?? message.data['messageBody'] ?? message.data['content'];

    if (kDebugMode) {
      dev.log('Attempting to show notification:', name: 'NOTIFICATION');
      dev.log('  Derived Title: $title', name: 'NOTIFICATION');
      dev.log('  Derived Body: $body', name: 'NOTIFICATION');
    }

    // 제목과 내용이 모두 없으면 알림을 띄우지 않음
    if (title == null && body == null) {
      if (kDebugMode) dev.log('Aborting notification: No title or body found in payload.', name: 'NOTIFICATION');
      return;
    }

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      showWhen: true,
    );
    
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await _flutterLocalNotificationsPlugin.show(
      message.hashCode,
      title,
      body,
      notificationDetails,
      payload: jsonEncode(message.data), // 데이터 페이로드를 전달
    );
  }

  // 알림 탭 핸들러 (앱이 이미 실행 중일 때)
  void _onDidReceiveNotificationResponse(NotificationResponse notificationResponse) {
    final String? payload = notificationResponse.payload;
    if (payload != null) {
      if (kDebugMode) dev.log('notification payload: $payload', name: 'NOTIFICATION');
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
    if (kDebugMode) dev.log('Message clicked!', name: 'NOTIFICATION');
    _handleMessageData(message.data);
  }

  // 데이터 페이로드 처리 및 화면 이동 로직 (라우터 연동 필요)
  void _handleMessageData(Map<String, dynamic> data) {
    if (kDebugMode) dev.log("Notification Data received: $data", name: 'NOTIFICATION');

    // TODO: 여기서 데이터 파싱 및 라우팅 로직 구현
    // routerProvider 접근을 위해 BuildContext가 필요하며,
    // NotificationService가 직접 Riverpod Consumer가 아니므로
    // rootNavigatorKey를 통해 context를 얻어 GoRouter를 사용해야 합니다.
    final context = rootNavigatorKey.currentContext;
    if (context == null) {
      if (kDebugMode) dev.log("Router context not available for navigation.", name: 'NOTIFICATION');
      return;
    }

    final String? notificationType = data['notificationType'];
    final String? metadataString = data['metadata'];
    
    if (kDebugMode) {
      dev.log("Parsed Notification Type: $notificationType", name: 'NOTIFICATION');
      dev.log("Parsed Metadata String: $metadataString", name: 'NOTIFICATION');
    }
    
    if (metadataString != null) {
       try {
         final Map<String, dynamic> metadata = jsonDecode(metadataString);
         if (kDebugMode) dev.log("Parsed Metadata: $metadata", name: 'NOTIFICATION');

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
               if (kDebugMode) dev.log("Navigating to Diary Detail for diaryId: $diaryId (Currently commented out)", name: 'NOTIFICATION');
             }
             break;
           case 'FOLLOW':
             final memberId = metadata['memberId'];
             if (memberId != null) {
               GoRouter.of(context).push('/profile/$memberId'); // 예시 라우트
               if (kDebugMode) dev.log("Navigating to Member Profile for memberId: $memberId (Currently commented out)", name: 'NOTIFICATION');
             }
             break;
           case 'QUIZ_COMPLETED':
             final bookId = metadata['bookId'];
             final challengeId = metadata['challengeId'];
             if (bookId != null && challengeId != null) {
               GoRouter.of(context).push('/reading-challenge/detail/$bookId?challengeId=$challengeId');
               if (kDebugMode) dev.log("Navigating to Reading Challenge Detail for bookId: $bookId, challengeId: $challengeId (Currently commented out)", name: 'NOTIFICATION');
             }
             break;
           default:
             if (kDebugMode) dev.log("Unknown notification type or no navigation defined for: $notificationType", name: 'NOTIFICATION');
             break;
         }
         */
       } catch (e) {
         if (kDebugMode) dev.log("Error parsing metadata JSON: $e", name: 'NOTIFICATION');
       }
    } else {
      if (kDebugMode) dev.log("No metadata found in notification payload.", name: 'NOTIFICATION');
    }
  }
}

