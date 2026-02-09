import 'package:bookstar/common/components/base_screen.dart';
import 'package:bookstar/common/components/button/cta_button_l1.dart';
import 'package:bookstar/common/theme/style/app_texts.dart';
import 'package:bookstar/gen/assets.gen.dart';
import 'package:bookstar/gen/colors.gen.dart';
import 'package:bookstar/modules/reading_challenge/model/challenge_detail_chapter.dart';
import 'package:bookstar/modules/reading_challenge/model/challenge_detail_chapter_detail.dart';
import 'package:bookstar/modules/reading_challenge/model/choice_result.dart';
import 'package:bookstar/modules/reading_challenge/model/quiz_choice.dart';
import 'package:bookstar/modules/reading_challenge/view/widgets/reading_challenge_complete_dialog.dart';
import 'package:bookstar/modules/reading_challenge/view_model/challenge_quiz_view_model.dart';
import 'package:bookstar/modules/reading_challenge/view_model/challenge_start_view_model.dart';
import 'package:bookstar/modules/reading_challenge/view_model/ongoing_challenge_view_model.dart';
import 'package:bookstar/modules/reading_data/view_model/reading_data_view_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ReadingChallengeQuizScreen extends BaseScreen {
  const ReadingChallengeQuizScreen({
    super.key,
    required this.chapter,
    required this.choiceResults,
    required this.chapterId,
    required this.challengeId,
    this.showAppBar = true,
  });

  final ChallengeDetailChapterDetail chapter;
  final List<ChoiceResult>? choiceResults;
  final int chapterId;
  final int challengeId;
  final bool showAppBar;

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
  bool _isTappedQuestion = false;

  @override
  void dispose() {
    for (final controller in _animationControllerList) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget buildBody(BuildContext context) {
    return widget.choiceResults == null
        ? _buildQuizPage(
            scrollController: scrollController,
            question: widget.chapter.question,
            choices: widget.chapter.choices,
            changeChoiceId: (choiceId) {
              setState(() {
                _selectedChoiceId = choiceId;
              });
            },
            selectedChoiceId: _selectedChoiceId,
          )
        : _buildQuizResultPage(
            scrollController: scrollController,
            question: widget.chapter.question,
            choices: widget.chapter.choices,
            selectedChoiceId: _selectedChoiceId,
            choiceResults: widget.choiceResults!,
            iconTurnList: _iconTurnsList,
            animationList: _animationList,
            isTappedQuestion: _isTappedQuestion,
            onQuestionTap: () {
              setState(() {
                _isTappedQuestion = true;
              });
            },
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
  }

  Widget _buildQuizPage({
    required ScrollController scrollController,
    required String question,
    required List<QuizChoice> choices,
    required Function(int) changeChoiceId,
    required int? selectedChoiceId,
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
                                  style:
                                      AppTexts.b8.copyWith(color: ColorName.w1),
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
    required bool isTappedQuestion,
    required Function(int) onArrowTap,
    required Function() onQuestionTap,
  }) {
    final correctChoiceId = choiceResults
        .firstWhereOrNull((element) => element.isCorrect)
        ?.choiceId;
    final isCorrect = selectedChoiceId == correctChoiceId;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverToBoxAdapter(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 24,
              ),
              isCorrect
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "정답이에요 ✨",
                          style: AppTexts.b1.copyWith(color: ColorName.p1),
                        ),
                        Text(
                          "당신의 깊은 집중력이 빛나는군요",
                          style: AppTexts.b1.copyWith(color: ColorName.w1),
                        )
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "오답이에요 😟",
                          style: AppTexts.b1.copyWith(color: ColorName.r),
                        ),
                        Text(
                          "내일은 꼭 맞힐 수 있을 거예요",
                          style: AppTexts.b1.copyWith(color: ColorName.w1),
                        )
                      ],
                    ),
              SizedBox(
                height: 23,
              ),
              GestureDetector(
                onTap: onQuestionTap,
                child: Container(
                  decoration: BoxDecoration(
                      color: ColorName.dim3,
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Q",
                            style: AppTexts.b8.copyWith(color: ColorName.p1)),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            !isTappedQuestion ? "눌러서 다시 보기" : question,
                            style: AppTexts.b8.copyWith(color: ColorName.g2),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 14,
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
                  return GestureDetector(
                    onTap: () => onArrowTap(index),
                    child: Column(
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
                                  : ColorName.g7,
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
                                  RotationTransition(
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
                                      color: ColorName.w3,
                                    )),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
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
            text: '정답 확인하기',
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
    // 리딩챌린지 목차 상세화면 refresh
    await ref
        .read(challengeStartViewModelProvider(widget.challengeId).notifier)
        .initState(widget.challengeId);
    // 리딩데이터 refresh
    await ref.read(readingDataViewModelProvider.notifier).initState();
    // 리딩챌린지 메인화면 refresh
    await ref.read(ongoingChallengeViewModelProvider.notifier).initState();
  }

  quitChallenge() async {
    final state =
        ref.watch(challengeStartViewModelProvider(widget.challengeId));
    // 모든 chapters의 status가 COMPLETED인지 확인
    final chapters = state.value?.detail.chapters;
    final isAllCompleted = chapters
            ?.every((chapter) => chapter.status == ChapterStatus.COMPLETED) ??
        false;

    if (isAllCompleted) {
      final result = await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => ReadingChallengeCompleteDialog(
                challengeId: widget.challengeId,
              ));

      if (result != null && result && mounted) {
        context.go('/reading-challenge', extra: {
          "requiredRefresh": true,
        });
      }
    } else {
      context.go('/reading-challenge/start/${widget.challengeId}/', extra: {
        "requiredRefresh": true,
      });
    }
  }
}
