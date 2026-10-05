import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../data/learning_repository.dart';
import 'bs_ui.dart';

/// Authors of the member's books by bookId; review items carry no author.
final reviewBookAuthorsProvider = Provider<Map<int, String>>((ref) => {
      for (final book in [
        ...?ref.watch(learningBooksProvider).valueOrNull,
        ...?ref.watch(finishedLearningBooksProvider).valueOrNull,
      ])
        if (book.bookAuthor.trim().isNotEmpty)
          book.bookId: book.bookAuthor.trim(),
    });

/// "수족관 (유래혁)", or just the title when the author is unknown.
String reviewBookLine(ReviewItem item, Map<int, String> authors) {
  final author = item.bookAuthor.trim().isNotEmpty
      ? item.bookAuthor.trim()
      : authors[item.bookId];
  return author == null ? item.bookTitle : '${item.bookTitle} ($author)';
}

final _sectionStyle = Bs.text(18, weight: FontWeight.w600, letterSpacing: 0);

/// 3.1 복습 tab: today's due quizzes, the first one as a highlighted card.
class LearningReviewScreen extends ConsumerStatefulWidget {
  const LearningReviewScreen({super.key});

  @override
  ConsumerState<LearningReviewScreen> createState() =>
      _LearningReviewScreenState();
}

