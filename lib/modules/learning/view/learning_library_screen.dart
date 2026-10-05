import 'package:bookstar/modules/reading_challenge/model/challenge_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/learning_footprint.dart';
import '../data/learning_repository.dart';
import '../data/library_layout.dart';
import 'bs_ui.dart';
import 'library_widgets.dart';

/// Challenge saved from 2.4.2 "퀴즈 풀기"; the library shows the 읽는중 책
/// list from the top so the new book is visible (2.4.3 책 등록_Completed).
final libraryAddedBookProvider = StateProvider<int?>((ref) => null);

/// 2.1 내 서재: summary, 읽는중/완독한 책 chips and the 목록/2열 toggle.
class LearningLibraryScreen extends ConsumerStatefulWidget {
  const LearningLibraryScreen({super.key});

  @override
  ConsumerState<LearningLibraryScreen> createState() =>
      _LearningLibraryScreenState();
}

class _LearningLibraryScreenState extends ConsumerState<LearningLibraryScreen> {
  final _scroll = ScrollController();
  bool _finished = false;

  FutureProvider<List<ChallengeResponse>> get _provider =>
      _finished ? finishedLearningBooksProvider : learningBooksProvider;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    ref.invalidate(learningFootprintProvider);
    ref.invalidate(_provider);
    try {
      await ref.read(_provider.future);
    } catch (_) {
      // The list shows the error with a retry action.
    }
  }

  void _showAdded() {
    setState(() => _finished = false);
    if (_scroll.hasClients) _scroll.jumpTo(0);
    ref.read(libraryAddedBookProvider.notifier).state = null;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int?>(libraryAddedBookProvider, (_, id) {
      if (id != null) _showAdded();
    });
    final books = ref.watch(_provider);
    final layout = ref.watch(libraryLayoutProvider);
    final bottom = MediaQuery.paddingOf(context).bottom;
    return ColoredBox(
      color: Bs.bg,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            BsTopBar(
              title: '내 서재',
              trailing: BsTopBarAction(
                icon: 'ic_add_book',
                tooltip: '책 찾아서 추가하기',
                onPressed: () => context.push('/library/search'),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                color: Bs.primary,
                onRefresh: _refresh,
                child: CustomScrollView(
                  controller: _scroll,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                        child: _header(
                            layout, books.valueOrNull?.isNotEmpty ?? false)),
                    ...books.when(
                      data: (items) => items.isEmpty
                          ? [_fill(_empty(), bottom)]
                          : _books(_newestFirst(items), layout),
                      loading: () => [
                        _fill(
                            const CircularProgressIndicator(color: Bs.primary),
                            bottom)
                      ],
                      error: (error, _) => [
                        _fill(
                            BsEmptyState(
                              message: learningErrorMessage(error),
                              action: BsSecondaryButton(
                                  label: '다시 불러오기',
                                  expand: false,
                                  onPressed: () => ref.invalidate(_provider)),
                            ),
                            bottom)
                      ],
                    ),
                    if (books.valueOrNull?.isNotEmpty ?? false)
                      SliverPadding(
                          padding: EdgeInsets.only(bottom: bottom + 24)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(LibraryLayout layout, bool hasBooks) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 26, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('읽고 떠올린 것이\n하나의 세계로',
                style: Bs.text(18,
                    weight: FontWeight.w600, height: 1.4, letterSpacing: 0)),
            const SizedBox(height: 8),
            const _LibrarySummary(),
            const SizedBox(height: 23),
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 44),
              child: Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      children: [
                        BsChip(
                            label: '읽는중 책',
                            selected: !_finished,
                            onTap: () => setState(() => _finished = false)),
                        BsChip(
                            label: '완독한 책',
                            selected: _finished,
                            onTap: () => setState(() => _finished = true)),
                      ],
                    ),
                  ),
                  if (hasBooks)
                    LibraryToggle(
                      label: layout.label,
                      expanded: layout == LibraryLayout.twoColumns,
                      semanticsLabel:
                          '${layout.label} 보기, ${layout.toggled.label} 보기로 바꾸기',
                      onTap: () =>
                          ref.read(libraryLayoutProvider.notifier).toggle(),
                    ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _fill(Widget child, double bottom) => SliverFillRemaining(
        hasScrollBody: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 4, 16, bottom),
          child: Align(alignment: const Alignment(0, -0.1), child: child),
        ),
      );

  Widget _empty() => BsEmptyState(
      message: _finished
          ? '아직 완독한 책이 없어요\n모든 목차의 퀴즈를 풀면 여기에 모여요'
          : '우측 상단의 검색 탭에서\n읽고 싶은 책을 찾아보세요');

  /// Newest challenge first, so a book added from 2.4.2 appears on top.
  List<ChallengeResponse> _newestFirst(List<ChallengeResponse> items) =>
      [...items]..sort((a, b) => b.challengeId.compareTo(a.challengeId));

  List<Widget> _books(List<ChallengeResponse> items, LibraryLayout layout) {
    if (layout == LibraryLayout.list) {
      return [
        SliverPadding(
          padding: Bs.pagePadding,
          sliver: SliverList.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, thickness: 1, color: Bs.surface),
            itemBuilder: (_, index) {
              final book = items[index];
              return LibraryBookRow(
                key: ValueKey('library-book-${book.challengeId}'),
                title: libraryTitle(book.bookTitle),
                author: book.bookAuthor,
                cover: book.bookImageUrl,
                percent: libraryPercent(book.progressRate),
                semanticsLabel: _label(book),
                onTap: () => _open(book),
              );
            },
          ),
        ),
      ];
    }
    final rows = (items.length + 1) ~/ 2;
    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        sliver: SliverList.separated(
          itemCount: rows,
          separatorBuilder: (_, __) => const SizedBox(height: 31),
          itemBuilder: (_, row) => Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final index in [row * 2, row * 2 + 1]) ...[
                if (index.isOdd) const SizedBox(width: 35),
                Expanded(
                  child: index < items.length
                      ? _cell(items[index])
                      : const SizedBox.shrink(),
                ),
              ],
            ],
          ),
        ),
      ),
    ];
  }

  Widget _cell(ChallengeResponse book) => LibraryBookCell(
        key: ValueKey('library-book-${book.challengeId}'),
        title: libraryTitle(book.bookTitle),
        author: book.bookAuthor,
        cover: book.bookImageUrl,
        percent: libraryPercent(book.progressRate),
        semanticsLabel: _label(book),
        onTap: () => _open(book),
      );

  String _label(ChallengeResponse book) {
    final author = libraryAuthorLabel(book.bookAuthor);
    return '${libraryTitle(book.bookTitle)}, '
        '${author.isEmpty ? '' : '$author, '}'
        '${_finished ? '완독한 책' : '읽는중 책'}, '
        '${libraryPercent(book.progressRate)}% 진행, 목차 열기';
  }

  void _open(ChallengeResponse book) =>
      context.push('/library/${book.challengeId}/chapters');
}

/// "N권 N목차 N개 퀴즈" from the stored learning records.
class _LibrarySummary extends ConsumerWidget {
  const _LibrarySummary();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final footprint = ref.watch(learningFootprintProvider).valueOrNull;
    final number = Bs.text(16, weight: FontWeight.w600);
    final unit = Bs.text(16, weight: FontWeight.w500, color: Bs.g3);
    Widget count(int value, String label) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$value', style: number),
            const SizedBox(width: 2),
            Text(label, style: unit),
          ],
        );
    final books = footprint?.bookCount ?? 0;
    final chapters = footprint?.chapterCount ?? 0;
    final quizzes = footprint?.answeredQuizCount ?? 0;
    return Visibility(
      visible: footprint != null,
      maintainSize: true,
      maintainAnimation: true,
      maintainState: true,
      child: Semantics(
        label: '$books권 $chapters목차 $quizzes개 퀴즈',
        excludeSemantics: true,
        child: Wrap(
          spacing: 9,
          children: [
            count(books, '권'),
            count(chapters, '목차'),
            count(quizzes, '개 퀴즈'),
          ],
        ),
      ),
    );
  }
}
