import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/footprint_export.dart';
import '../data/learning_access.dart';
import '../data/reading_graph.dart';
import '../data/reading_map_remote.dart';
import '../data/learning_repository.dart';
import 'bs_ui.dart';
import 'reading_graph_canvas.dart';
import 'reading_map_preview.dart';

/// 4.1 독서 지도 탭: summary + map card that opens the full map (4.2).
class ReadingMapScreen extends ConsumerWidget {
  const ReadingMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => BsScaffold(
        title: '독서 지도',
        trailing: BsTopBarAction(
          icon: 'ic_settings',
          tooltip: '설정',
          onPressed: () => context.push('/settings'),
        ),
        body: RefreshIndicator(
          color: Bs.primary,
          onRefresh: () async {
            ref.invalidate(readingGraphProvider);
            ref.invalidate(readingMapStateProvider);
            try {
              await Future.wait([
                ref.read(readingGraphProvider.future),
                ref.read(readingMapStateProvider.future),
              ]);
            } catch (_) {}
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 27, 16, 24),
            children: [
              const _ReadingMapCostCard(),
              const SizedBox(height: 20),
              ReadingMapPreview(
                mapHeight: 460,
                onOpen: () => context.push('/map/all'),
              ),
            ],
          ),
        ),
      );
}

