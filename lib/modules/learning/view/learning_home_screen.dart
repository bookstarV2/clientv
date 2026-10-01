import 'package:bookstar/modules/reading_challenge/model/challenge_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/learning_repository.dart';
import '../data/reading_graph.dart';
import 'bs_ui.dart';
import 'reading_map_preview.dart';

/// Books shown in the 1.1 carousel; the rest are one tap away in 전체 보기.
const _carouselLimit = 5;

/// 1.1 메인 (AI 퀴즈 tab). `Default`: book carousel, single CTA and the
/// 독서 지도 preview. `Default-1`: the same books before any answered quiz has
/// built the map (bigger cover, no map section). `Empty`: no book saved yet.
class LearningHomeScreen extends ConsumerStatefulWidget {
  const LearningHomeScreen({super.key});

  @override
  ConsumerState<LearningHomeScreen> createState() => _LearningHomeScreenState();
}

class _LearningHomeScreenState extends ConsumerState<LearningHomeScreen> {
  int _page = 0;

  Future<void> _refresh() async {
    ref.invalidate(readingGraphProvider);
    ref.invalidate(learningBooksProvider);
    try {
      await ref.read(learningBooksProvider.future);
    } catch (_) {}
  }

  void _openMap() => context.go('/map');

  @override
  Widget build(BuildContext context) {
    final books = ref.watch(learningBooksProvider);
    final map = ref.watch(readingGraphProvider);
    return ColoredBox(
      color: Bs.bg,
      child: Column(
        children: [
          SafeArea(
            bottom: false,
            child: BsTopBar(
              title: '독서 퀴즈',
              trailing: BsTopBarAction(
                  icon: 'ic_settings',
                  tooltip: '설정',
                  onPressed: () => context.push('/settings')),
            ),
          ),
          Expanded(
            child: books.when(
              loading: () => const Center(
                  child: CircularProgressIndicator(color: Bs.primary)),
              error: (error, _) => _BooksError(
                  message: learningErrorMessage(error),
                  onRetry: () => ref.invalidate(learningBooksProvider)),
              data: (items) {
                final shown = items.take(_carouselLimit).toList();
                final Widget content;
                if (shown.isEmpty) {
                  content = _EmptyHome(onOpenMap: _openMap);
                } else {
                  final page = _page.clamp(0, shown.length - 1);
                  final carousel = _Carousel(
                    books: shown,
                    page: page,
                    onPageChanged: (index) => setState(() => _page = index),
                    onAll: () => context.go('/library'),
                    onStart: () => context
                        .push('/library/${shown[page].challengeId}/chapters'),
                  );
                  content = map.valueOrNull?.nodes.isEmpty == true
                      ? _FirstBookHome(carousel: carousel)
                      : _BookHome(carousel: carousel, onOpenMap: _openMap);
                }
                return RefreshIndicator(
                    color: Bs.primary, onRefresh: _refresh, child: content);
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Current carousel state shared by the Default and Default-1 layouts.
class _Carousel {
  const _Carousel({
    required this.books,
    required this.page,
    required this.onPageChanged,
    required this.onAll,
    required this.onStart,
  });

  final List<ChallengeResponse> books;
  final int page;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onAll;
  final VoidCallback onStart;

  ChallengeResponse get book => books[page];

  Widget dots() => books.length < 2
      ? const SizedBox(height: 8)
      : BsPageDots(count: books.length, index: page);

  Widget covers(double width) => _CoverPager(
      books: books, page: page, width: width, onPageChanged: onPageChanged);

  Widget cta() => Padding(
        padding: Bs.pagePadding,
        child: BsPrimaryButton(label: '내 책으로 퀴즈 풀기', onPressed: onStart),
      );
}

/// 1.1 메인_Default.
class _BookHome extends StatelessWidget {
  const _BookHome({required this.carousel, required this.onOpenMap});

  final _Carousel carousel;
  final VoidCallback onOpenMap;

  @override
  Widget build(BuildContext context) => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(
            top: 26.5, bottom: MediaQuery.paddingOf(context).bottom + 24),
        children: [
          _BookHeader(book: carousel.book, onAll: carousel.onAll),
          const SizedBox(height: 11.5),
          carousel.covers(138),
          const SizedBox(height: 22),
          Center(child: carousel.dots()),
          const SizedBox(height: 33),
          carousel.cta(),
          const SizedBox(height: 43),
          Padding(
            padding: Bs.pagePadding,
            child: ReadingMapPreview(mapHeight: 563, onOpen: onOpenMap),
          ),
        ],
      );
}

/// 1.1 메인_Default-1: books but no reading-map data yet.
class _FirstBookHome extends StatelessWidget {
  const _FirstBookHome({required this.carousel});

  final _Carousel carousel;

  @override
  Widget build(BuildContext context) => _FillViewport(
        bottom: 36,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 26.5),
            _BookHeader(book: carousel.book, onAll: carousel.onAll),
            const SizedBox(height: 16.5),
            Padding(padding: Bs.pagePadding, child: carousel.dots()),
            const Spacer(flex: 70),
            carousel.covers(163),
            const Spacer(flex: 88),
            carousel.cta(),
          ],
        ),
      );
}

/// 1.1 메인_Empty: nothing saved yet, the CTA starts a book search.
class _EmptyHome extends StatelessWidget {
  const _EmptyHome({required this.onOpenMap});

  final VoidCallback onOpenMap;

  @override
  Widget build(BuildContext context) => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
            16, 26.5, 16, MediaQuery.paddingOf(context).bottom + 24),
        children: [
          Text('읽고싶은 책이 있나요?',
              style: Bs.text(20, weight: FontWeight.w700, letterSpacing: 0)),
          const SizedBox(height: 8),
          Text('읽고 싶은 책을 찾고 목차를 골라,\nAI 퀴즈를 풀어 보세요.',
              style: Bs.text(14, color: Bs.g3, height: 1.5, letterSpacing: 0)),
          const SizedBox(height: 23.5),
          const Center(child: BsCharacterImage(BsCharacter.books, width: 112)),
          const SizedBox(height: 21.5),
          BsPrimaryButton(
              label: '내 책으로 퀴즈 풀기',
              onPressed: () => context.push('/library/search')),
          const SizedBox(height: 102),
          ReadingMapPreview(mapHeight: 563, onOpen: onOpenMap),
        ],
      );
}

/// Title, "`author` 저자" and the 전체 보기 link of the visible book.
class _BookHeader extends StatelessWidget {
  const _BookHeader({required this.book, required this.onAll});

  final ChallengeResponse book;
  final VoidCallback onAll;

  @override
  Widget build(BuildContext context) => Padding(
        padding: Bs.pagePadding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(book.bookTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Bs.text(20, weight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(book.bookAuthor.isEmpty ? '' : '${book.bookAuthor} 저자',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Bs.text(14, color: Bs.g3, letterSpacing: 0)),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Semantics(
              button: true,
              label: '전체 보기',
              excludeSemantics: true,
              child: InkWell(
                onTap: onAll,
                borderRadius: BorderRadius.circular(8),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 44),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, right: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('전체 보기', style: Bs.text(14, color: Bs.g7)),
                        const SizedBox(width: 9),
                        const Padding(
                          padding: EdgeInsets.only(top: 2.5),
                          child: SizedBox(
                            width: 9,
                            height: 15.5,
                            child: BsIcon('ic_chevron_right',
                                size: 15.5, color: Bs.g7),
                          ),
                        ),
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

/// Swipeable covers. Each layout owns its controller, starting from the page
/// shown before a Default ↔ Default-1 switch.
class _CoverPager extends StatefulWidget {
  const _CoverPager(
      {required this.books,
      required this.page,
      required this.width,
      required this.onPageChanged});

  final List<ChallengeResponse> books;
  final int page;
  final double width;
  final ValueChanged<int> onPageChanged;

  @override
  State<_CoverPager> createState() => _CoverPagerState();
}

class _CoverPagerState extends State<_CoverPager> {
  late final _controller = PageController(initialPage: widget.page);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        height: widget.width * 1.43,
        child: PageView.builder(
          controller: _controller,
          itemCount: widget.books.length,
          onPageChanged: widget.onPageChanged,
          itemBuilder: (_, index) =>
              Center(child: _Cover(widget.books[index], width: widget.width)),
        ),
      );
}

/// Book cover framed by the 1pt W3 outline of the design.
class _Cover extends StatelessWidget {
  const _Cover(this.book, {required this.width});

  final ChallengeResponse book;
  final double width;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          border: Border.all(color: Bs.surface),
          borderRadius: BorderRadius.circular(2),
        ),
        child: BsBookCover(
            url: book.bookImageUrl,
            title: book.bookTitle,
            width: width,
            height: width * 1.43),
      );
}

/// Fills the space above the tab bar and scrolls when it does not fit
/// (small phones, large text).
class _FillViewport extends StatelessWidget {
  const _FillViewport({required this.child, required this.bottom});

  final Widget child;
  final double bottom;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(
              bottom: MediaQuery.paddingOf(context).bottom + bottom),
          child: ConstrainedBox(
            constraints: BoxConstraints(
                minHeight: (constraints.maxHeight -
                        MediaQuery.paddingOf(context).bottom -
                        bottom)
                    .clamp(0, double.infinity)),
            child: IntrinsicHeight(child: child),
          ),
        ),
      );
}

class _BooksError extends StatelessWidget {
  const _BooksError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
              16, 24, 16, MediaQuery.paddingOf(context).bottom + 24),
          child: BsEmptyState(
            message: message,
            action: BsPrimaryButton(label: '다시 불러오기', onPressed: onRetry),
          ),
        ),
      );
}
