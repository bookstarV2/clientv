import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/learning_footprint.dart';
import '../data/learning_repository.dart';
import 'bs_ui.dart';
import 'learning_library_screen.dart';
import 'library_widgets.dart';

/// 2.4.2 검색한 책 상세: 줄거리 (더보기/접기) and 목차. "퀴즈 풀기" saves the
/// book to 내 서재 and returns to the library with it on top (2.4.3); a book
/// that is already saved opens its chapters instead.
class LearningBookDetailScreen extends ConsumerStatefulWidget {
  const LearningBookDetailScreen({super.key, required this.bookId});

  final int bookId;

  @override
  ConsumerState<LearningBookDetailScreen> createState() =>
      _LearningBookDetailScreenState();
}

class _LearningBookDetailScreenState
    extends ConsumerState<LearningBookDetailScreen> {
  bool _expanded = false;
  bool _saving = false;

  Future<void> _start(LearningBookDetail book) async {
    final saved = book.challengeId;
    if (saved != null && saved > 0) {
      context.push('/library/$saved/chapters');
      return;
    }
    setState(() => _saving = true);
    try {
      final id = await ref.read(learningBookRegistrarProvider)(widget.bookId);
      ref.invalidate(learningFootprintProvider);
      ref.read(libraryAddedBookProvider.notifier).state = id;
      if (mounted) context.go('/library');
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(learningErrorMessage(error))));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(learningBookDetailProvider(widget.bookId));
    return LibraryPage(
      body: detail.when(
        data: _content,
        loading: () =>
            const Center(child: CircularProgressIndicator(color: Bs.primary)),
        error: (error, _) => Center(
          child: SingleChildScrollView(
            padding: Bs.pagePadding,
            child: BsEmptyState(
              message: learningErrorMessage(error),
              action: BsSecondaryButton(
                  label: '다시 불러오기',
                  expand: false,
                  onPressed: () => ref
                      .invalidate(learningBookDetailProvider(widget.bookId))),
            ),
          ),
        ),
      ),
    );
  }

  Widget _content(LearningBookDetail book) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Stack(
      children: [
        ListView(
          padding: EdgeInsets.fromLTRB(16, 26, 16, bottom + 15 + 56 + 24),
          children: [
            LibraryBookHeader(
                title: libraryTitle(book.title),
                author: book.author,
                cover: book.bookCover),
            if (book.description.trim().isNotEmpty) ...[
              const SizedBox(height: 22),
              const LibrarySectionTitle('줄거리'),
              const SizedBox(height: 15),
              _Synopsis(
                text: book.description.trim(),
                expanded: _expanded,
                onToggle: () => setState(() => _expanded = !_expanded),
              ),
            ],
            if (book.chapters.isNotEmpty) ...[
              const SizedBox(height: 32),
              const LibrarySectionTitle('목차'),
              const SizedBox(height: 16),
              for (final (index, chapter) in book.chapters.indexed) ...[
                if (index > 0) const SizedBox(height: 6),
                LibraryChapterRow(title: chapter.title),
              ],
            ],
          ],
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Column(
            children: [
              const IgnorePointer(
                child: SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x26FFFFFF), Bs.white],
                      ),
                    ),
                  ),
                ),
              ),
              ColoredBox(
                color: Bs.white,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, bottom + 15),
                  child: BsPrimaryButton(
                    label: '퀴즈 풀기',
                    loading: _saving,
                    onPressed: () => _start(book),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// White 줄거리 card: three lines with "더보기 ∨", the full text with
/// "접기 ∧" once expanded.
class _Synopsis extends StatelessWidget {
  const _Synopsis(
      {required this.text, required this.expanded, required this.onToggle});

  final String text;
  final bool expanded;
  final VoidCallback onToggle;

  static const _maxLines = 3;

  @override
  Widget build(BuildContext context) {
    final style = Bs.text(16,
        weight: FontWeight.w500, color: Bs.g6, height: 1.5, letterSpacing: 0);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 13, 12, 0),
      decoration: BoxDecoration(
          color: Bs.white, borderRadius: BorderRadius.circular(12)),
      child: LayoutBuilder(builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: text, style: style),
          maxLines: _maxLines,
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
        )..layout(maxWidth: constraints.maxWidth);
        final overflows = painter.didExceedMaxLines;
        painter.dispose();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text,
                style: style,
                maxLines: expanded ? null : _maxLines,
                overflow: expanded ? null : TextOverflow.ellipsis),
            if (overflows)
              Semantics(
                container: true,
                button: true,
                label: expanded ? '줄거리 접기' : '줄거리 더보기',
                excludeSemantics: true,
                onTap: onToggle,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onToggle,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 44),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(expanded ? '접기' : '더보기',
                            style: Bs.text(14, color: Bs.g3)),
                        const SizedBox(width: 5),
                        BsIcon(expanded ? 'ic_chevron_up' : 'ic_chevron_down',
                            size: 14, color: Bs.g3),
                      ],
                    ),
                  ),
                ),
              ),
            SizedBox(height: overflows ? 2 : 13),
          ],
        );
      }),
    );
  }
}
