import 'package:bookstar/common/components/button/cta_button_l1.dart';
import 'package:bookstar/common/theme/style/app_texts.dart';
import 'package:bookstar/gen/assets.gen.dart';
import 'package:bookstar/gen/colors.gen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ReadingChallengeHasQuizDialog extends StatelessWidget {
  const ReadingChallengeHasQuizDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("리딩 챌린지")),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "선택하신 책의",
                    style: AppTexts.b1.copyWith(color: ColorName.w1),
                  ),
                  Text.rich(TextSpan(children: [
                    TextSpan(
                        text: "목차별 퀴즈",
                        style: AppTexts.b1.copyWith(color: ColorName.p1)),
                    TextSpan(
                        text: "를 생성하고",
                        style: AppTexts.b1.copyWith(color: ColorName.w1)),
                  ])),
                  Text(
                    "리딩 챌린지를 시작할까요?",
                    style: AppTexts.b1.copyWith(color: ColorName.w1),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    "퀴즈 생성은 약 1분 정도 소요돼요.",
                    style: AppTexts.b6.copyWith(color: ColorName.g3),
                  ),
                ],
              ),
            ),
            Expanded(
                child: Center(
              child: Assets.icons.icReadingChallengeHasQuiz.svg(),
            )),
            Center(
                child: CtaButtonL1(
              text: "퀴즈 생성하기",
              onPressed: () {
                context.pop(true);
              },
            )),
            SizedBox(
              height: 8,
            ),
            Center(
              child: CtaButtonL1(
                text: "다른 책 찾아보기",
                backgroundColor: ColorName.g7,
                borderColor: ColorName.g7,
                onPressed: () {
                  context.pop();
                },
              ),
            ),
            SizedBox(
              height: 20,
            )
          ],
        ));
  }
}
