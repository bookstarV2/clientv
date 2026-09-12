import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/footprint_export.dart';
import '../data/learning_access.dart';
import '../data/reading_graph.dart';
import 'learning_design.dart';
import 'reading_graph_canvas.dart';
import 'reading_graph_explorer.dart';

Future<void> openReadingMap(BuildContext context) =>
    Navigator.of(context, rootNavigator: true).push<void>(MaterialPageRoute(
        builder: (_) => Theme(
            data: LearningColors.theme,
            child: Scaffold(
                appBar: AppBar(title: const Text('독서 지도')),
                body: const SafeArea(child: ReadingGraphScreen())))));

class ReadingGraphScreen extends ConsumerStatefulWidget {
  const ReadingGraphScreen({super.key});

  @override
  ConsumerState<ReadingGraphScreen> createState() => _ReadingGraphScreenState();
}

class _ReadingGraphScreenState extends ConsumerState<ReadingGraphScreen> {
  String? _selectedId;
  final _selectionKey = GlobalKey();
  bool _exporting = false;
  bool _exploring = false;
  bool _fullscreen = false;
  ReadingGraph? _shownGraph;
  int? _owner;

  @override
  Widget build(BuildContext context) {
    final owner = ref.watch(learningAccountProvider);
    if (_owner != owner) {
      _owner = owner;
      _selectedId = null;
      _exploring = false;
    }
    final state = ref.watch(readingGraphProvider);
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(readingGraphProvider);
        try {
          await ref.read(readingGraphProvider.future);
        } catch (_) {}
      },
      child: state.when(
        skipLoadingOnRefresh: false,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            const Text('지도를 불러오지 못했어요', style: learningTitleStyle),
            const SizedBox(height: 12),
            const Text(
              '기록이 사라진 것은 아니에요. 연결을 확인하고 다시 불러와 주세요.',
              style: learningBodyStyle,
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => ref.invalidate(readingGraphProvider),
              child: const Text('지도 다시 불러오기'),
            ),
            TextButton(
              onPressed: () => context.go('/library'),
              child: const Text('내 서재 열기'),
            ),
          ],
        ),
        data: (graph) => _content(graph),
      ),
    );
  }

  Widget _content(ReadingGraph graph) {
    if (!identical(_shownGraph, graph)) {
      _shownGraph = graph;
      _exploring = false;
    }
    ReadingNode? selected;
    for (final node in graph.nodes) {
      if (node.id == _selectedId) selected = node;
    }
    final empty = graph.nodes.isEmpty;
    return ListView(
      physics: _exploring
          ? const NeverScrollableScrollPhysics()
          : const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 28),
      children: [
        RepaintBoundary(
          child: ColoredBox(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'MY READING MAP',
                        style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 2.2,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF79817C),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        empty ? '첫 책에서 시작될\n나만의 세계.' : '읽고 떠올린 것들이\n하나의 세계로.',
                        style: const TextStyle(
                          fontSize: 28,
                          height: 1.27,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -1.2,
                          color: Color(0xFF252D29),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (!empty)
                        Wrap(
                          spacing: 18,
                          runSpacing: 8,
                          children: [
                            _count('${graph.books.length}', '책'),
                            _count('${graph.chapterCount}', '목차'),
                            _count('${graph.questionCount}', '풀어본 질문'),
                          ],
                        ),
                    ],
                  ),
                ),
                if (!empty)
                  SizedBox(
                    height: 360,
                    child: ReadingGraphCanvas(
                      graph: graph,
                      selectedId: selected?.id,
                      exploring: _exploring,
                      onFullscreen: _openFullscreen,
                      onExplorationChanged: (value) =>
                          setState(() => _exploring = value),
                      onSelected: (node) =>
                          setState(() => _selectedId = node.id),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 44),
                    child: Center(
                      child: Column(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFCBD9D1),
                              ),
                            ),
                            child: Center(
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF527E72),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            '아직 기록된 점이 없어요',
                            style: TextStyle(color: Color(0xFF69766F)),
                          ),
                        ],
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  child: Text(
                    empty
                        ? '읽은 책을 고르고 한 문제를 풀면\n책과 질문이 연결된 첫 점들이 생겨요.'
                        : '큰 점은 책, 작은 점은 목차와 풀어본 질문.\n선은 같은 책 안에서 이어진 기록이에요.',
                    style: const TextStyle(
                      fontSize: 11,
                      height: 1.65,
                      color: Color(0xFF737D77),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (graph.truncated || graph.unavailableCount > 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    '${graph.truncated ? '최근 불러온 최대 300개 질문을 표시해요. ' : ''}'
                    '${graph.unavailableCount > 0 ? '현재 열 수 없는 질문 ${graph.unavailableCount}개는 표시하지 않았어요.' : ''}',
                    style: learningBodyStyle,
                  ),
                ),
              if (selected != null) ...[
                _selection(selected, graph),
                const SizedBox(height: 16),
              ],
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF293E34),
                  ),
                  onPressed: () =>
                      context.go(empty ? '/library/search' : '/library'),
                  icon: const Icon(Icons.add, size: 20),
                  label: Text(empty ? '첫 책 찾기' : '읽고 흔적 남기기'),
                ),
              ),
              if (!empty) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: _exporting ? null : _share,
                    icon: const Icon(Icons.ios_share_rounded, size: 17),
                    label: Text(_exporting ? '이미지 준비 중…' : '내 독서 지도 공유'),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        '지도 속 책',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (_selectedId != null)
                      TextButton(
                        onPressed: () => setState(() => _selectedId = null),
                        child: const Text('선택 해제'),
                      ),
                  ],
                ),
                ...graph.books.map(
                  (book) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: readingGraphPalette[graph.books.indexOf(book) %
                            readingGraphPalette.length],
                      ),
                    ),
                    title: Text(
                      book.label,
                      style: const TextStyle(fontSize: 14),
                    ),
                    subtitle: Text(
                      '풀어본 질문 ${graph.nodes.where((n) => n.bookId == book.bookId && n.kind == ReadingNodeKind.question).length}개',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: const Icon(Icons.north_west_rounded, size: 17),
                    selected: selected?.bookId == book.bookId,
                    onTap: () => _selectNode(book),
                  ),
                ),
              ],
              const SizedBox(height: 18),
              const Text(
                '현재 앱에 남아 있는 풀이 기록으로 만든 지도예요.\n완독 권수나 지식 습득을 인증하는 지도는 아니에요.',
                style: TextStyle(
                  fontSize: 11,
                  height: 1.6,
                  color: Color(0xFF737D77),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _count(String count, String label) => RichText(
        text: TextSpan(
          style: const TextStyle(
            fontFamily: 'Pretendard',
            color: Color(0xFF35463C),
          ),
          children: [
            TextSpan(
              text: count,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            TextSpan(
              text: '  $label',
              style: const TextStyle(fontSize: 11, color: Color(0xFF737D77)),
            ),
          ],
        ),
      );

  Widget _selection(ReadingNode node, ReadingGraph graph) => Container(
        key: _selectionKey,
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFDCE5DF)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                switch (node.kind) {
                  ReadingNodeKind.book => '책',
                  ReadingNodeKind.chapter => '목차',
                  ReadingNodeKind.question => '풀어본 질문',
                },
                style: const TextStyle(fontSize: 11, color: Color(0xFF527E72))),
            const SizedBox(height: 8),
            Text(
              node.label,
              style: const TextStyle(
                fontSize: 16,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (node.kind != ReadingNodeKind.book) ...[
              const SizedBox(height: 6),
              Text(node.bookTitle, style: learningBodyStyle),
            ],
            if (node.chapterId != null)
              TextButton.icon(
                onPressed: () => context.push('/review/quiz/${node.chapterId}'),
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: const Text('이 목차 다시 열기'),
              ),
            if (node.kind == ReadingNodeKind.book) ...[
              const SizedBox(height: 10),
              ...graph.nodes
                  .where(
                    (n) =>
                        n.bookId == node.bookId &&
                        n.kind == ReadingNodeKind.chapter,
                  )
                  .map(
                    (chapter) => TextButton(
                      onPressed: () => _selectNode(chapter),
                      child: Text(chapter.label),
                    ),
                  ),
            ],
            if (node.kind == ReadingNodeKind.chapter) ...[
              const SizedBox(height: 10),
              ...graph.nodes.where((n) => n.parentId == node.id).map(
                    (question) => TextButton(
                      onPressed: () => _selectNode(question),
                      child: Text(question.label),
                    ),
                  ),
            ],
          ],
        ),
      );

  void _selectNode(ReadingNode node) {
    setState(() {
      _selectedId = node.id;
      _exploring = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = _selectionKey.currentContext;
      if (!mounted || target == null) return;
      Scrollable.ensureVisible(
        target,
        alignment: 0,
        duration: MediaQuery.of(context).disableAnimations
            ? Duration.zero
            : const Duration(milliseconds: 240),
      );
    });
  }

  Future<void> _openFullscreen() async {
    final owner = ref.read(learningAccountProvider);
    if (owner == null || _fullscreen) return;
    setState(() {
      _exploring = false;
      _fullscreen = true;
    });
    final selected = await showDialog<ReadingNode>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Consumer(
        builder: (context, ref, _) {
          ref.listen<int?>(learningAccountProvider, (_, next) {
            if (next != owner && dialogContext.mounted) {
              Navigator.of(dialogContext).pop();
            }
          });
          final currentOwner = ref.watch(learningAccountProvider);
          if (currentOwner != owner) return const SizedBox.shrink();
          final state = ref.watch(readingGraphProvider);
          void close() => Navigator.of(dialogContext).pop();
          return Dialog.fullscreen(
            backgroundColor: Colors.white,
            child: SafeArea(
              child: state.when(
                skipLoadingOnRefresh: false,
                data: (graph) => ReadingGraphExplorer(
                  graph: graph,
                  onClose: close,
                  onOpen: (node) => Navigator.of(dialogContext).pop(node),
                ),
                loading: () => Column(
                  children: [
                    IconButton(
                      tooltip: '지도 탐색 닫기',
                      onPressed: close,
                      icon: const Icon(Icons.close),
                    ),
                    const Expanded(
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ],
                ),
                error: (_, __) => Column(
                  children: [
                    IconButton(
                      tooltip: '지도 탐색 닫기',
                      onPressed: close,
                      icon: const Icon(Icons.close),
                    ),
                    const Expanded(
                      child: Center(child: Text('지도를 다시 불러와 주세요.')),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
    if (!mounted) return;
    setState(() => _fullscreen = false);
    if (selected != null && ref.read(learningAccountProvider) == owner) {
      _selectNode(selected);
    }
  }

  Future<void> _share() async {
    final owner = ref.read(learningAccountProvider);
    final graph = ref.read(readingGraphProvider).valueOrNull;
    if (owner == null || graph == null || _exporting) return;
    final approved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('이 지도를 이미지로 공유할까요?'),
        content: const Text(
          '책 제목과 표시된 기록 수가 이미지에 담겨요. 실제 공유 대상은 다음 화면에서 직접 선택해요.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('이미지 준비'),
          ),
        ],
      ),
    );
    if (approved != true ||
        !mounted ||
        ref.read(learningAccountProvider) != owner) {
      return;
    }
    setState(() => _exporting = true);
    try {
      final bytes = await renderReadingGraphImage(graph);
      if (!mounted || ref.read(learningAccountProvider) != owner) {
        return;
      }
      final box = context.findRenderObject() as RenderBox;
      await ref.read(footprintExportProvider).share(
            bytes,
            box.localToGlobal(Offset.zero) & box.size,
            () => mounted && ref.read(learningAccountProvider) == owner,
          );
    } catch (_) {
      if (mounted && ref.read(learningAccountProvider) == owner) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미지를 준비하지 못했어요. 다시 시도해 주세요.')),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }
}
