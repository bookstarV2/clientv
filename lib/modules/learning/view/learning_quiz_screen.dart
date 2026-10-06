import 'package:bookstar/modules/reading_challenge/model/challenge_detail_chapter.dart';
import 'package:bookstar/modules/reading_challenge/model/choice_result.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/learning_footprint.dart';
import '../data/learning_repository.dart';
import '../data/reading_graph.dart';
import '../data/reading_map_remote.dart';
import 'bs_ui.dart';
import 'learning_chapters_screen.dart';
import 'learning_report_screen.dart';

/// 2.3 AI 퀴즈 (from 내 서재, [challengeId] set) and 3.2 복습: question →
/// selected → 정답 확인, then the next quiz or the same quiz again.
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
  bool _movingOn = false;
  bool _answered = false;
  String? _error;
  String? _requestId;
  LearningQuizResult? _result;

  bool get _fromLibrary => widget.challengeId != null;

  @override
  void initState() {
    super.initState();
    _quiz = _load();
  }

  @override
  void didUpdateWidget(LearningQuizScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // go_router can reuse this page when it replaces the only page.
    if (oldWidget.chapterId == widget.chapterId &&
        oldWidget.challengeId == widget.challengeId) {
      return;
    }
    _choiceId = null;
    _submitting = false;
    _movingOn = false;
    _answered = false;
    _error = null;
    _requestId = null;
    _result = null;
    _quiz = _load();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<LearningQuizData> _load() async {
    final repository = ref.read(learningRepositoryProvider);
    final chapter = await repository.getQuiz(widget.chapterId);
    final answered = await repository.hasAnswered(chapter.quizId);
    return LearningQuizData(chapter, answered);
  }

  Future<void> _submit(LearningQuizData quiz) async {
    final choiceId = _choiceId;
    final chapterId = widget.chapterId;
    if (_submitting || choiceId == null) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final repository = ref.read(learningRepositoryProvider);
      final LearningQuizResult result;
      if (quiz.isReview || _answered) {
        _requestId ??= LearningRepository.newRequestId();
        result = await repository.submitReview(
            quiz.chapter.quizId, choiceId, _requestId!);
      } else {
        final challengeId = widget.challengeId;
        if (challengeId == null) {
          throw StateError('A first quiz requires a book');
        }
        result = await repository.submitFirstAnswer(
            quiz.chapter.quizId, choiceId, challengeId);
      }
      if (!mounted || chapterId != widget.chapterId) return;
      setState(() {
        _result = result;
        _answered = true;
      });
      ref.invalidate(reviewOverviewProvider);
      ref.invalidate(reviewedQuizzesProvider);
      ref.invalidate(learningBooksProvider);
      ref.invalidate(finishedLearningBooksProvider);
      ref.invalidate(learningFootprintProvider);
      ref.invalidate(readingGraphProvider);
      ref.invalidate(readingMapStateProvider);
      if (widget.challengeId != null) {
        ref.invalidate(learningChaptersProvider(widget.challengeId!));
      }
      _scrollToTop();
    } catch (error) {
      if (mounted && chapterId == widget.chapterId) {
        setState(() => _error = learningErrorMessage(error,
            answerIsRetained: true, quizContext: true));
      }
    } finally {
      if (mounted && chapterId == widget.chapterId) {
        setState(() => _submitting = false);
      }
    }
  }

  void _scrollToTop() => WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) _scrollController.jumpTo(0);
      });

  void _select(int choiceId) {
    if (_submitting || _result != null) return;
    setState(() {
      if (_choiceId != choiceId) _requestId = null;
      _choiceId = choiceId;
      _error = null;
    });
  }

  void _retry() {
    setState(() {
      _result = null;
      _choiceId = null;
      _requestId = null;
      _error = null;
    });
    _scrollToTop();
  }

  Future<void> _next(LearningQuizData quiz) async {
    if (_movingOn) return;
    setState(() => _movingOn = true);
    String? location;
    try {
      location = await _nextLocation(quiz.chapter.quizId);
    } catch (_) {
      // The list the quiz was opened from still offers every other quiz.
    }
    if (!mounted) return;
    setState(() => _movingOn = false);
    if (location == null) {
      _close();
    } else {
      context.pushReplacement(location);
    }
  }

  Future<String?> _nextLocation(int quizId) async {
    final repository = ref.read(learningRepositoryProvider);
    final challengeId = widget.challengeId;
    if (challengeId == null) {
      final due = await repository.getReviews(dueOnly: true);
      final next = due.items.firstWhereOrNull((item) => item.quizId != quizId);
      return next == null ? null : '/review/quiz/${next.chapterId}';
    }
    final chapters = (await repository.getChapters(challengeId)).chapters;
    final index =
        chapters.indexWhere((chapter) => chapter.chapterId == widget.chapterId);
    final next = [
      ...chapters.skip(index + 1),
      ...chapters.take(index < 0 ? 0 : index),
    ].firstWhereOrNull((chapter) =>
        chapter.chapterId != widget.chapterId &&
        chapter.status != ChapterStatus.COMPLETED);
    return next == null ? null : '/library/$challengeId/quiz/${next.chapterId}';
  }

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(
          _fromLibrary ? '/library/${widget.challengeId}/chapters' : '/review');
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: !_submitting,
        child: FutureBuilder<LearningQuizData>(
          future: _quiz,
          builder: (context, snapshot) {
            final loading = snapshot.connectionState != ConnectionState.done;
            final quiz = loading ? null : snapshot.data;
            return Scaffold(
              backgroundColor: Bs.bg,
              body: DecoratedBox(
                decoration: BoxDecoration(
                    gradient: _result == null ? null : _answerGradient),
                child: SafeArea(
                  child: Column(
                    children: [
                      BsTopBar(
                        title: _fromLibrary ? 'AI 퀴즈' : '복습',
                        showBack: true,
                        trailing: BsTopBarAction(
                          icon: 'ic_report',
                          tooltip: '퀴즈 오류 신고',
                          onPressed: quiz == null || _submitting
                              ? null
                              : () => showQuizReportSheet(
                                  context, quiz.chapter.quizId),
                        ),
                      ),
                      if (_result != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                          child: _pointResult(_result!),
                        ),
                      Expanded(
                        child: loading
                            ? const Center(
                                child: CircularProgressIndicator(
                                    color: Bs.primary))
                            : quiz == null
                                ? _loadError(snapshot.error)
                                : _content(quiz),
                      ),
                      if (quiz != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 15),
                          child: _actions(quiz),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );

  Widget _loadError(Object? error) => Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: BsEmptyState(
            message: learningErrorMessage(
                error ?? StateError('Quiz not available'),
                quizContext: true),
            action: BsSmallButton(
              label: '다시 불러오기',
              onPressed: () {
                final next = _load();
                setState(() {
                  _quiz = next;
                });
              },
            ),
          ),
        ),
      );

  Widget _content(LearningQuizData quiz) {
    final result = _result;
    final chapterTitle = quiz.chapter.chapterTitle.trim();
    return ListView(
      key: ValueKey(result == null ? 'question' : 'answer'),
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 26, 16, 24),
      children: [
        BsQuizCard(
          question: quiz.chapter.question,
          options: result == null ? _choices(quiz) : _answers(quiz, result),
        ),
        if (result == null) ...[
          if (chapterTitle.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const SizedBox.square(
                  dimension: 24,
                  child: Center(
                      child: BsIcon('ic_chapter_book', size: 20, color: Bs.g3)),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(chapterTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Bs.text(14, color: Bs.g3, letterSpacing: 0)),
                ),
              ],
            ),
          ],
        ] else ...[
          const SizedBox(height: 24),
          Semantics(
            liveRegion: true,
            label: result.isCorrect ? '정답이에요.' : '아쉬워요. 정답을 확인해 보세요.',
            child: BsExplanationCard(body: _explanation(result)),
          ),
        ],
      ],
    );
  }

  Widget _pointResult(LearningQuizResult result) {
    final earned = result.earnedPoints > 0;
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Bs.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: earned ? Bs.primary : Bs.surface),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(earned ? '퀴즈 포인트 적립 완료' : '복습 완료',
                      style: Bs.text(16, weight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(
                      earned
                          ? '독서 지도 만들기와 선 연결에 사용할 수 있어요.'
                          : '포인트는 퀴즈 첫 풀이에 한 번 적립돼요.',
                      style: Bs.text(13, color: Bs.g3, height: 1.4)),
                ],
              ),
            ),
            if (earned) ...[
              const SizedBox(width: 8),
              Text('+${result.earnedPoints}P',
                  style:
                      Bs.text(22, weight: FontWeight.w700, color: Bs.primary)),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _choices(LearningQuizData quiz) => [
        for (final (index, choice) in quiz.chapter.choices.indexed)
          BsOptionTile(
            text: choice.choiceText,
            state: _choiceId == choice.choiceId
                ? BsOptionState.selected
                : BsOptionState.idle,
            semanticsLabel: '${index + 1}번 ${choice.choiceText}',
            onTap: _submitting ? null : () => _select(choice.choiceId),
          ),
      ];

  List<Widget> _answers(LearningQuizData quiz, LearningQuizResult result) {
    final byId = {
      for (final choice in result.choiceResults) choice.choiceId: choice
    };
    return [
      for (final choice in quiz.chapter.choices)
        _answer(choice.choiceText, byId[choice.choiceId]),
    ];
  }

  Widget _answer(String text, ChoiceResult? result) {
    final correct = result?.isCorrect == true;
    final picked = result?.isSelected == true;
    return BsOptionTile(
      text: text,
      state: correct
          ? BsOptionState.answer
          : picked
              ? BsOptionState.idle
              : BsOptionState.dimmed,
      semanticsLabel: [
        if (correct) '정답',
        if (picked) '내가 고른 답',
        text,
      ].join(', '),
    );
  }

  String _explanation(LearningQuizResult result) {
    final correct =
        result.choiceResults.firstWhereOrNull((choice) => choice.isCorrect);
    final explanation = correct?.explanation.trim() ?? '';
    return explanation.isEmpty ? '이 부분을 책에서 다시 확인해 보세요.' : explanation;
  }

  Widget _actions(LearningQuizData quiz) {
    if (_result == null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!quiz.isReview && !_answered) ...[
            Text('첫 풀이를 완료하면 포인트가 적립돼요.',
                textAlign: TextAlign.center, style: Bs.text(13, color: Bs.g3)),
            const SizedBox(height: 8),
          ],
          if (_error != null) ...[
            Semantics(
              liveRegion: true,
              child: Text(_error!,
                  textAlign: TextAlign.center,
                  style: Bs.text(14, color: quizErrorTextColor, height: 1.5)),
            ),
            const SizedBox(height: 12),
          ],
          BsPrimaryButton(
            label: '정답 확인하기',
            loading: _submitting,
            onPressed: _choiceId == null ? null : () => _submit(quiz),
          ),
        ],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BsPrimaryButton(
          label: _fromLibrary ? '다른 퀴즈 풀기' : '다른 퀴즈 복습하기',
          loading: _movingOn,
          onPressed: () => _next(quiz),
        ),
        const SizedBox(height: 8),
        BsSecondaryButton(
            label: '이 퀴즈 다시 풀기', onPressed: _movingOn ? null : _retry),
      ],
    );
  }
}

const _answerGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  stops: [0, 0.7, 1],
  colors: [Bs.bg, Bs.bg, Bs.gradientEnd],
);
