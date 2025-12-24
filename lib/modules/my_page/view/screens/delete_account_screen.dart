import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/view_model/auth_view_model.dart';
import '../../../auth/view_model/auth_state.dart';

import '../../../../common/components/button/cta_button_l1.dart';
import '../../../../common/components/form/checkbox_2.dart';
import '../../../../common/theme/style/app_paddings.dart';
import '../../../../common/theme/style/app_sizes.dart';
import '../../../../common/theme/style/app_texts.dart';
import '../../../../gen/colors.gen.dart';
import '../../../../gen/assets.gen.dart';
import '../widgets/radio_button_1_static.dart';

class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() =>
      _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  bool isChecked = false;
  bool isDeleted = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final isWithdrawCompleted = authState.when(
      data: (data) => data is AuthWithdrawCompleted,
      loading: () => false,
      error: (e, t) => false,
    );
    final showCompletedUI = isDeleted || isWithdrawCompleted;

    return Scaffold(
      appBar: AppBar(
        title: const Text('회원 탈퇴'),
        leading: isDeleted
            ? null
            : IconButton(
                icon: const BackButton(),
                onPressed: () => Navigator.of(context).pop(),
              ),
        automaticallyImplyLeading: !isDeleted,
        actions: [
          if (!isDeleted)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                GoRouter.of(context).go('/my-feed');
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: AppPaddings.SCREEN_BODY_PADDING,
            child: Column(
              children: [
                showCompletedUI
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                                height: 188 -
                                    AppSizes.APP_BAR_HEIGHT -
                                    AppPaddings.SCREEN_BODY_PADDING.top -
                                    MediaQuery.of(context).padding.top),
                            Text(
                              '회원 탈퇴 완료',
                              style: AppTexts.b8.copyWith(color: ColorName.g3),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '독서 습관이 느슨해질 때면\u2028언제든 돌아오세요',
                              style: AppTexts.b1.copyWith(color: ColorName.w1),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '떠난다니 아쉬워요',
                              style: AppTexts.h4.copyWith(color: ColorName.w1),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '탈퇴 전 아래의 정보를 꼼꼼히 확인해 주세요.',
                              style: AppTexts.b8.copyWith(color: ColorName.g3),
                            ),
                            const SizedBox(height: 30),
                            SizedBox(
                              height: 233,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  RadioButton1Static(
                                    title: '모든 데이터가 즉시 삭제돼요',
                                    description:
                                        '북스타에서 활동한 데이터는 탈퇴와 동시에 즉시 삭제되며, 삭제된 이후에는 다시 불러올 수 없어요.',
                                  ),
                                  RadioButton1Static(
                                    title: '30일 내 로그인하면 탈퇴가 취소돼요',
                                    description:
                                        '유예 기간인 30일 내 로그인 한다면, 탈퇴 신청이 취소되어 기존의 계정으로 북스타에서 활동할 수 있어요',
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Center(
                              child: CheckBox2(
                                label: '위 주의사항을 모두 숙지했으며 탈퇴에 동의해요',
                                value: isChecked,
                                onChanged: (value) {
                                  setState(() {
                                    isChecked = value;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
              ],
            ),
          ),
          if (showCompletedUI)
            Align(
              alignment: Alignment.center,
              child: Assets.icons.icWithdrawal.svg(
                width: 130,
                height: 137.0982208251953,
              ),
            ),
          if (showCompletedUI)
            Positioned(
              left: 14,
              right: 14,
              bottom: 10,
              child: CtaButtonL1(
                text: '북스타 종료하기',
                enabled: true,
                analyticsEventName: 'click_exit_app_after_withdraw',
                analyticsEventParams: const {
                  'screen_name': 'delete_account',
                },
                onPressed: () {
                  if (Platform.isAndroid) {
                    SystemNavigator.pop();
                  } else if (Platform.isIOS) {
                    GoRouter.of(context).go('/login');
                  }
                },
              ),
            ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 54),
        child: CtaButtonL1(
          text: showCompletedUI ? '로그인 하고 탈퇴 취소하기' : '탈퇴하기',
          enabled: showCompletedUI ? true : isChecked,
          analyticsEventName: showCompletedUI
              ? 'click_cancel_withdraw_from_login'
              : 'click_confirm_withdraw',
          analyticsEventParams: const {
            'screen_name': 'delete_account',
          },
          onPressed: showCompletedUI
              ? () {
                  GoRouter.of(context).go('/login');
                }
              : isChecked
                  ? () async {
                      try {
                        // 실제 탈퇴 API 호출
                        await ref
                            .read(authViewModelProvider.notifier)
                            .withdraw();

                        setState(() {
                          isDeleted = true;
                        });
                      } catch (e) {
                        // 에러 처리
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('탈퇴 처리 중 오류가 발생했습니다: $e')),
                        );
                      }
                    }
                  : null,
          backgroundColor: showCompletedUI ? ColorName.g7 : null,
          borderColor: showCompletedUI ? ColorName.g6 : null,
        ),
      ),
    );
  }
}
