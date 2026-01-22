import 'package:bookstar/common/components/base_screen.dart';
import 'package:bookstar/common/components/button/cta_button_l1.dart';
import 'package:bookstar/common/theme/style/app_texts.dart';
import 'package:bookstar/gen/assets.gen.dart';
import 'package:bookstar/gen/colors.gen.dart';
import 'package:bookstar/modules/reading_challenge/model/quiz_choice.dart';
import 'package:bookstar/modules/reading_challenge/view_model/challenge_quiz_view_model.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

class ReadingChallengeQuizCheckScreen extends BaseScreen {
  const ReadingChallengeQuizCheckScreen({
    super.key,
    required this.chapterId,
    required this.challengeId,
    required this.onButtonTap,
  });

  final int chapterId;
  final int challengeId;
  final VoidCallback onButtonTap;

  @override
  BaseScreenState<ReadingChallengeQuizCheckScreen> createState() =>
      _ReadingChallengeQuizCheckScreenState();
}

class _ReadingChallengeQuizCheckScreenState
    extends BaseScreenState<ReadingChallengeQuizCheckScreen> {
  @override
  Widget buildBody(BuildContext context) {
    final state = ref.watch(challengeQuizViewModelProvider(widget.chapterId));
    return state.when(
      data: (data) {
        return _buildQuizPage(
          question: data.chapter.question,
          choices: data.chapter.choices,
        );
      },
      loading: loading,
      error: error("리딩 챌린지 퀴즈 정보 취득 중 오류가 발생했습니다. ${widget.chapterId}"),
    );
  }

  Widget _buildQuizPage({
    required String question,
    required List<QuizChoice> choices,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 30,
          ),
          Text("뒷내용이 궁금해지는", style: AppTexts.b1.copyWith(color: ColorName.w1)),
          Text("오늘의 퀴즈를 확인해 보세요",
              style: AppTexts.b1.copyWith(color: ColorName.w1)),
          SizedBox(height: 70),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: ColorName.dim2.withValues(alpha: 0.3),
              boxShadow: [
                // 외곽 빛
                BoxShadow(
                  color: ColorName.p1.withValues(alpha: 0.1),
                  blurRadius: 40,
                  spreadRadius: 50,
                ),
                // 하단 그림자
                BoxShadow(
                  color: ColorName.b1.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                    width: 37,
                    height: 37,
                    child: Assets.images.icQuizCheck.image()),
                SizedBox(
                  height: 6,
                ),
                Text("오늘의 퀴즈",
                    style: AppTexts.b8.copyWith(color: ColorName.g3)),
                SizedBox(
                  height: 16,
                ),
                Text(
                  question,
                  style: AppTexts.b5.copyWith(color: ColorName.w1),
                )
              ],
            ),
          ),
          SizedBox(height: 60)
        ],
      ),
    );
  }

  @override
  Widget? buildFloatingActionButton(BuildContext context) {
    return CtaButtonL1(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF775DFF),
          Color(0xFF5DD6D8),
        ],
      ),
      text: '책 속에서 정답 찾기',
      onPressed: () {
        widget.onButtonTap();
      },
    );
  }
}