class _ReadingMapCostCard extends ConsumerWidget {
  const _ReadingMapCostCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(readingMapStateProvider);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Bs.white, borderRadius: BorderRadius.circular(18)),
      child: state.when(
        skipLoadingOnRefresh: true,
        loading: () => Text('포인트를 불러오고 있어요', style: Bs.text(14, color: Bs.g3)),
        error: (_, __) => BsSecondaryButton(
          label: '포인트 다시 불러오기',
          onPressed: () => ref.invalidate(readingMapStateProvider),
        ),
        data: (map) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('내 포인트 ${map.balance}P',
                style: Bs.text(18, weight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('지도 만들기 ${map.createCost}P · 선 다시 연결하기 ${map.refreshCost}P',
                style: Bs.text(14, color: Bs.g5)),
            const SizedBox(height: 12),
            BsPrimaryButton(
              label: map.version == 0 ? '지도 만들기' : '선 다시 연결하기',
              height: 44,
              onPressed: () => context.push('/map/all'),
            ),
          ],
        ),
      ),
    );
  }
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
  String? _selectedNodeId;
  bool _exporting = false;
  bool _requesting = false;
  String? _mapError;
  Timer? _pollTimer;
  int? _owner;

  @override
  void dispose() {
    _pollTimer?.cancel();
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
      _selectedNodeId = null;
    }
    final state = ref.watch(readingGraphProvider);
    final mapState = ref.watch(readingMapStateProvider);
    ref.listen(readingMapStateProvider, (_, next) {
      if (next.valueOrNull?.isWorking == true) {
        _pollTimer ??= Timer.periodic(const Duration(seconds: 3), (_) {
          if (mounted) ref.invalidate(readingMapStateProvider);
        });
      } else if (next.hasValue) {
        _pollTimer?.cancel();
        _pollTimer = null;
      }
    });
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
        data: (graph) => _content(graph, mapState.valueOrNull,
            mapLoading: mapState.isLoading, mapFailed: mapState.hasError),
      ),
    );
  }

  Widget _content(ReadingGraph graph, ReadingMapState? mapState,
      {required bool mapLoading, required bool mapFailed}) {
    final book = _bookId == null ? null : graph.nodeById('b$_bookId');
    final chapter = book == null ? null : graph.nodeById(_chapterId);
    final selectedNode = graph.nodeById(_selectedNodeId);
    final links = mapState?.links ?? const <ReadingMapLink>[];
    final visibleLinks = selectedNode == null
        ? links
        : links
            .where((link) => _linkTouchesNode(graph, link, selectedNode))
            .toList();
    final books = graph.books;
    return SingleChildScrollView(
      controller: _scroll,
      padding: EdgeInsets.only(
          top: 14, bottom: 28 + MediaQuery.paddingOf(context).bottom),
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
                if (graph.nodes.isNotEmpty)
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
          _mapControls(mapState, loading: mapLoading, failed: mapFailed),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
            child: Container(
              height: 478,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                  color: Bs.white, borderRadius: BorderRadius.circular(18)),
              child: graph.nodes.isEmpty
                  ? const ReadingMapMessage.empty()
                  : Stack(
                      children: [
                        ReadingGraphCanvas(
                          graph: graph,
                          links: links,
                          selectedId:
                              selectedNode?.id ?? chapter?.id ?? book?.id,
                          onSelected: (node) =>
                              _selectNode(node, fromMap: true),
                          zoomable: true,
                        ),
                        if (selectedNode != null)
                          Positioned(
                            left: 12,
                            right: 12,
                            bottom: 12,
                            child: IgnorePointer(
                                child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 9),
                              decoration: BoxDecoration(
                                color: Bs.white.withValues(alpha: .94),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(selectedNode.label,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          Bs.text(13, weight: FontWeight.w600)),
                                  Text('같은 점을 다시 누르면 상세 기록으로 이동해요',
                                      style: Bs.text(11, color: Bs.g3)),
                                ],
                              ),
                            )),
                          ),
                      ],
                    ),
            ),
          ),
          if (mapState != null && links.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 10),
              child: Text(selectedNode == null ? '이어진 생각' : '선택한 생각의 연결',
                  style: Bs.text(18, weight: FontWeight.w700)),
            ),
            if (visibleLinks.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('이 생각과 연결된 퀴즈는 아직 없어요.',
                    style: Bs.text(14, color: Bs.g3)),
              ),
            for (final link in visibleLinks) _connectionCard(graph, link),
          ],
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

  Widget _mapControls(ReadingMapState? state,
      {required bool loading, required bool failed}) {
    if (state == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
        child: failed
            ? BsSecondaryButton(
                label: '포인트 다시 불러오기',
                onPressed: () => ref.invalidate(readingMapStateProvider))
            : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    final creating = state.version == 0;
    final cost = creating ? state.createCost : state.refreshCost;
    final canRequest = !state.isWorking &&
        !_requesting &&
        state.balance >= cost &&
        (creating ? state.answeredQuizCount >= 2 : state.hasNewQuizzes);
    final label = creating ? '지도 만들기 · ${cost}P' : '지도 갱신하기 · ${cost}P';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Bs.white, borderRadius: BorderRadius.circular(18)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('내 포인트 ${state.balance}P',
                style: Bs.text(16, weight: FontWeight.w700)),
            const SizedBox(height: 5),
            Text(_mapHint(state, cost),
                style: Bs.text(13, color: Bs.g3, height: 1.5)),
            if (_mapError != null) ...[
              const SizedBox(height: 8),
              Text(_mapError!, style: Bs.text(13, color: Bs.primary)),
            ],
            const SizedBox(height: 14),
            BsPrimaryButton(
              label: state.isWorking ? '생각을 연결하고 있어요' : label,
              loading: _requesting || (loading && state.isWorking),
              onPressed: canRequest ? () => _requestMap(state) : null,
            ),
          ],
        ),
      ),
    );
  }

  String _mapHint(ReadingMapState state, int cost) {
    if (state.isWorking) return '앱을 나가도 작업은 계속돼요. 완료되면 지도가 갱신됩니다.';
    if (state.status == 'FAILED') return '작업이 실패해 포인트를 돌려드렸어요. 다시 시도할 수 있어요.';
    if (state.status == 'NO_LINK') {
      return '이번 기록에서 확인할 수 있는 연결이 없어 포인트를 돌려드렸어요.';
    }
    if (state.version == 0 && state.answeredQuizCount < 2) {
      return '퀴즈를 2개 이상 풀면 생각 연결을 만들 수 있어요.';
    }
    if (state.version > 0 && !state.hasNewQuizzes) {
      return '새 퀴즈를 풀면 지도를 갱신할 수 있어요.';
    }
    if (state.balance < cost) return '포인트가 부족해요. 퀴즈를 풀어 모아 보세요.';
    return '최근 최대 40개 퀴즈를 분석해요. 실패하거나 연결이 없으면 돌려드려요.';
  }

  Future<void> _requestMap(ReadingMapState state) async {
    final creating = state.version == 0;
    final cost = creating ? state.createCost : state.refreshCost;
    final approved = await showBsConfirmDialog(
      context,
      title: creating ? '독서지도를 만들까요?' : '독서지도를 갱신할까요?',
      message: '${cost}P를 사용해 푼 퀴즈의 생각을 연결해요.\n실패하거나 연결이 없으면 포인트를 돌려드려요.',
      confirmLabel: creating ? '지도 만들기' : '지도 갱신하기',
    );
    if (approved != true || !mounted) return;
    setState(() {
      _requesting = true;
      _mapError = null;
    });
    try {
      await ref.read(readingMapRemoteProvider).request(
          LearningRepository.newRequestId(), creating ? 'CREATE' : 'REFRESH');
      ref.invalidate(readingMapStateProvider);
    } catch (_) {
      if (mounted) {
        ref.invalidate(readingMapStateProvider);
        setState(() => _mapError = '요청 상태를 확인하고 있어요. 잠시 후 다시 확인해 주세요.');
      }
    } finally {
      if (mounted) setState(() => _requesting = false);
    }
  }

  Widget _connectionCard(ReadingGraph graph, ReadingMapLink link) {
    final first = graph.nodeById('q${link.quizAId}');
    final second = graph.nodeById('q${link.quizBId}');
    if (first == null || second == null) return const SizedBox.shrink();
    final title = switch (link.type) {
      'SAME_CONCEPT' => '같은 개념',
      'COMPLEMENTS' => '서로 보완하는 생각',
      'CONTRASTS' => '다른 관점',
      'PREREQUISITE' => '먼저 이해할 생각',
      _ => '이어진 생각',
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Bs.white, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Bs.text(14, weight: FontWeight.w700, color: Bs.primary)),
            const SizedBox(height: 8),
            Text(link.reason, style: Bs.text(15, color: Bs.g7, height: 1.5)),
            const SizedBox(height: 10),
            Text('${first.bookTitle} · ${first.label}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Bs.text(13, color: Bs.g3)),
            const SizedBox(height: 3),
            Text('${second.bookTitle} · ${second.label}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Bs.text(13, color: Bs.g3)),
            const SizedBox(height: 8),
            Text('① ${link.supportA}',
                style: Bs.text(13, color: Bs.g5, height: 1.4)),
            const SizedBox(height: 3),
            Text('② ${link.supportB}',
                style: Bs.text(13, color: Bs.g5, height: 1.4)),
            const SizedBox(height: 10),
            Row(children: [
              TextButton(
                  onPressed: () =>
                      context.push('/review/quiz/${first.chapterId}'),
                  child: const Text('첫 퀴즈 복습')),
              TextButton(
                  onPressed: () =>
                      context.push('/review/quiz/${second.chapterId}'),
                  child: const Text('두 번째 퀴즈 복습')),
            ]),
          ],
        ),
      ),
    );
  }

  bool _linkTouchesNode(
      ReadingGraph graph, ReadingMapLink link, ReadingNode selected) {
    for (final quizId in [link.quizAId, link.quizBId]) {
      final quiz = graph.nodeById('q$quizId');
      if (quiz == null) continue;
      if (selected.kind == ReadingNodeKind.question && quiz.id == selected.id) {
        return true;
      }
      if (selected.kind == ReadingNodeKind.chapter &&
          quiz.parentId == selected.id) {
        return true;
      }
      if (selected.kind == ReadingNodeKind.book &&
          quiz.bookId == selected.bookId) {
        return true;
      }
    }
    return false;
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

  void _selectNode(ReadingNode node, {bool fromMap = false}) {
    final repeatedMapTap = fromMap && _selectedNodeId == node.id;
    setState(() {
      _selectedNodeId = node.id;
      _bookId = node.bookId;
      _chapterId = switch (node.kind) {
        ReadingNodeKind.book => null,
        ReadingNodeKind.chapter => node.id,
        ReadingNodeKind.question => node.parentId,
      };
    });
    if (!fromMap || repeatedMapTap) _revealPanel();
  }

  void _toggleBook(ReadingNode book) {
    setState(() {
      _selectedNodeId = null;
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
      final links = ref.read(readingMapStateProvider).valueOrNull?.links ??
          const <ReadingMapLink>[];
      final bytes = await renderReadingGraphImage(graph, links: links);
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
