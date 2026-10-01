import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/footprint_export.dart';
import '../data/learning_access.dart';
import '../data/reading_graph.dart';
import 'bs_ui.dart';
import 'reading_graph_canvas.dart';
import 'reading_map_preview.dart';

/// 4.1 독서 지도 탭: summary + map card that opens the full map (4.2).
class ReadingMapScreen extends ConsumerWidget {
  const ReadingMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => BsScaffold(
        title: '독서 지도',
        body: RefreshIndicator(
          color: Bs.primary,
          onRefresh: () async {
            ref.invalidate(readingGraphProvider);
            try {
              await ref.read(readingGraphProvider.future);
            } catch (_) {}
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 27, 16, 24),
            children: [
              ReadingMapPreview(
                mapHeight: 563,
                onOpen: () => context.push('/map/all'),
              ),
            ],
          ),
        ),
      );
}

/// 4.2 독서 지도 전체보기: the whole map, its books (지도 속 책) and the
/// chapters/quizzes of the selected book (Active / Active-1), plus 4.2.1
/// image sharing.
class ReadingMapAllScreen extends ConsumerStatefulWidget {
  const ReadingMapAllScreen({super.key});

  @override
  ConsumerState<ReadingMapAllScreen> createState() =>
      _ReadingMapAllScreenState();
}

