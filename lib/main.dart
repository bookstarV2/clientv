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
import 'common/theme/app_theme.dart';
import 'gen/assets.gen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await dotenv.load(fileName: Assets.env.aEnv);
  KakaoSdk.init(
    nativeAppKey: dotenv.env['KAKAO_NATIVE_KEY'],
  );

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
      ref.read(notificationServiceProvider).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final goRouter = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Book SNS App',
      theme: AppTheme.themeData,
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
