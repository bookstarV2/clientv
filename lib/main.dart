import 'package:bookstar/firebase_options.dart';
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
  await dotenv.load(fileName: Assets.env.aEnv);

  KakaoSdk.init(
    nativeAppKey: dotenv.env['KAKAO_NATIVE_KEY'],
  );

  final fontLoader = FontLoader('BookkMyungjo');
  fontLoader.addFont(rootBundle.load(Assets.fonts.bookkMyungjoBold));
  fontLoader.addFont(rootBundle.load(Assets.fonts.akiraExpandedDemo));
  await fontLoader.load();

  // await FlutterSecureStorage().deleteAll();

  runApp(
    ProviderScope(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 480, // 스마트폰 크기 정도로 고정
          ),
          child: MyApp(),
        ),
      ),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Book SNS App',
      theme: AppTheme.themeData,
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
