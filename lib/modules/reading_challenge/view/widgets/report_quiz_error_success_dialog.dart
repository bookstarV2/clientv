import 'package:bookstar/common/components/button/cta_button_l1.dart';
import 'package:bookstar/common/theme/style/app_texts.dart';
import 'package:bookstar/gen/assets.gen.dart';
import 'package:bookstar/gen/colors.gen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ReportQuizErrorSuccessDialog extends StatelessWidget {
  const ReportQuizErrorSuccessDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          left: 16,
          right: 16,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("퀴즈 오류가 접수되었어요",
                style: AppTexts.b5.copyWith(color: ColorName.w1)),
            SizedBox(
              height: 6,
            ),
            Text("보다 유익한 북스타가 될 수 있도록 빠르게 조치할게요",
                style: AppTexts.b10.copyWith(color: ColorName.g1)),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(child: Assets.icons.icPointShopChar2.svg()),
            ),
            CtaButtonL1(
              text: '닫기',
              onPressed: () {
                context.pop();
              },
            ),
            SizedBox(
              height: 16,
            ),
          ],
        ),
      ),
    );
  }
}
