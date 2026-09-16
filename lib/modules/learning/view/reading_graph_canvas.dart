import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../data/reading_graph.dart';

const readingGraphPalette = [
  Color(0xFF527E72),
  Color(0xFFB96C48),
  Color(0xFF667DB0),
  Color(0xFF8B739F),
  Color(0xFFAA873D),
];

Future<Uint8List> renderReadingGraphImage(ReadingGraph graph) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder)..scale(3);
  canvas.drawColor(Colors.white, BlendMode.src);
  void text(
    String value,
    double top,
    double fontSize,
    Color color, {
    FontWeight weight = FontWeight.w400,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: value,
        style: TextStyle(
          fontFamily: 'Pretendard',
          fontSize: fontSize,
          fontWeight: weight,
          color: color,
          height: 1.4,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 2,
      ellipsis: '…',
    )..layout(maxWidth: 312);
    painter.paint(canvas, Offset(24, top));
  }

  text('MY READING MAP', 24, 9, const Color(0xFF737D77));
  text(
    '읽고 떠올린 것들이\n하나의 세계로.',
    48,
    23,
    const Color(0xFF252D29),
    weight: FontWeight.w600,
  );
  text(
    '책 ${graph.books.length}  ·  목차 ${graph.chapterCount}  ·  풀어본 질문 ${graph.questionCount}',
    124,
    10,
    const Color(0xFF527E72),
  );
  canvas.save();
  canvas.translate(0, 142);
  ReadingGraphPainter(
    ReadingGraphLayout(graph, const Size(360, 252)),
  ).paint(canvas, const Size(360, 252));
  canvas.restore();
  text(
    '북스타  /  나만의 독서 지도',
    397,
    11,
    const Color(0xFF35463C),
    weight: FontWeight.w600,
  );
  text(
    '표시된 풀이 기록 · 완독 인증 아님${graph.truncated ? ' · 일부 기록' : ''}',
    421,
    8,
    const Color(0xFF737D77),
  );
  final picture = recorder.endRecording();
  ui.Image? image;
  try {
    image = await picture.toImage(1080, 1350);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    if (data == null) throw StateError('Image encoding failed');
    return data.buffer.asUint8List();
  } finally {
    image?.dispose();
    picture.dispose();
  }
}

class ReadingGraphCanvas extends StatefulWidget {
  const ReadingGraphCanvas({
    super.key,
    required this.graph,
    this.selectedId,
    this.onSelected,
    this.onExplorationChanged,
    this.onFullscreen,
    this.exploring,
    this.interactive = true,
  });
  final ReadingGraph graph;
  final String? selectedId;
  final ValueChanged<ReadingNode>? onSelected;
  final ValueChanged<bool>? onExplorationChanged;
  final VoidCallback? onFullscreen;
  final bool? exploring;
  final bool interactive;

  @override
  State<ReadingGraphCanvas> createState() => _ReadingGraphCanvasState();
}

class _ReadingGraphCanvasState extends State<ReadingGraphCanvas> {
  final _transform = TransformationController();
  bool _exploring = false;

  @override
  void dispose() {
    _transform.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ReadingGraphCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.graph, widget.graph) ||
        (oldWidget.exploring == true && widget.exploring == false)) {
      _transform.value = Matrix4.identity();
      _exploring = false;
    }
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, box) {
          final size = Size(box.maxWidth, box.maxHeight);
          final layout = ReadingGraphLayout(widget.graph, size);
          final picture = GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: widget.interactive
                ? (details) {
                    final hit = layout.hitTest(details.localPosition);
                    if (hit != null) {
                      widget.onSelected?.call(hit);
                    }
                  }
                : null,
            child: CustomPaint(
              size: size,
              painter:
                  ReadingGraphPainter(layout, selectedId: widget.selectedId),
            ),
          );
          if (!widget.interactive) return picture;
          return Stack(
            children: [
              Positioned.fill(
                child: Semantics(
                  label:
                      '독서 지도. 책 ${widget.graph.books.length}권, 풀어본 질문 ${widget.graph.questionCount}개. 확대하거나 아래 목록에서 기록을 선택할 수 있어요.',
                  child: (widget.exploring ?? _exploring)
                      ? InteractiveViewer(
                          transformationController: _transform,
                          minScale: .75,
                          maxScale: 5,
                          boundaryMargin: const EdgeInsets.all(180),
                          child: picture,
                        )
                      : picture,
                ),
              ),
              if (widget.exploring ?? _exploring)
                const Positioned(
                  top: 4,
                  left: 24,
                  right: 24,
                  child: IgnorePointer(
                    child: Text(
                      '이동·핀치 확대 중 · 전체 보기로 돌아갈 수 있어요',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10, color: Color(0xFF737D77)),
                    ),
                  ),
                ),
              Positioned(
                right: 8,
                bottom: 8,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .94),
                    border: Border.all(color: const Color(0xFFE7E9E7)),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.onFullscreen != null)
                        IconButton(
                          tooltip: '지도 전체 화면 · 점 끌기',
                          onPressed: widget.onFullscreen,
                          icon: const Icon(Icons.open_in_full, size: 19),
                        ),
                      IconButton(
                        tooltip: '지도 축소',
                        iconSize: 19,
                        onPressed: () {
                          setState(() => _exploring = true);
                          widget.onExplorationChanged?.call(true);
                          final scale = _transform.value.getMaxScaleOnAxis();
                          final next = Matrix4.identity()
                            ..translate(size.width / 2, size.height / 2)
                            ..scale(max(.75 / scale, 1 / 1.4))
                            ..translate(-size.width / 2, -size.height / 2)
                            ..multiply(_transform.value);
                          _transform.value = next;
                        },
                        icon: const Icon(Icons.remove),
                      ),
                      IconButton(
                        tooltip: '지도 확대',
                        iconSize: 19,
                        onPressed: () {
                          setState(() => _exploring = true);
                          widget.onExplorationChanged?.call(true);
                          final scale = _transform.value.getMaxScaleOnAxis();
                          if (scale < 5) {
                            final next = Matrix4.identity()
                              ..translate(size.width / 2, size.height / 2)
                              ..scale(min(1.4, 5 / scale))
                              ..translate(-size.width / 2, -size.height / 2)
                              ..multiply(_transform.value);
                            _transform.value = next;
                          }
                        },
                        icon: const Icon(Icons.add),
                      ),
                      IconButton(
                        tooltip: '지도 전체 보기',
                        iconSize: 19,
                        onPressed: () => setState(() {
                          _transform.value = Matrix4.identity();
                          _exploring = false;
                          widget.onExplorationChanged?.call(false);
                        }),
                        icon: const Icon(Icons.center_focus_weak_rounded),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      );
}

