import 'package:bookstar/modules/reading_challenge/model/quiz_choice.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../data/learning_repository.dart';
import '../data/learning_footprint.dart';
import '../data/reading_graph.dart';
import 'learning_chapters_screen.dart';
import 'learning_design.dart';
import 'reading_graph_screen.dart';

class LearningQuizScreen extends ConsumerStatefulWidget {
  const LearningQuizScreen(
      {super.key, required this.chapterId, this.challengeId});
  final int chapterId;
  final int? challengeId;

  @override
  ConsumerState<LearningQuizScreen> createState() => _LearningQuizScreenState();
}

class _LearningQuizScreenState extends ConsumerState<LearningQuizScreen> {
  late Future<LearningQuizData> _quiz;
  final _scrollController = ScrollController();
  int? _choiceId;
  bool _submitting = false;
  String? _error;
  String? _requestId;
  LearningQuizResult? _result;

  @override
  void initState() {
    super.initState();
    _quiz = _load();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<LearningQuizData> _load() async {
    final chapter =
        await ref.read(learningRepositoryProvider).getQuiz(widget.chapterId);
    final answered =
        await ref.read(learningRepositoryProvider).hasAnswered(chapter.quizId);
    return LearningQuizData(chapter, answered);
  }

  Future<void> _submit(LearningQuizData quiz) async {
    if (_submitting || _choiceId == null) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      LearningQuizResult result;
      if (quiz.isReview) {
        _requestId ??= LearningRepository.newRequestId();
        result = await ref
            .read(learningRepositoryProvider)
            .submitReview(quiz.chapter.quizId, _choiceId!, _requestId!);
      } else {
        final challengeId = widget.challengeId;
        if (challengeId == null) {
          throw StateError('A first quiz requires a book');
        }
        result = await ref
            .read(learningRepositoryProvider)
            .submitFirstAnswer(quiz.chapter.quizId, _choiceId!, challengeId);
      }
      if (!mounted) return;
      setState(() => _result = result);
      ref.invalidate(reviewOverviewProvider);
      ref.invalidate(learningBooksProvider);
      ref.invalidate(finishedLearningBooksProvider);
      ref.invalidate(learningFootprintProvider);
      ref.invalidate(readingGraphProvider);
      if (widget.challengeId != null) {
        ref.invalidate(learningChaptersProvider(widget.challengeId!));
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
      });
    } catch (error) {
      if (mounted) {
        setState(() => _error = learningErrorMessage(error,
            answerIsRetained: true, quizContext: true));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: !_submitting,
        child: FutureBuilder<LearningQuizData>(
          future: _quiz,
          builder: (context, snapshot) {
            final quiz = snapshot.data;
            return LearningPage(
              title: _result != null
                  ? '퀴즈 해설'
                  : quiz?.isReview == true
                      ? '다시 떠올리기'
                      : '오늘의 한 문제',
              actions: quiz == null
                  ? null
                  : [
                      IconButton(
                        tooltip: '퀴즈 내용 안내',
                        onPressed: _submitting
                            ? null
                            : () => _showQuizInfo(context, quiz.chapter.quizId),
                        icon: const Icon(Icons.help_outline_rounded),
                      ),
                    ],
              bottom: quiz == null
                  ? null
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_error != null) ...[
                          Semantics(
                              liveRegion: true,
                              child: Text(_error!,
                                  style: const TextStyle(
                                      color: LearningColors.amber,
                                      height: 1.5))),
                          const SizedBox(height: 12),
                        ],
                        SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: _result != null
                                  ? () => context.canPop()
                                      ? context.pop()
                                      : context.go('/quiz')
                                  : _choiceId == null || _submitting
                                      ? null
                                      : () => _submit(quiz),
                              child: _submitting
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white))
                                  : Text(_result != null
                                      ? widget.challengeId == null
                                          ? '복습 목록으로'
                                          : '목차로 돌아가기'
                                      : _choiceId == null
                                          ? '생각한 답을 골라 주세요'
                                          : '답 확인하기'),
                            )),
                        if (_result == null) ...[
                          const SizedBox(height: 10),
                          const Text('기억이 안 나도 괜찮아요. 해설로 다시 짚어봐요.',
                              style: TextStyle(
                                  fontSize: 12, color: LearningColors.muted)),
                        ],
                      ],
                    ),
              child: snapshot.connectionState == ConnectionState.waiting
                  ? const Center(child: CircularProgressIndicator())
                  : snapshot.hasError
                      ? SingleChildScrollView(
                          child: LearningError(
                          message: learningErrorMessage(snapshot.error!,
                              quizContext: true),
                          onRetry: () {
                            final nextQuiz = _load();
                            setState(() {
                              _quiz = nextQuiz;
                            });
                          },
                        ))
                      : quiz == null
                          ? const SizedBox.shrink()
                          : ListView(
                              key: ValueKey(
                                  _result == null ? 'question' : 'result'),
                              controller: _scrollController,
                              padding:
                                  const EdgeInsets.fromLTRB(20, 12, 20, 24),
                              children: _result == null
                                  ? _question(quiz)
                                  : _answer(quiz, _result!),
                            ),
            );
          },
        ),
      );

  List<Widget> _question(LearningQuizData quiz) => [
        LearningLabel(
            quiz.isReview ? '복습 · 기억에서 꺼내 보기' : 'AI 독서 퀴즈 · 한 목차 한 문제'),
        const SizedBox(height: 12),
        Text(quiz.chapter.chapterTitle,
            style: const TextStyle(
                fontSize: 13, height: 1.5, color: LearningColors.muted)),
        const SizedBox(height: 16),
        Text(quiz.chapter.question,
            style: const TextStyle(
                fontSize: 22,
                height: 1.5,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4)),
        const SizedBox(height: 18),
        ...quiz.chapter.choices.mapIndexed((index, choice) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _choice(choice, index),
            )),
      ];

  void _selectChoice(int choiceId) {
    if (_submitting) return;
    setState(() {
      if (_choiceId != choiceId) _requestId = null;
      _choiceId = choiceId;
      _error = null;
    });
  }

  Widget _choice(QuizChoice choice, int index) {
    final selected = _choiceId == choice.choiceId;
    return Semantics(
      button: true,
      selected: selected,
      enabled: !_submitting,
      onTap: _submitting ? null : () => _selectChoice(choice.choiceId),
      label: '${index + 1}번 ${choice.choiceText}',
      excludeSemantics: true,
      child: Material(
        color: selected ? LearningColors.lavender : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
              color: selected ? LearningColors.primary : LearningColors.line,
              width: selected ? 1.5 : 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _submitting ? null : () => _selectChoice(choice.choiceId),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  size: 22,
                  color:
                      selected ? LearningColors.primary : LearningColors.muted),
              const SizedBox(width: 14),
              Expanded(
                  child: Text(choice.choiceText,
                      style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w400,
                          color: LearningColors.ink))),
            ]),
          ),
        ),
      ),
    );
  }

  List<Widget> _answer(LearningQuizData quiz, LearningQuizResult result) {
    final correct =
        result.choiceResults.firstWhereOrNull((choice) => choice.isCorrect);
    final selected =
        result.choiceResults.firstWhereOrNull((choice) => choice.isSelected);
    final color =
        result.isCorrect ? LearningColors.green : LearningColors.amber;
    return [
      Semantics(
          liveRegion: true,
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: result.isCorrect
                      ? LearningColors.greenSoft
                      : LearningColors.amberSoft,
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(
                  result.isCorrect
                      ? Icons.check_rounded
                      : Icons.lightbulb_outline_rounded,
                  color: color,
                  size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Text(result.isCorrect ? '잘 떠올렸어요' : '함께 다시 짚어봐요',
                    style: TextStyle(
                        fontSize: 19,
                        height: 1.4,
                        fontWeight: FontWeight.w700,
                        color: color))),
          ])),
      const SizedBox(height: 16),
      LearningCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          LearningLabel(result.isCorrect ? '내가 고른 정답' : '정답 · 핵심 다시 보기',
              color: LearningColors.green),
          const SizedBox(height: 12),
          Text(correct?.choiceText ?? '정답 정보를 확인할 수 없어요.',
              style: const TextStyle(
                  fontSize: 18, height: 1.5, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Text(
              correct?.explanation.isNotEmpty == true
                  ? correct!.explanation
                  : '이 부분을 책에서 다시 확인해 보세요.',
              style: const TextStyle(
                  fontSize: 16, height: 1.6, color: LearningColors.ink)),
          if (!result.isCorrect && selected != null) ...[
            const SizedBox(height: 12),
            const Divider(),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(bottom: 8),
              title: const Text('내가 고른 답 살펴보기',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              children: [
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text(selected.choiceText, style: learningBodyStyle)),
                if (selected.explanation.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(selected.explanation, style: learningBodyStyle),
                ],
              ],
            ),
          ],
        ]),
      ),
      const SizedBox(height: 16),
      LearningCard(
          color: LearningColors.lavender,
          child: Row(children: [
            const Icon(Icons.event_repeat_rounded,
                color: LearningColors.primary),
            const SizedBox(width: 14),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(
                      result.nextReviewAt == null
                          ? '복습에 저장했어요'
                          : '${DateFormat('M월 d일').format(result.nextReviewAt!)}에 다시 만나요',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 5),
                  const Text('복습 탭에서 언제든 다시 풀 수 있어요.',
                      style: TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: LearningColors.muted)),
                ])),
          ])),
      const SizedBox(height: 18),
      Text(
          quiz.isReview
              ? '다시 떠올린 흔적은 같은 질문의 점에 이어져요.'
              : '이 퀴즈를 푼 흔적이 독서 지도에 남았어요.',
          style: learningBodyStyle),
      TextButton.icon(
          onPressed: () => openReadingMap(context),
          icon: const Icon(Icons.hub_outlined, size: 18),
          label: const Text('쌓인 풀이 흔적 보기')),
      const SizedBox(height: 12),
      TextButton.icon(
        onPressed: () => _showQuizInfo(context, quiz.chapter.quizId),
        icon: const Icon(Icons.flag_outlined, size: 18),
        label: const Text('책의 내용과 다른가요?'),
      ),
    ];
  }

  void _showQuizInfo(BuildContext context, int quizId) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: LearningColors.paper,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
          child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('AI 퀴즈와 함께 읽는 법',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: LearningColors.ink)),
              const SizedBox(height: 14),
              const Text(
                  'AI가 책 정보와 목차를 바탕으로 만든 퀴즈예요.\n책의 원문과 다른 내용이나 해석이 섞일 수 있어요.\n해설이 낯설다면 해당 부분을 책에서 확인해 주세요.',
                  style: learningBodyStyle),
              const SizedBox(height: 22),
              SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonal(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      context.push('/quiz/$quizId/report');
                    },
                    child: const Text('문제 오류 알려주기'),
                  )),
            ]),
      )),
    );
  }
}
