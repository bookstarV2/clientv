import 'package:bookstar/common/theme/style/app_paddings.dart';
import 'package:bookstar/common/theme/style/app_texts.dart';
import 'package:bookstar/modules/my_page/view/widgets/label_section.dart';
import 'package:bookstar/gen/colors.gen.dart';
import 'package:bookstar/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bookstar/modules/auth/view_model/auth_view_model.dart';
import 'package:bookstar/modules/auth/view_model/auth_state.dart';
import 'package:bookstar/common/components/dialog/custom_dialog.dart';

class LoginInfoScreen extends ConsumerWidget {
  const LoginInfoScreen({super.key});

  Widget _getProviderIcon(String providerType) {
    switch (providerType.toUpperCase()) {
      case 'GOOGLE':
        return Assets.icons.google.svg(width: 13, height: 13);
      case 'KAKAO':
        return Assets.icons.kakao.svg(width: 13, height: 13);
      case 'APPLE':
        return Assets.icons.apple.svg(width: 13, height: 13);
      default:
        return Assets.icons.google.svg(width: 14, height: 14);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const double titleWidth = 80;
    final authState = ref.watch(authViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('로그인 정보'),
        leading: IconButton(
          icon: const BackButton(),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              GoRouter.of(context).go('/my-feed');
            },
          ),
        ],
      ),
      body: Padding(
        padding: AppPaddings.SCREEN_BODY_PADDING,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 58,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: titleWidth,
                    child: LabelSection('간편 회원 가입'),
                  ),
                  const SizedBox(width: 18),
                  ...authState.when(
                    data: (data) => data is AuthSuccess
                        ? [
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: data.providerType == 'KAKAO'
                                    ? const Color(0xFFFEE500)
                                    : ColorName.w1,
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: Center(
                                child: _getProviderIcon(data.providerType),
                              ),
                            ),
                            const SizedBox(width: 7),
                          ]
                        : [],
                    loading: () => [],
                    error: (e, t) => [],
                  ),
                  Expanded(
                      child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => CustomDialog(
                          title: '로그아웃',
                          content: '정말 로그아웃하시겠어요?',
                          icon: Assets.icons.icReadingChallengeChar1
                              .svg(width: 100, height: 106.8803482055664),
                          cancelButtonText: '취소',
                          confirmButtonText: '로그아웃',
                          confirmAnalyticsEventName: 'click_logout_confirm',
                          analyticsEventParams: const {
                            'screen_name': 'login_info',
                          },
                          cancelAnalyticsEventName: 'click_logout_cancel',
                          onCancel: () => Navigator.of(context).pop(),
                          onConfirm: () async {
                            await ref
                                .read(authViewModelProvider.notifier)
                                .signOut();
                            if (context.mounted) {
                              Navigator.of(context).pop();
                              context.go('/login');
                            }
                          },
                        ),
                      );
                    },
                    child: TextField(
                      enabled: false,
                      maxLines: 1,
                      minLines: 1,
                      style: AppTexts.b8.copyWith(color: ColorName.w1),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        filled: true,
                        fillColor: Colors.transparent,
                        hintText: authState.when(
                          data: (data) =>
                              data is AuthSuccess ? data.email : '이메일 정보 없음',
                          loading: () => '이메일 정보 없음',
                          error: (e, t) => '이메일 정보 없음',
                        ),
                        hintStyle: authState.when(
                          data: (data) => data is AuthSuccess
                              ? AppTexts.b8.copyWith(color: ColorName.w1)
                              : AppTexts.b8.copyWith(
                                  color: ColorName.e0,
                                  decoration: TextDecoration.underline,
                                ),
                          loading: () => AppTexts.b8.copyWith(
                            color: ColorName.e0,
                            decoration: TextDecoration.underline,
                          ),
                          error: (e, t) => AppTexts.b8.copyWith(
                            color: ColorName.e0,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        isCollapsed: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  )),
                ],
              ),
            ),
            const Divider(height: 1, color: ColorName.g7, thickness: 1),
            SizedBox(
              height: 58,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: titleWidth,
                    child: LabelSection('연동 상태'),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: TextField(
                      enabled: false,
                      maxLines: 1,
                      minLines: 1,
                      style: AppTexts.b8.copyWith(color: ColorName.w1),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        filled: true,
                        fillColor: Colors.transparent,
                        hintText: authState.when(
                          data: (data) => data is AuthSuccess ? "연동중" : '연동 문재',
                          loading: () => '연동 상태',
                          error: (e, t) => '연동 상태',
                        ),
                        hintStyle: authState.when(
                          data: (data) => data is AuthSuccess
                              ? AppTexts.b8.copyWith(color: ColorName.w1)
                              : AppTexts.b8.copyWith(
                                  color: ColorName.e0,
                                  decoration: TextDecoration.underline,
                                ),
                          loading: () => AppTexts.b8.copyWith(
                            color: ColorName.e0,
                            decoration: TextDecoration.underline,
                          ),
                          error: (e, t) => AppTexts.b8.copyWith(
                            color: ColorName.e0,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        isCollapsed: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: ColorName.g7, thickness: 1),
          ],
        ),
      ),
    );
  }
}
