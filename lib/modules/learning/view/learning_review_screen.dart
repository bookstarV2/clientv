import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../data/learning_repository.dart';
import 'learning_design.dart';

class LearningReviewHistoryPage extends StatelessWidget {
  const LearningReviewHistoryPage({super.key});

  @override
  Widget build(BuildContext context) => const LearningPage(
        title: '이전에 푼 문제',
        child: LearningReviewScreen(allQuizzes: true),
      );
}

class LearningReviewScreen extends ConsumerStatefulWidget {
  const LearningReviewScreen({super.key, this.allQuizzes = false});

  /// History is a separate destination, not a competing tab on daily review.
  final bool allQuizzes;

  @override
  ConsumerState<LearningReviewScreen> createState() =>
      _LearningReviewScreenState();
}

class _LearningReviewScreenState extends ConsumerState<LearningReviewScreen> {
  bool get _dueOnly => !widget.allQuizzes;
  bool _loadingMore = false;
  late Future<ReviewPage> _page;
  List<ReviewItem> _extra = [];
  ReviewPage? _lastPage;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _page = ref.read(learningRepositoryProvider).getReviews(dueOnly: _dueOnly);
  }

  Future<void> _refresh() async {
    _generation++;
    setState(() {
      _extra = [];
      _lastPage = null;
      _loadingMore = false;
      _page =
          ref.read(learningRepositoryProvider).getReviews(dueOnly: _dueOnly);
    });
    try {
      await _page;
    } catch (_) {
      // FutureBuilder owns the visible failure and retry state.
    }
  }

  Future<void> _more(ReviewPage page) async {
    if (_loadingMore || !page.hasNext) return;
    final generation = _generation;
    setState(() => _loadingMore = true);
    try {
      final result = await ref
          .read(learningRepositoryProvider)
          .getReviews(cursor: page.nextCursor, dueOnly: _dueOnly);
      if (!mounted || generation != _generation) return;
      setState(() {
        _extra.addAll(result.items);
        _lastPage = result;
      });
    } catch (error) {
      if (mounted && generation == _generation) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(learningErrorMessage(error))));
      }
    } finally {
      if (mounted && generation == _generation) {
        setState(() => _loadingMore = false);
      }
    }
  }

  Future<void> _openHistory() async {
    await context.push('/review/history');
    if (mounted) await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(reviewOverviewProvider, (_, next) {
      if (next is AsyncData<ReviewPage> && !next.isLoading) _refresh();
    });
    return RefreshIndicator(
      color: ReviewColors.ink,
      onRefresh: _refresh,
      child: FutureBuilder<ReviewPage>(
        future: _page,
        builder: (context, snapshot) {
          // Never leave retained data actionable during refresh.
          final ready = snapshot.connectionState == ConnectionState.done &&
              !snapshot.hasError;
          final data = ready ? snapshot.data : null;
          final onlyUnavailable = data != null &&
              data.totalCount > 0 &&
              data.unavailableCount >= data.totalCount;
          final items =
              data == null ? <ReviewItem>[] : [...data.items, ..._extra];
          final rows = _dueOnly ? items.skip(1) : items;
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              if (snapshot.connectionState != ConnectionState.done)
                const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                        child:
                            CircularProgressIndicator(color: ReviewColors.ink)))
              else if (snapshot.hasError)
                LearningError(onRetry: _refresh)
              else if (data != null) ...[
                if (items.isEmpty)
                  // A positive count with no items is not a completion state.
                  if (!onlyUnavailable &&
                      data.totalCount > 0 &&
                      (!_dueOnly || data.dueCount > 0))
                    LearningError(
                        onRetry: _refresh,
                        message: '퀴즈 목록을 확인하지 못했어요.\n다시 불러와 주세요.')
                  else
                    _empty(data, onlyUnavailable)
                else ...[
                  if (_dueOnly) ...[
                    _focusCard(items.first),
                    const SizedBox(height: 12),
                    const Text('한 번에 다 풀지 않아도 괜찮아요.',
                        style: TextStyle(
                            fontSize: 13,
                            height: 1.5,
                            color: LearningColors.muted)),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: _openHistory,
                        style: TextButton.styleFrom(
                            foregroundColor: ReviewColors.ink),
                        icon: const Icon(Icons.history_rounded, size: 18),
                        label: const Text('이전에 푼 문제 모두 보기'),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ] else ...[
                    const Text('복습 시점과 관계없이,\n내가 풀었던 문제를 다시 볼 수 있어요.',
                        style: learningBodyStyle),
                    const SizedBox(height: 16),
                  ],
                  if (data.reviewedTodayCount > 0) ...[
                    Text('오늘 ${data.reviewedTodayCount}개를 다시 풀었어요',
                        style: const TextStyle(
                            fontSize: 13,
                            height: 1.5,
                            color: ReviewColors.ink)),
                    const SizedBox(height: 16),
                  ],
                  if (_dueOnly && rows.isNotEmpty) ...[
                    const Text('다른 문제 고르기',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                  ],
                  ...rows.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _reviewCard(item))),
                  if ((_lastPage ?? data).hasNext)
                    OutlinedButton(
                        style: OutlinedButton.styleFrom(
                            foregroundColor: ReviewColors.ink),
                        onPressed: _loadingMore
                            ? null
                            : () => _more(_lastPage ?? data),
                        child: Text(_loadingMore ? '불러오는 중…' : '퀴즈 더 보기')),
                ],
                if (data.unavailableCount > 0 && !onlyUnavailable) ...[
                  const SizedBox(height: 20),
                  Text(
                      '지금 제공할 수 없는 퀴즈 ${data.unavailableCount}개는 목록에서 제외했어요.\n기존 풀이 기록은 보관돼요.',
                      style: learningBodyStyle),
                ],
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _openReview(ReviewItem item) async {
    await context.push('/review/quiz/${item.chapterId}');
    if (mounted) await _refresh();
  }

  String _schedule(ReviewItem item) => item.due
      ? '지금 떠올려 볼 시간'
      : '${DateFormat('M월 d일 HH:mm').format(item.nextReviewAt.toLocal())} 예정';

  String _label(ReviewItem item) =>
      '${item.bookTitle}, ${item.chapterTitle}, ${item.question}, ${_schedule(item)}, 복습하기';

  Widget _focusCard(ReviewItem item) => LearningCard(
        color: ReviewColors.ink,
        onTap: () => _openReview(item),
        label: _label(item),
        excludeChildSemantics: true,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('한 문제부터 가볍게',
              style: TextStyle(
                  fontSize: 12, height: 1.5, color: ReviewColors.context)),
          const SizedBox(height: 12),
          Text(item.question,
              maxLines:
                  MediaQuery.textScalerOf(context).scale(1) > 1.2 ? null : 3,
              overflow: MediaQuery.textScalerOf(context).scale(1) > 1.2
                  ? null
                  : TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 21,
                  height: 1.4,
                  letterSpacing: -.3,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
          const SizedBox(height: 20),
          Row(children: [
            BookCover(url: item.bookCover, title: item.bookTitle, width: 32),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(item.bookTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                  const SizedBox(height: 2),
                  Text(item.chapterTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12,
                          height: 1.5,
                          color: ReviewColors.context)),
                ])),
          ]),
          const SizedBox(height: 20),
          // One accessible action for the card; no duplicate nested button.
          Container(
            constraints: const BoxConstraints(minHeight: 52),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
                color: ReviewColors.action,
                borderRadius: BorderRadius.circular(10)),
            child: const Row(children: [
              Expanded(
                  child: Text('이 문제 다시 풀기',
                      style: TextStyle(
                          fontSize: 15,
                          height: 1.4,
                          fontWeight: FontWeight.w700,
                          color: ReviewColors.ink))),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward_rounded,
                  size: 20, color: ReviewColors.ink),
            ]),
          ),
        ]),
      );

  Widget _reviewCard(ReviewItem item) => LearningCard(
        flat: true,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        onTap: () => _openReview(item),
        label: _label(item),
        excludeChildSemantics: true,
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          BookCover(url: item.bookCover, title: item.bookTitle, width: 32),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(item.question,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text('${item.bookTitle} · ${item.chapterTitle}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color: LearningColors.muted)),
                const SizedBox(height: 6),
                Text(_schedule(item),
                    style: TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color: item.due
                            ? ReviewColors.ink
                            : LearningColors.muted)),
              ])),
          const SizedBox(width: 10),
          const Padding(
              padding: EdgeInsets.only(top: 3),
              child: Icon(Icons.chevron_right_rounded,
                  size: 20, color: LearningColors.muted)),
        ]),
      );

  Widget _empty(ReviewPage data, bool onlyUnavailable) {
    final first = data.totalCount == 0;
    final title = first
        ? '첫 퀴즈가 복습의 시작이에요'
        : onlyUnavailable
            ? '지금 다시 풀 수 있는 문제가 없어요'
            : data.reviewedTodayCount > 0
                ? '오늘 ${data.reviewedTodayCount}개를 다시 풀었어요'
                : '지금 예정된 복습은 없어요';
    return LearningCard(
      color: ReviewColors.soft,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(first ? Icons.auto_stories_outlined : Icons.history_rounded,
            size: 30, color: ReviewColors.ink),
        const SizedBox(height: 24),
        Text(title,
            style: const TextStyle(
                fontSize: 24,
                height: 1.35,
                fontWeight: FontWeight.w700,
                color: ReviewColors.ink,
                letterSpacing: -.4)),
        const SizedBox(height: 12),
        Text(
            first
                ? '서재에서 한 문제를 풀면\n다시 볼 퀴즈가 이곳에 쌓여요.'
                : onlyUnavailable
                    ? '기존 ${data.totalCount}개 풀이 기록은 보관돼요.\n내 서재에서 다른 퀴즈를 만나보세요.'
                    : '${data.reviewedTodayCount > 0 ? '지금 예정된 복습은 없어요.\n' : ''}이전에 푼 문제는 언제든 다시 볼 수 있어요.',
            style: learningBodyStyle),
        const SizedBox(height: 24),
        SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: ReviewColors.ink,
                  foregroundColor: Colors.white),
              onPressed: () {
                if (first || onlyUnavailable) {
                  context.go('/library');
                } else {
                  _openHistory();
                }
              },
              child: Text(first
                  ? '내 서재에서 시작하기'
                  : onlyUnavailable
                      ? '다른 퀴즈 찾기'
                      : '이전에 푼 문제 모두 보기'),
            )),
      ]),
    );
  }
}

/// Focused activity colors, not correct-answer or completion indicators.
class ReviewColors {
  ReviewColors._();
  static const ink = Color(0xFF173D35);
  static const action = Color(0xFFDCEFAD);
  static const context = Color(0xFFC8DCD3);
  static const soft = Color(0xFFE8EFE8);
}