class _LearningReviewScreenState extends ConsumerState<LearningReviewScreen>
    with _ReviewPaging {
  void _open(ReviewItem item) => context.push('/review/quiz/${item.chapterId}');

  @override
  Widget build(BuildContext context) {
    ref.listen(reviewOverviewProvider, (_, next) {
      if (next is AsyncData<ReviewPage> && !next.isLoading) {
        _resetPages();
      }
    });
    final overview = ref.watch(reviewOverviewProvider);
    final authors = ref.watch(reviewBookAuthorsProvider);
    return ColoredBox(
      color: Bs.bg,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const BsTopBar(title: '복습'),
            Expanded(
              child: _ReviewList(
                onRefresh: () => ref.refresh(reviewOverviewProvider.future),
                topPadding: 17,
                children: [
                  _ReviewHeader(
                      onHistory: () => context.push('/review/history')),
                  const SizedBox(height: 6),
                  ...overview.isLoading
                      ? const [_ReviewLoading()]
                      : overview.hasError || !overview.hasValue
                          ? [
                              _ReviewMessage(
                                message: learningErrorMessage(
                                    overview.error ?? StateError('No data')),
                                actionLabel: '다시 불러오기',
                                onAction: () =>
                                    ref.invalidate(reviewOverviewProvider),
                              )
                            ]
                          : _content(overview.requireValue, authors),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _content(ReviewPage page, Map<int, String> authors) {
    final items = [...page.items, ..._moreItems];
    final onlyUnavailable =
        page.totalCount > 0 && page.unavailableCount >= page.totalCount;
    if (items.isEmpty) {
      if (!onlyUnavailable && page.dueCount > 0) {
        return [
          _ReviewMessage(
            message: '퀴즈 목록을 확인하지 못했어요.\n다시 불러와 주세요.',
            actionLabel: '다시 불러오기',
            onAction: () => ref.invalidate(reviewOverviewProvider),
          )
        ];
      }
      return [
        if (page.totalCount == 0)
          _ReviewMessage(
            message: '아직 푼 퀴즈가 없어요.\n내 서재에서 퀴즈를 풀면 이곳에서 복습할 수 있어요.',
            actionLabel: '퀴즈 풀러 가기',
            onAction: () => context.go('/library'),
          )
        else if (onlyUnavailable)
          _ReviewMessage(
            message: '지금 복습할 수 있는 퀴즈가 없어요.\n기존 풀이 기록은 보관돼요.',
            actionLabel: '다른 퀴즈 찾기',
            onAction: () => context.go('/library'),
          )
        else
          _ReviewMessage(
              message: page.reviewedTodayCount > 0
                  ? '오늘 복습할 퀴즈를 모두 풀었어요.'
                  : '오늘 복습할 퀴즈가 없어요.',
              character: BsCharacter.cloud),
      ];
    }
    return [
      _ReviewHero(item: items.first, onOpen: () => _open(items.first)),
      const SizedBox(height: 20),
      for (final (index, item) in items.skip(1).indexed) ...[
        if (index > 0) const _ReviewDivider(),
        _ReviewRow(
          item: item,
          subtitle: reviewBookLine(item, authors),
          label: '${item.question}, ${reviewBookLine(item, authors)}, 복습하기',
          onTap: () => _open(item),
        ),
      ],
      _moreFooter(
          page,
          (cursor) => ref
              .read(learningRepositoryProvider)
              .getReviews(cursor: cursor, dueOnly: true)),
      if (page.unavailableCount > 0 && !onlyUnavailable)
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Text(
              '지금 제공할 수 없는 퀴즈 ${page.unavailableCount}개는 목록에서 제외했어요.\n기존 풀이 기록은 보관돼요.',
              style: Bs.text(13, color: Bs.g3, height: 1.5)),
        ),
    ];
  }
}

/// 3.3 복습한 퀴즈: quizzes reviewed at least once, latest review first.
class LearningReviewHistoryPage extends ConsumerStatefulWidget {
  const LearningReviewHistoryPage({super.key});

  @override
  ConsumerState<LearningReviewHistoryPage> createState() =>
      _LearningReviewHistoryPageState();
}

class _LearningReviewHistoryPageState
    extends ConsumerState<LearningReviewHistoryPage> with _ReviewPaging {
  static final _date = DateFormat('yyyy.MM.dd');

  String _subtitle(ReviewItem item, Map<int, String> authors) {
    final book = reviewBookLine(item, authors);
    final reviewedAt = item.lastReviewedAt;
    return reviewedAt == null
        ? book
        : '$book | ${_date.format(reviewedAt.toLocal())} 복습';
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(reviewedQuizzesProvider, (_, next) {
      if (next is AsyncData<ReviewPage> && !next.isLoading) {
        _resetPages();
      }
    });
    final reviewed = ref.watch(reviewedQuizzesProvider);
    final authors = ref.watch(reviewBookAuthorsProvider);
    return Scaffold(
      backgroundColor: Bs.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const BsTopBar(title: '복습', showBack: true),
            Expanded(
              child: _ReviewList(
                onRefresh: () => ref.refresh(reviewedQuizzesProvider.future),
                topPadding: 26,
                children: [
                  Semantics(
                      header: true,
                      child: Text('복습한 퀴즈', style: _sectionStyle)),
                  const SizedBox(height: 3),
                  ...reviewed.isLoading
                      ? const [_ReviewLoading()]
                      : reviewed.hasError || !reviewed.hasValue
                          ? [
                              _ReviewMessage(
                                message: learningErrorMessage(
                                    reviewed.error ?? StateError('No data')),
                                actionLabel: '다시 불러오기',
                                onAction: () =>
                                    ref.invalidate(reviewedQuizzesProvider),
                              )
                            ]
                          : _content(reviewed.requireValue, authors),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _content(ReviewPage page, Map<int, String> authors) {
    final items = [...page.items, ..._moreItems];
    if (items.isEmpty) {
      return const [
        _ReviewMessage(
            message: '아직 복습한 퀴즈가 없어요.\n복습 탭에서 오늘의 퀴즈를 다시 풀어 보세요.',
            character: BsCharacter.cloud),
      ];
    }
    return [
      for (final (index, item) in items.indexed) ...[
        if (index > 0) const _ReviewDivider(),
        _ReviewRow(
          item: item,
          subtitle: _subtitle(item, authors),
          label: '${item.question}, ${_subtitle(item, authors)}, 다시 풀기',
          onTap: () => context.push('/review/quiz/${item.chapterId}'),
        ),
      ],
      _moreFooter(
          page,
          (cursor) => ref
              .read(learningRepositoryProvider)
              .getReviews(cursor: cursor, reviewedOnly: true)),
    ];
  }
}

/// Pages appended below the first provider page ("load more" on scroll).
mixin _ReviewPaging<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  final _moreItems = <ReviewItem>[];
  ReviewPage? _lastPage;
  bool _loadingMore = false;
  bool _moreFailed = false;
  int _generation = 0;

  void _resetPages() => setState(() {
        _generation++;
        _moreItems.clear();
        _lastPage = null;
        _loadingMore = false;
        _moreFailed = false;
      });

  Future<void> _loadMore(Future<ReviewPage> Function() fetch) async {
    if (_loadingMore) return;
    final generation = _generation;
    setState(() {
      _loadingMore = true;
      _moreFailed = false;
    });
    try {
      final page = await fetch();
      if (!mounted || generation != _generation) return;
      setState(() {
        _moreItems.addAll(page.items);
        _lastPage = page;
      });
    } catch (_) {
      if (mounted && generation == _generation) {
        setState(() => _moreFailed = true);
      }
    } finally {
      if (mounted && generation == _generation) {
        setState(() => _loadingMore = false);
      }
    }
  }

  Widget _moreFooter(
      ReviewPage first, Future<ReviewPage> Function(int? cursor) fetch) {
    final page = _lastPage ?? first;
    if (!page.hasNext) return const SizedBox.shrink();
    void more() => _loadMore(() => fetch(page.nextCursor));
    if (_moreFailed) {
      return Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Center(
          child:
              BsSmallButton(label: '퀴즈 더 불러오기', filled: false, onPressed: more),
        ),
      );
    }
    return _LoadMore(key: ValueKey(page.nextCursor), onShown: more);
  }
}

class _LoadMore extends StatefulWidget {
  const _LoadMore({super.key, required this.onShown});
  final VoidCallback onShown;

  @override
  State<_LoadMore> createState() => _LoadMoreState();
}

class _LoadMoreState extends State<_LoadMore> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onShown();
    });
  }

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator(
                  strokeWidth: 2.4, color: Bs.primary)),
        ),
      );
}

