import 'package:bookstar/common/service/analytics_service.dart';
import 'package:bookstar/modules/learning/view/bs_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../model/login_request.dart';
import '../../view_model/auth_state.dart';
import '../../view_model/auth_view_model.dart';

const _socialLabelColor = Color(0xD9000000);

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
    final notifier = ref.read(authViewModelProvider.notifier);
    return Scaffold(
      backgroundColor: Bs.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 26.5, 16, 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('읽은 책이\n오래 기억되도록',
                        style: Bs.text(22,
                            weight: FontWeight.w600, letterSpacing: 0)),
                    const SizedBox(height: 8),
                    Text('AI 퀴즈로 책을 더 깊이 읽고,\n끝까지 완독해보세요.',
                        style: Bs.text(16, color: Bs.g3, letterSpacing: 0)),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: auth.valueOrNull is AuthRestoreFailed
                              ? BsEmptyState(
                                  message:
                                      '저장된 로그인을 확인하지 못했어요.\n연결이 돌아오면 다시 시도해 주세요.',
                                  action: BsSecondaryButton(
                                    label: '저장된 로그인 다시 확인하기',
                                    height: 44,
                                    expand: false,
                                    onPressed: notifier.retryStoredSession,
                                  ),
                                )
                              : Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const BsCharacterImage(BsCharacter.books,
                                        width: 137),
                                    if (busy)
                                      const Padding(
                                        padding: EdgeInsets.only(top: 12),
                                        child: SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Bs.primary)),
                                      ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    BsPrimaryButton(
                        label: '로그인 없이 한 문제 풀어보기',
                        onPressed: () => context.push('/preview')),
                    const SizedBox(height: 20),
                    const _OrDivider(),
                    const SizedBox(height: 21),
                    AbsorbPointer(
                      absorbing: busy,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _SocialButton(
                            icon: SvgPicture.asset('assets/icons/kakao.svg',
                                width: 20, height: 20),
                            label: '카카오로 시작하기',
                            color: Bs.kakao,
                            analyticsEvent: 'click_kakao_login',
                            onPressed: () => notifier.login(ProviderType.kakao),
                          ),
                          const SizedBox(height: 12),
                          _SocialButton(
                            icon: SvgPicture.asset('assets/icons/google.svg',
                                width: 22, height: 22),
                            label: 'Google로 시작하기',
                            analyticsEvent: 'click_google_login',
                            onPressed: () =>
                                notifier.login(ProviderType.google),
                          ),
                          const SizedBox(height: 12),
                          _SocialButton(
                            icon: SvgPicture.asset('assets/icons/apple.svg',
                                width: 24, height: 24),
                            label: 'Apple로 시작하기',
                            analyticsEvent: 'click_apple_login',
                            onPressed: () => notifier.login(ProviderType.apple),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Column(
                  children: [
                    Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        _PolicyLink('서비스 이용약관',
                            () => context.push('/policies/service')),
                        _PolicyLink('개인정보 수집 및 이용',
                            () => context.push('/policies/privacy')),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('AI 퀴즈에는 오류가 있을 수 있어요.\n책과 함께 확인하며 이용해 주세요.',
                        textAlign: TextAlign.center,
                        style: Bs.caption.copyWith(color: Bs.g2)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) => Row(
        children: [
          const Expanded(child: Divider(height: 1, thickness: 1, color: Bs.g1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text('또는',
                style: Bs.text(14, weight: FontWeight.w600, color: Bs.g2)),
          ),
          const Expanded(child: Divider(height: 1, thickness: 1, color: Bs.g1)),
        ],
      );
}

/// 56pt social login button (Figma 0.1): Kakao yellow, Google/Apple white
/// with a W3 outline.
class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.label,
    required this.analyticsEvent,
    required this.onPressed,
    this.color,
  });

  final Widget icon;
  final String label;
  final String analyticsEvent;
  final VoidCallback onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: TextButton(
          onPressed: () {
            AnalyticsService.logEvent(analyticsEvent,
                parameters: const {'screen_name': 'login'}).ignore();
            onPressed();
          },
          style: TextButton.styleFrom(
            backgroundColor: color ?? Bs.white,
            foregroundColor: _socialLabelColor,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Bs.radius),
              side: color == null
                  ? const BorderSide(color: Bs.surface)
                  : BorderSide.none,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(width: 10),
              Flexible(
                child: Text(label,
                    textAlign: TextAlign.center,
                    style: Bs.text(16,
                        weight: FontWeight.w600, color: _socialLabelColor)),
              ),
            ],
          ),
        ),
      );
}

class _PolicyLink extends StatelessWidget {
  const _PolicyLink(this.label, this.onPressed);

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: Bs.g3,
          minimumSize: const Size(44, 44),
          textStyle: Bs.text(12, height: 1.6),
        ),
        child: Text(label),
      );
}
