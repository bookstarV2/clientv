import 'package:bookstar/modules/learning/view/learning_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../model/login_request.dart';
import '../../view_model/auth_state.dart';
import '../../view_model/auth_view_model.dart';
import '../widgets/social_login_button.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(authViewModelProvider, (_, next) {
      final state = next.valueOrNull;
      if (state is AuthFailed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인을 완료하지 못했어요. 다시 시도해 주세요.')),
        );
      }
    });
    final auth = ref.watch(authViewModelProvider);
    final busy = auth.isLoading || auth.valueOrNull is AuthLoading;
    return LearningPage(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
        children: [
          const LearningLabel('BOOKSTAR'),
          if (auth.valueOrNull is AuthRestoreFailed) ...[
            const SizedBox(height: 18),
            const Text('저장된 로그인을 확인하지 못했어요.\n연결이 돌아오면 다시 시도해 주세요.',
                style: learningBodyStyle),
            TextButton(
                onPressed: () async {
                  await ref
                      .read(authViewModelProvider.notifier)
                      .retryStoredSession();
                },
                child: const Text('저장된 로그인 다시 확인하기')),
          ],
          const SizedBox(height: 28),
          const Text('읽은 책이\n내 지식이 되도록', style: learningTitleStyle),
          const SizedBox(height: 16),
          const Text('읽고 잊기 아쉬웠던 내용,\nAI 퀴즈 한 문제로 되짚어요.',
              style: learningBodyStyle),
          const SizedBox(height: 24),
          SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => context.push('/preview'),
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('로그인 없이 한 문제 체험'),
              )),
          const SizedBox(height: 14),
          const Text('읽은 목차 → 한 문제 → 복습',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13, height: 1.6, color: LearningColors.muted)),
          const SizedBox(height: 30),
          const Center(
              child: Text('내 책과 복습 기록을 저장하려면',
                  style: TextStyle(fontSize: 13, color: LearningColors.muted))),
          const SizedBox(height: 16),
          AbsorbPointer(
            absorbing: busy,
            child: Column(children: [
              SocialLoginButton(
                onPressed: () => ref
                    .read(authViewModelProvider.notifier)
                    .login(ProviderType.kakao),
                assetName: 'assets/icons/kakao.svg',
                label: '카카오로 시작하기',
                backgroundColor: const Color(0xFFFEE500),
                textColor: Colors.black87,
                analyticsEventName: 'click_kakao_login',
                analyticsEventParams: const {'screen_name': 'login'},
              ),
              const SizedBox(height: 10),
              SocialLoginButton(
                onPressed: () => ref
                    .read(authViewModelProvider.notifier)
                    .login(ProviderType.google),
                assetName: 'assets/icons/google.svg',
                label: 'Google로 시작하기',
                backgroundColor: Colors.white,
                textColor: LearningColors.ink,
                isGoogle: true,
                analyticsEventName: 'click_google_login',
                analyticsEventParams: const {'screen_name': 'login'},
              ),
              const SizedBox(height: 10),
              SocialLoginButton(
                onPressed: () => ref
                    .read(authViewModelProvider.notifier)
                    .login(ProviderType.apple),
                assetName: 'assets/icons/apple.svg',
                label: 'Apple로 시작하기',
                backgroundColor: Colors.white,
                textColor: LearningColors.ink,
                analyticsEventName: 'click_apple_login',
                analyticsEventParams: const {'screen_name': 'login'},
              ),
            ]),
          ),
          if (busy)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                  child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2))),
            ),
          const SizedBox(height: 22),
          Wrap(alignment: WrapAlignment.center, children: [
            TextButton(
                onPressed: () => context.push('/policies/service'),
                child: const Text('서비스 이용약관')),
            TextButton(
                onPressed: () => context.push('/policies/privacy'),
                child: const Text('개인정보 수집 및 이용')),
          ]),
          const Center(
              child: Text('AI 퀴즈에는 오류가 있을 수 있어요.\n책과 함께 확인하며 이용해 주세요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 12, height: 1.6, color: LearningColors.muted))),
        ],
      ),
    );
  }
}
