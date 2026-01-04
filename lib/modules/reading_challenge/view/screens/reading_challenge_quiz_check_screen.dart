import 'package:bookstar/common/components/base_screen.dart';
import 'package:bookstar/common/components/button/cta_button_l1.dart';
import 'package:bookstar/common/service/analytics_service.dart';
import 'package:bookstar/common/theme/style/app_texts.dart';
import 'package:bookstar/gen/colors.gen.dart';
import 'package:bookstar/modules/reading_challenge/model/quiz_choice.dart';
import 'package:bookstar/modules/reading_challenge/view/widgets/report_quiz_error_dialog.dart';
import 'package:bookstar/modules/reading_challenge/view/widgets/report_quiz_error_success_dialog.dart';
import 'package:bookstar/modules/reading_challenge/view_model/challenge_quiz_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

class ReadingChallengeQuizCheckScreen extends BaseScreen {
  const ReadingChallengeQuizCheckScreen(
      {super.key, required this.chapterId, required this.challengeId});

  final int chapterId;
  final int challengeId;

  @override
  BaseScreenState<ReadingChallengeQuizCheckScreen> createState() =>
      _ReadingChallengeQuizCheckScreenState();
}

class _ReadingChallengeQuizCheckScreenState
    extends BaseScreenState<ReadingChallengeQuizCheckScreen> {
  // int? _selectedChoiceId;

  Future<void> _onTapQuizError() async {
    final quizId = ref
        .read(challengeQuizViewModelProvider(widget.chapterId))
        .value
        ?.quizId;
    AnalyticsService.logEvent('click_open_report_quiz_error', parameters: {
      'screen_name': "reading_challenge_quiz_check",
      "quiz_id": quizId
    });
    final result = await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => ReportQuizErrorDialog(
              quizId: quizId!,
            ));

    if (result && mounted) {
      await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => ReportQuizErrorSuccessDialog());
    }
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('리딩챌린지'),
      leading: IconButton(
        icon: const BackButton(),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    final state = ref.watch(challengeQuizViewModelProvider(widget.chapterId));
    return state.when(
      data: (data) {
        return _buildQuizPage(
          scrollController: scrollController,
          question: data.chapter.question,
          choices: data.chapter.choices,
          onTapQuizError: () => _onTapQuizError(),
        );
      },
      loading: loading,
      error: error("리딩 챌린지 퀴즈 정보 취득 중 오류가 발생했습니다. ${widget.chapterId}"),
    );
  }

  Widget _buildQuizPage({
    required ScrollController scrollController,
    required String question,
    required List<QuizChoice> choices,
    required Function onTapQuizError,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverToBoxAdapter(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => onTapQuizError(),
                    child: Text("퀴즈에 오류가 있나요?",
                        style: AppTexts.b8.copyWith(color: ColorName.g3)),
                  ),
                ],
              ),
              SizedBox(
                height: 12,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Q", style: AppTexts.b2.copyWith(color: ColorName.p1)),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      question,
                      style: AppTexts.b3.copyWith(color: ColorName.w1),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 24,
              ),
              Column(
                spacing: 12,
                children: choices
                    .map((choice) => Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: ColorName.g7,
                          borderRadius: BorderRadius.circular(10),
                          border: null,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 20),
                          child: Text(
                            choice.choiceText,
                            style: AppTexts.b8.copyWith(color: ColorName.g3),
                          ),
                        )))
                    .toList(),
              ),
              SizedBox(height: 60)
            ],
          )),
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
      text: '책읽고 퀴즈 풀러가기',
      onPressed: () {
        context.push(
            '/reading-challenge/${widget.challengeId}/quiz/${widget.chapterId}/deep-time');
      },
    );
  }
}
