import 'package:flutter/material.dart' hide IconAlignment;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/extension/string_extensions.dart';
import '../../../../common/theme/app_style.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/colors.gen.dart';
import '../../model/login_request.dart';
import '../../view_model/auth_view_model.dart';
import '../widgets/animated_hero_switcher.dart';
import '../widgets/social_login_button.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppPaddings.LOGIN_SCREEN_PADDING,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGreetingSection(),
              _buildHeroSection(),
              _buildButtonSection(ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12.0,
      children: [
        RichText(
          textAlign: TextAlign.start,
          text: TextSpan(
            children: [
              '책'.colored(baseStyle: AppTexts.h4, color: ColorName.p1),
              '은 좋아하는데,\n'.colored(baseStyle: AppTexts.h4, color: ColorName.w1),
              '꾸준히'.colored(baseStyle: AppTexts.h4, color: ColorName.p1),
              '가 어려웠다면.'.colored(baseStyle: AppTexts.h4, color: ColorName.w1),
            ],
          ),
        ),
        Text(
          '지금 북스타에서 시작해 보세요',
          textAlign: TextAlign.start,
          style: AppTexts.b8.copyWith(color: ColorName.g3),
        ),
      ],
    );
  }

  Widget _buildHeroSection() {
    return Center(
      child: AnimatedHeroSwitcher(
        imagePaths: [
          Assets.images.heroLookUp3x.path,
          Assets.images.heroLookForward3x.path,
        ],
      ),
    );
  }

  Widget _buildButtonSection(WidgetRef ref) {
    return Column(
      spacing: 12.0,
      children: [
        SocialLoginButton(
          onPressed: () {
            ref
                .read(authViewModelProvider.notifier)
                .login(ProviderType.kakao);
          },
          assetName: 'assets/icons/kakao.svg',
          label: '카카오 로그인',
          backgroundColor: const Color(0xFFFEE500),
          textColor: Colors.black87,
          analyticsEventName: 'click_kakao_login',
          analyticsEventParams: const {
            'screen_name': 'login',
          },
        ),
        SocialLoginButton(
          onPressed: () {
            ref
                .read(authViewModelProvider.notifier)
                .login(ProviderType.google);
          },
          assetName: 'assets/icons/google.svg',
          label: 'Google로 로그인',
          backgroundColor: Colors.white,
          textColor: Colors.black,
          isGoogle: true,
          analyticsEventName: 'click_google_login',
          analyticsEventParams: const {
            'screen_name': 'login',
          },
        ),
        SocialLoginButton(
          onPressed: () {
            ref
                .read(authViewModelProvider.notifier)
                .login(ProviderType.apple);
          },
          assetName: 'assets/icons/apple.svg',
          label: 'Apple로 로그인',
          backgroundColor: Colors.white,
          textColor: Colors.black,
          analyticsEventName: 'click_apple_login',
          analyticsEventParams: const {
            'screen_name': 'login',
          },
        ),
      ],
    );
  }
}