class ReadingGraphLayout {
  ReadingGraphLayout(this.graph, this.size) {
    if (graph.nodes.isEmpty) return;
    var minX = graph.nodes.first.x;
    var maxX = minX;
    var minY = graph.nodes.first.y;
    var maxY = minY;
    for (final node in graph.nodes) {
      minX = min(minX, node.x);
      maxX = max(maxX, node.x);
      minY = min(minY, node.y);
      maxY = max(maxY, node.y);
    }
    final spanX = max(230.0, maxX - minX);
    final spanY = max(230.0, maxY - minY);
    final scale = min(
      max(1.0, size.width - 80) / spanX,
      max(1.0, size.height - (size.height < 240 ? 32 : 110)) / spanY,
    );
    nodeScale = (scale / .8).clamp(.3, 1.0);
    for (final node in graph.nodes) {
      positions[node.id] = Offset(
        size.width / 2 + (node.x - (minX + maxX) / 2) * scale,
        size.height / 2 - 12 + (node.y - (minY + maxY) / 2) * scale,
      );
    }
  }
  final ReadingGraph graph;
  final Size size;
  final positions = <String, Offset>{};
  double nodeScale = 1;

  ReadingNode? hitTest(Offset point) {
    ReadingNode? closest;
    var distance = 22.0;
    for (final node in graph.nodes) {
      final candidate = (positions[node.id]! - point).distance;
      if (candidate < distance) {
        closest = node;
        distance = candidate;
      }
    }
    return closest;
  }
}

class ReadingGraphPainter extends CustomPainter {
  ReadingGraphPainter(this.layout, {this.selectedId});
  final ReadingGraphLayout layout;
  final String? selectedId;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);
    final nodes = layout.graph.nodes;
    if (nodes.isEmpty) return;
    ReadingNode? selected;
    for (final node in nodes) {
      if (node.id == selectedId) selected = node;
    }
    final books = layout.graph.books;
    final colors = {
      for (var i = 0; i < books.length; i++)
        books[i].bookId: readingGraphPalette[i % readingGraphPalette.length],
    };
    for (final node in nodes) {
      final parent = layout.positions[node.parentId];
      if (parent == null) continue;
      final active = selected == null || selected.bookId == node.bookId;
      canvas.drawLine(
        parent,
        layout.positions[node.id]!,
        Paint()
          ..color = active
              ? colors[node.bookId]!.withValues(alpha: .38)
              : const Color(0xFFEDEFEF)
          ..strokeWidth = node.kind == ReadingNodeKind.chapter ? .9 : .65,
      );
    }
    final occupiedLabels = <Rect>[];
    for (final node in nodes) {
      final point = layout.positions[node.id]!;
      final active = selected == null || selected.bookId == node.bookId;
      final color = active ? colors[node.bookId]! : const Color(0xFFDCDDDE);
      final radius = (switch (node.kind) {
            ReadingNodeKind.book => 6.5,
            ReadingNodeKind.chapter => 3.3,
            ReadingNodeKind.question => node.reviewCount > 0 ? 2.9 : 2.2,
          }) *
          layout.nodeScale;
      if (node.kind == ReadingNodeKind.book || node.id == selectedId) {
        canvas.drawCircle(
          point,
          radius + (node.id == selectedId ? 9 : 4 * layout.nodeScale),
          Paint()..color = color.withValues(alpha: .09),
        );
      }
      canvas.drawCircle(point, radius, Paint()..color = color);
      if (node.id == selectedId) {
        canvas.drawCircle(
          point,
          radius + 4,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1,
        );
      }
      if (node.kind == ReadingNodeKind.book &&
          (books.length <= 14 || node.id == selectedId)) {
        final label = TextPainter(
          text: TextSpan(
            text: node.label,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: active ? const Color(0xFF595E5B) : const Color(0xFFAFB2B0),
            ),
          ),
          textDirection: TextDirection.ltr,
          maxLines: 1,
          ellipsis: '…',
        )..layout(maxWidth: min(108.0, size.width - 24));
        final x = (point.dx - label.width / 2).clamp(
          8.0,
          max(8.0, size.width - label.width - 8),
        );
        for (final y in [
          point.dy + 12,
          point.dy - label.height - 10,
          point.dy + 30,
        ]) {
          final rect = Rect.fromLTWH(
            x.toDouble(),
            y,
            label.width,
            label.height,
          );
          if (rect.top < 0 ||
              rect.bottom > size.height - 8 ||
              occupiedLabels.any((other) => other.overlaps(rect.inflate(3)))) {
            continue;
          }
          label.paint(canvas, rect.topLeft);
          occupiedLabels.add(rect);
          break;
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant ReadingGraphPainter oldDelegate) =>
      oldDelegate.layout != layout || oldDelegate.selectedId != selectedId;
}