class _ReadingMapAllScreenState extends ConsumerState<ReadingMapAllScreen> {
  final _scroll = ScrollController();
  final _panelKey = GlobalKey();
  final _shareKey = GlobalKey();
  int? _bookId;
  String? _chapterId;
  bool _exporting = false;
  int? _owner;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final owner = ref.watch(learningAccountProvider);
    if (_owner != owner) {
      _owner = owner;
      _bookId = null;
      _chapterId = null;
    }
    final state = ref.watch(readingGraphProvider);
    return BsScaffold(
      showBack: true,
      title: '독서 지도',
      body: state.when(
        skipLoadingOnRefresh: !state.hasError,
        loading: () => const Center(
            child:
                CircularProgressIndicator(strokeWidth: 2.4, color: Bs.primary)),
        error: (_, __) => ReadingMapMessage(
          message: '기록이 사라진 것은 아니에요.\n연결을 확인하고 다시 불러와 주세요.',
          actionLabel: '다시 불러오기',
          onAction: () => ref.invalidate(readingGraphProvider),
        ),
        data: (graph) => graph.nodes.isEmpty
            ? const ReadingMapMessage.empty()
            : _content(graph),
      ),
    );
  }

  Widget _content(ReadingGraph graph) {
    final book = _bookId == null ? null : graph.nodeById('b$_bookId');
    final chapter = book == null ? null : graph.nodeById(_chapterId);
    final books = graph.books;
    return SingleChildScrollView(
      controller: _scroll,
      padding: const EdgeInsets.only(top: 14, bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 4, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text('읽고 떠올린 것이\n하나의 세계로',
                        style: Bs.text(18,
                            weight: FontWeight.w700,
                            height: 1.4,
                            letterSpacing: 0)),
                  ),
                ),
                IconButton(
                  key: _shareKey,
                  tooltip: '독서 지도 이미지로 공유',
                  onPressed: _exporting ? null : () => _share(graph),
                  icon: _exporting
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Bs.primary))
                      : const BsIcon('ic_share', size: 24, color: Bs.g5),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 9, 16, 0),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _count(books.length, '권'),
                _count(graph.chapterCount, '목차'),
                _count(graph.questionCount, '개 퀴즈'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
            child: Container(
              height: 478,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                  color: Bs.white, borderRadius: BorderRadius.circular(18)),
              child: ReadingGraphCanvas(
                graph: graph,
                selectedId: chapter?.id ?? book?.id,
                onSelected: _selectNode,
                zoomable: true,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 32.5, 16, 5),
            child: Text('지도 속 책',
                style: Bs.text(18, weight: FontWeight.w700, height: 1.4)),
          ),
          for (final (index, node) in books.indexed)
            _bookRow(graph, node,
                selected: node.bookId == book?.bookId,
                dimmed: book != null && node.bookId != book.bookId,
                last: index == books.length - 1),
          if (book != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10.5, 16, 0),
              child: _panel(graph, book, chapter),
            ),
        ],
      ),
    );
  }

  Widget _count(int count, String label) => Text.rich(TextSpan(
        style: Bs.text(16, color: Bs.g3, letterSpacing: 0),
        children: [
          TextSpan(
              text: '$count',
              style: const TextStyle(
                  fontWeight: FontWeight.w700, color: Bs.black)),
          const WidgetSpan(child: SizedBox(width: 2)),
          TextSpan(text: label),
        ],
      ));

  Widget _bookRow(ReadingGraph graph, ReadingNode book,
      {required bool selected, required bool dimmed, required bool last}) {
    final color = readingBookColor(graph, book.bookId);
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: () => _toggleBook(book),
        child: Padding(
          padding: Bs.pagePadding,
          child: Container(
            padding: const EdgeInsets.only(top: 10, bottom: 12.5),
            decoration: last
                ? null
                : const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Bs.surface))),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 5.5),
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: dimmed ? color.withValues(alpha: .6) : color,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(book.label,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Bs.text(16,
                              weight: FontWeight.w600,
                              color: dimmed ? Bs.g2 : Bs.g7)),
                      const SizedBox(height: 3.5),
                      Text('풀어본 퀴즈 ${graph.questionCountOf(book.bookId)}개',
                          style: Bs.text(14,
                              color: dimmed ? Bs.g2 : Bs.g3, height: 1.5)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _panel(ReadingGraph graph, ReadingNode book, ReadingNode? chapter) =>
      Container(
        key: _panelKey,
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 20.5, 16, 20),
        decoration: BoxDecoration(
            color: Bs.surface, borderRadius: BorderRadius.circular(18)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: chapter == null
              ? [
                  Text(book.label,
                      style: Bs.text(18,
                          weight: FontWeight.w700, color: Bs.g7, height: 1.4)),
                  const SizedBox(height: 15.5),
                  for (final (index, node)
                      in graph.chaptersOf(book.bookId).indexed) ...[
                    if (index > 0) const SizedBox(height: 12),
                    _chapterTile(node),
                  ],
                ]
              : [
                  Semantics(
                    button: true,
                    onTapHint: '목차 목록으로 돌아가기',
                    child: GestureDetector(
                      onTap: () => setState(() => _chapterId = null),
                      child: Text(book.label,
                          style: Bs.text(14, color: Bs.g3, height: 1.5)),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(chapter.label,
                      style: Bs.text(18,
                          weight: FontWeight.w700, color: Bs.g7, height: 1.4)),
                  const SizedBox(height: 15.5),
                  for (final (index, question)
                      in graph.questionsOf(chapter.id).indexed) ...[
                    if (index > 0) const SizedBox(height: 8),
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 13),
                      decoration: BoxDecoration(
                          color: Bs.white,
                          borderRadius: BorderRadius.circular(Bs.radius)),
                      child: Text(question.label,
                          style: Bs.text(16,
                              color: Bs.g6, height: 1.5, letterSpacing: 0)),
                    ),
                  ],
                  const SizedBox(height: 16),
                  BsPrimaryButton(
                    label: '퀴즈 다시 풀기',
                    onPressed: () =>
                        context.push('/review/quiz/${chapter.chapterId}'),
                  ),
                ],
        ),
      );

  Widget _chapterTile(ReadingNode chapter) => Semantics(
        button: true,
        child: Material(
          color: Bs.white,
          borderRadius: BorderRadius.circular(Bs.radius),
          child: InkWell(
            borderRadius: BorderRadius.circular(Bs.radius),
            onTap: () => _selectNode(chapter),
            child: Container(
              constraints: const BoxConstraints(minHeight: 50),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(chapter.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Bs.text(16, color: Bs.g6)),
            ),
          ),
        ),
      );

  void _selectNode(ReadingNode node) {
    setState(() {
      _bookId = node.bookId;
      _chapterId = switch (node.kind) {
        ReadingNodeKind.book => null,
        ReadingNodeKind.chapter => node.id,
        ReadingNodeKind.question => node.parentId,
      };
    });
    _revealPanel();
  }

  void _toggleBook(ReadingNode book) {
    setState(() {
      if (_bookId != book.bookId) {
        _bookId = book.bookId;
        _chapterId = null;
      } else if (_chapterId != null) {
        _chapterId = null;
      } else {
        _bookId = null;
      }
    });
    if (_bookId != null) _revealPanel();
  }

  /// Scrolls so the selection panel is visible, keeping the book list above
  /// it in view (Figma 4.2 Active / Active-1).
  void _revealPanel() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final panel = _panelKey.currentContext?.findRenderObject();
      if (!mounted || panel == null || !_scroll.hasClients) return;
      final position = _scroll.position;
      final top =
          RenderAbstractViewport.of(panel).getOffsetToReveal(panel, 0).offset;
      final target = min(position.maxScrollExtent, max(0.0, top - 120));
      if (MediaQuery.disableAnimationsOf(context)) {
        position.jumpTo(target);
      } else {
        position.animateTo(target,
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic);
      }
    });
  }

  Future<void> _share(ReadingGraph graph) async {
    final owner = ref.read(learningAccountProvider);
    if (owner == null || _exporting) return;
    final approved = await showBsConfirmDialog(
      context,
      title: '이 지도를 이미지로 공유할까요?',
      message: '책 제목과 기록 수가 이미지에 표시돼요.\n공유 대상은 다음 화면에서 선택할 수 있어요.',
      confirmLabel: '이미지 만들기',
    );
    bool stillOwner() => mounted && ref.read(learningAccountProvider) == owner;
    if (approved != true || !stillOwner()) return;
    setState(() => _exporting = true);
    try {
      final bytes = await renderReadingGraphImage(graph);
      if (!stillOwner()) return;
      final box =
          (_shareKey.currentContext ?? context).findRenderObject() as RenderBox;
      await ref
          .read(footprintExportProvider)
          .share(bytes, box.localToGlobal(Offset.zero) & box.size, stillOwner);
    } catch (_) {
      if (mounted && stillOwner()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미지를 준비하지 못했어요. 다시 시도해 주세요.')),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }
}
