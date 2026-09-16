import 'core/notification_service.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // 추가
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

import 'common/router/router.dart';
import 'modules/learning/view/learning_design.dart';
import 'gen/assets.gen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 로컬 시뮬 실행: 스텁 키로도 앱이 죽지 않도록 초기화 실패를 무시
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  } catch (e) {
    debugPrint('[local-sim] Firebase init skipped: $e');
  }
  await dotenv.load(fileName: Assets.env.aEnv);
  try {
    KakaoSdk.init(
      nativeAppKey: dotenv.env['KAKAO_NATIVE_KEY'],
    );
  } catch (e) {
    debugPrint('[local-sim] Kakao init skipped: $e');
  }

  final fontLoader = FontLoader('BookkMyungjo');
  fontLoader.addFont(rootBundle.load(Assets.fonts.bookkMyungjoBold));
  fontLoader.addFont(rootBundle.load(Assets.fonts.akiraExpandedDemo));
  fontLoader.load();
  runApp(
    ProviderScope(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 480, // 스마트폰 크기 정도로 고정
          ),
          child: const MyApp(),
        ),
      ),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    // 알림 서비스 초기화
    // (빌드 후 실행되도록 addPostFrameCallback 사용하거나, 비동기로 실행)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // [local-sim] 알림 권한 다이얼로그가 AXe 탭을 막아 임시 비활성화
      // ref.read(notificationServiceProvider).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final goRouter = ref.watch(routerProvider);

    return MaterialApp.router(
      title: '북스타 · 읽은 책을 내 지식으로',
      theme: LearningColors.theme,
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