class _ReviewList extends StatelessWidget {
  const _ReviewList(
      {required this.onRefresh,
      required this.topPadding,
      required this.children});
  final Future<ReviewPage> Function() onRefresh;
  final double topPadding;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => RefreshIndicator(
        color: Bs.primary,
        onRefresh: () async {
          try {
            await onRefresh();
          } catch (_) {
            // The list shows the failure with its own retry.
          }
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
              16, topPadding, 16, MediaQuery.paddingOf(context).bottom + 24),
          children: children,
        ),
      );
}

class _ReviewHeader extends StatelessWidget {
  const _ReviewHeader({required this.onHistory});
  final VoidCallback onHistory;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Row(
          children: [
            Expanded(
              child: Semantics(
                  header: true, child: Text('오늘 복습할 퀴즈', style: _sectionStyle)),
            ),
            Semantics(
              button: true,
              label: '복습한 퀴즈',
              excludeSemantics: true,
              onTap: onHistory,
              child: InkWell(
                onTap: onHistory,
                borderRadius: BorderRadius.circular(8),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 44),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, right: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('복습한 퀴즈',
                            style: Bs.text(14, color: Bs.g7, letterSpacing: 0)),
                        const SizedBox(width: 6),
                        const BsIcon('ic_chevron_right',
                            size: 14, color: Bs.g7),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}

class _ReviewHero extends StatelessWidget {
  const _ReviewHero({required this.item, required this.onOpen});
  final ReviewItem item;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.2;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      decoration: BoxDecoration(
          color: Bs.surface, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(item.bookTitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Bs.text(18,
                  weight: FontWeight.w600,
                  color: Bs.g7,
                  height: 1.4,
                  letterSpacing: 0)),
          const SizedBox(height: 3.5),
          Text(item.chapterTitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Bs.text(14, color: Bs.g3, letterSpacing: 0)),
          const SizedBox(height: 16.5),
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
            decoration: BoxDecoration(
                color: Bs.white,
                borderRadius: BorderRadius.circular(Bs.radius)),
            child: Text(item.question,
                maxLines: largeText ? null : 3,
                overflow: largeText ? null : TextOverflow.ellipsis,
                style: Bs.text(16,
                    weight: FontWeight.w500,
                    color: Bs.g6,
                    height: 1.5,
                    letterSpacing: 0)),
          ),
          const SizedBox(height: 16),
          BsPrimaryButton(label: '퀴즈 다시 풀기', onPressed: onOpen),
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow(
      {required this.item,
      required this.subtitle,
      required this.label,
      required this.onTap});
  final ReviewItem item;
  final String subtitle;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        excludeSemantics: true,
        onTap: onTap,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.only(top: 11, bottom: 10),
            child: Row(
              children: [
                BsBookCover(
                    url: item.bookCover, title: item.bookTitle, width: 54),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.question,
                          maxLines:
                              MediaQuery.textScalerOf(context).scale(1) > 1.2
                                  ? 3
                                  : 1,
                          overflow: TextOverflow.ellipsis,
                          style: Bs.text(16,
                              weight: FontWeight.w500, letterSpacing: 0)),
                      const SizedBox(height: 4),
                      Text(subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Bs.text(14, color: Bs.g3, letterSpacing: 0)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _ReviewDivider extends StatelessWidget {
  const _ReviewDivider();

  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, thickness: 1, color: Bs.surface);
}

class _ReviewLoading extends StatelessWidget {
  const _ReviewLoading();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.only(top: 80),
        child: Center(child: CircularProgressIndicator(color: Bs.primary)),
      );
}

class _ReviewMessage extends StatelessWidget {
  const _ReviewMessage(
      {required this.message,
      this.actionLabel,
      this.onAction,
      this.character = BsCharacter.dizzy});
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final BsCharacter character;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 56),
        child: BsEmptyState(
          message: message,
          character: character,
          action: actionLabel == null
              ? null
              : BsSmallButton(label: actionLabel!, onPressed: onAction),
        ),
      );
}
