import 'package:bookstar/common/components/base_screen.dart';
import 'package:bookstar/common/components/button/cta_button_l1.dart';
import 'package:bookstar/common/service/analytics_service.dart';
import 'package:bookstar/common/theme/style/app_texts.dart';
import 'package:bookstar/gen/assets.gen.dart';
import 'package:bookstar/gen/colors.gen.dart';
import 'package:bookstar/modules/reading_challenge/model/choice_result.dart';
import 'package:bookstar/modules/reading_challenge/model/quiz_choice.dart';
import 'package:bookstar/modules/reading_challenge/view/widgets/report_quiz_error_dialog.dart';
import 'package:bookstar/modules/reading_challenge/view/widgets/report_quiz_error_success_dialog.dart';
import 'package:bookstar/modules/reading_challenge/view_model/challenge_quiz_view_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

class ReadingChallengeQuizScreen extends BaseScreen {
  const ReadingChallengeQuizScreen(
      {super.key, required this.chapterId, required this.challengeId});

  final int chapterId;
  final int challengeId;

  @override
  BaseScreenState<ReadingChallengeQuizScreen> createState() =>
      _ReadingChallengeQuizScreenState();
}

class _ReadingChallengeQuizScreenState
    extends BaseScreenState<ReadingChallengeQuizScreen>
    with TickerProviderStateMixin {
  int? _selectedChoiceId;
  List<bool> _isExpandedList = [];
  List<AnimationController> _animationControllerList = [];
  List<Animation<double>> _animationList = [];
  List<Animation<double>> _iconTurnsList = [];

  @override
  void dispose() {
    for (final controller in _animationControllerList) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _onTapQuizError() async {
    final quizId = ref
        .read(challengeQuizViewModelProvider(widget.chapterId))
        .value
        ?.quizId;
    AnalyticsService.logEvent('click_open_report_quiz_error', parameters: {
      'screen_name': "reading_challenge_quiz",
      "quiz_id": quizId
    });

    final result = await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => ReportQuizErrorDialog(
              quizId: quizId!,
            ));

    if (result != null && result && mounted) {
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
        return data.choiceResults == null
            ? _buildQuizPage(
                scrollController: scrollController,
                question: data.chapter.question,
                choices: data.chapter.choices,
                changeChoiceId: (choiceId) {
                  setState(() {
                    _selectedChoiceId = choiceId;
                  });
                },
                selectedChoiceId: _selectedChoiceId,
                onTapQuizError: () {
                  _onTapQuizError();
                },
              )
            : _buildQuizResultPage(
                scrollController: scrollController,
                question: data.chapter.question,
                choices: data.chapter.choices,
                selectedChoiceId: _selectedChoiceId,
                choiceResults: data.choiceResults!,
                iconTurnList: _iconTurnsList,
                animationList: _animationList,
                onArrowTap: (index) {
                  setState(() {
                    _isExpandedList[index] = !_isExpandedList[index];
                  });

                  if (_isExpandedList[index]) {
                    _animationControllerList[index].forward();
                  } else {
                    _animationControllerList[index].reverse();
                  }
                },
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
    required Function(int) changeChoiceId,
    required int? selectedChoiceId,
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
                    .map((choice) => GestureDetector(
                          onTap: () => changeChoiceId(choice.choiceId),
                          child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: selectedChoiceId == choice.choiceId
                                    ? ColorName.p1.withValues(alpha: 0.2)
                                    : ColorName.g7,
                                borderRadius: BorderRadius.circular(10),
                                border: selectedChoiceId == choice.choiceId
                                    ? Border.all(color: ColorName.p1)
                                    : null,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16.0, horizontal: 20),
                                child: Text(
                                  choice.choiceText,
                                  style: AppTexts.b8.copyWith(
                                      color: selectedChoiceId == choice.choiceId
                                          ? ColorName.w1
                                          : ColorName.g3),
                                ),
                              )),
                        ))
                    .toList(),
              ),
              SizedBox(height: 60)
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildQuizResultPage({
    required ScrollController scrollController,
    required String question,
    required List<QuizChoice> choices,
    required int? selectedChoiceId,
    required List<ChoiceResult> choiceResults,
    required List<Animation<double>> iconTurnList,
    required List<Animation<double>> animationList,
    required Function(int) onArrowTap,
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
                children: choices.mapIndexed((index, choice) {
                  final choiceResult = choiceResults.firstWhereOrNull(
                      (element) => element.choiceId == choice.choiceId);
                  final isSelected = selectedChoiceId == choice.choiceId;
                  if (choiceResult == null) {
                    return Container();
                  }
                  return Column(
                    children: [
                      Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: choiceResult.isCorrect && isSelected
                                ? LinearGradient(
                                    colors: [
                                      Color(0xFF775DFF),
                                      Color(0xFF56C5C7),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            color: !choiceResult.isCorrect && isSelected
                                ? ColorName.r
                                : null,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16.0, horizontal: 20),
                            child: Row(
                              children: [
                                choiceResult.isCorrect
                                    ? Assets.icons.icChoiceCorrect.svg()
                                    : Assets.icons.icChoiceUncorrect.svg(
                                        colorFilter: ColorFilter.mode(
                                            choiceResult.isCorrect ||
                                                    !choiceResult.isCorrect &&
                                                        isSelected
                                                ? ColorName.w1
                                                : ColorName.g3,
                                            BlendMode.srcIn),
                                      ),
                                SizedBox(
                                  width: 8,
                                ),
                                Expanded(
                                  child: Text(
                                    choice.choiceText,
                                    style: AppTexts.b8.copyWith(
                                        color: choiceResult.isCorrect ||
                                                !choiceResult.isCorrect &&
                                                    isSelected
                                            ? ColorName.w1
                                            : ColorName.g3),
                                  ),
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                GestureDetector(
                                  onTap: () => onArrowTap(index),
                                  child: RotationTransition(
                                    turns: iconTurnList[index],
                                    child: Assets.icons.icArrowDown.svg(
                                      colorFilter: ColorFilter.mode(
                                          choiceResult.isCorrect ||
                                                  !choiceResult.isCorrect &&
                                                      isSelected
                                              ? ColorName.w1
                                              : ColorName.g3,
                                          BlendMode.srcIn),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                      SizeTransition(
                        sizeFactor: animationList[index],
                        child: Column(
                          children: [
                            SizedBox(
                              height: 8,
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: Text(choiceResult.explanation,
                                  style: AppTexts.b8.copyWith(
                                    color: ColorName.g3,
                                  )),
                            ),
                          ],
                        ),
                      )
                    ],
                  );
                }).toList(),
              ),
              SizedBox(height: 68)
            ],
          )),
        ],
      ),
    );
  }

  @override
  Widget? buildFloatingActionButton(BuildContext context) {
    final state = ref.watch(challengeQuizViewModelProvider(widget.chapterId));

    return state.value?.choiceResults == null
        ? CtaButtonL1(
            backgroundColor: ColorName.p1,
            text: '퀴즈 풀기',
            onPressed: () {
              submitQuiz();
            },
          )
        : CtaButtonL1(
            backgroundColor: ColorName.p1,
            text: '챌린지 종료하기',
            onPressed: () {
              quitChallenge();
            },
          );
  }

  submitQuiz() async {
    if (_selectedChoiceId == null) return;
    final notifier =
        ref.read(challengeQuizViewModelProvider(widget.chapterId).notifier);
    await notifier.submitQuiz(
      choiceId: _selectedChoiceId!,
      challengeId: widget.challengeId,
    );
    final state = ref.watch(challengeQuizViewModelProvider(widget.chapterId));
    final length = state.value?.chapter.choices.length ?? 0;
    setState(() {
      _isExpandedList = List<bool>.filled(length, false);

      _animationControllerList.clear();
      _animationList.clear();
      _iconTurnsList.clear();
      for (int i = 0; i < length; i++) {
        final controller = AnimationController(
          duration: Duration(milliseconds: 200),
          vsync: this,
        );

        final animation = CurvedAnimation(
          parent: controller,
          curve: Curves.easeIn,
        );
        final iconTurns = Tween<double>(
          begin: 0.0,
          end: 0.5,
        ).animate(controller);

        _animationControllerList.add(controller);
        _animationList.add(animation);
        _iconTurnsList.add(iconTurns);
      }
    });
  }

  quitChallenge() async {
    context.go('/reading-challenge/start/${widget.challengeId}/', extra: {
      "requiredRefresh": true,
    });
  }
}
