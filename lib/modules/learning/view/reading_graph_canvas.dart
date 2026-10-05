import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../data/reading_graph.dart';
import '../data/reading_map_remote.dart';
import 'bs_ui.dart';

/// Book colors of the v2 reading map (Figma 4.2 "지도 속 책" dots).
const readingGraphPalette = [
  Color(0xFF7ACC97),
  Color(0xFFFFC87D),
  Color(0xFFA2EBFF),
  Color(0xFFB9A8FF),
  Color(0xFFFFA8C2),
  Color(0xFFF2D46B),
];

const _mutedNode = Color(0xFFE3E6E9);
const _mutedEdge = Bs.surface;

Color readingBookColor(ReadingGraph graph, int bookId) {
  final index = graph.books.indexWhere((book) => book.bookId == bookId);
  return readingGraphPalette[max(0, index) % readingGraphPalette.length];
}

/// Share image (1080×1350) of the whole map with its title and counts.
Future<Uint8List> renderReadingGraphImage(ReadingGraph graph,
    {List<ReadingMapLink> links = const []}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder)..scale(3);
  canvas.drawColor(Bs.bg, BlendMode.src);
  void text(InlineSpan span, Offset offset) => (TextPainter(
        text: span,
        textDirection: TextDirection.ltr,
        maxLines: 2,
        ellipsis: '…',
      )..layout(maxWidth: 312))
          .paint(canvas, offset);

  text(
    TextSpan(
        text: '읽고 떠올린 것이\n하나의 세계로',
        style: Bs.text(22, weight: FontWeight.w700, height: 1.4)),
    const Offset(24, 28),
  );
  text(
    TextSpan(children: [
      for (final (count, label) in [
        (graph.books.length, '권  '),
        (graph.chapterCount, '목차  '),
        (graph.questionCount, '개 퀴즈'),
      ]) ...[
        TextSpan(text: '$count', style: Bs.text(14, weight: FontWeight.w700)),
        TextSpan(text: label, style: Bs.text(14, color: Bs.g3)),
      ],
    ]),
    const Offset(24, 98),
  );
  const card = Rect.fromLTWH(16, 132, 328, 252);
  canvas.drawRRect(RRect.fromRectAndRadius(card, const Radius.circular(18)),
      Paint()..color = Bs.white);
  canvas.save();
  canvas.translate(card.left + 8, card.top + 8);
  final mapSize = Size(card.width - 16, card.height - 16);
  ReadingGraphPainter(ReadingGraphLayout(graph, mapSize), links: links)
      .paint(canvas, mapSize);
  canvas.restore();
  text(
    TextSpan(
        text: '북스타 · 나의 독서 지도',
        style: Bs.text(12, weight: FontWeight.w600, color: Bs.g5)),
    const Offset(24, 400),
  );
  text(
    TextSpan(
        text: '풀어본 퀴즈 기록으로 만든 지도예요${graph.truncated ? ' · 일부 기록' : ''}',
        style: Bs.text(10, color: Bs.g3)),
    const Offset(24, 420),
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

/// Map of books (large dots), chapters and answered quizzes (small dots).
/// Tapping a dot reports the nearest node through [onSelected]; with
/// [zoomable] the map can be pinched (and panned sideways once zoomed) while
/// vertical drags keep scrolling the page.
class ReadingGraphCanvas extends StatefulWidget {
  const ReadingGraphCanvas({
    super.key,
    required this.graph,
    this.selectedId,
    this.onSelected,
    this.interactive = true,
    this.zoomable = false,
    this.links = const [],
  });
  final ReadingGraph graph;
  final String? selectedId;
  final ValueChanged<ReadingNode>? onSelected;
  final bool interactive;
  final bool zoomable;
  final List<ReadingMapLink> links;

  @override
  State<ReadingGraphCanvas> createState() => _ReadingGraphCanvasState();
}

class _ReadingGraphCanvasState extends State<ReadingGraphCanvas> {
  final _transform = TransformationController();
  bool _zoomed = false;

  @override
  void initState() {
    super.initState();
    _transform.addListener(() {
      final zoomed = _transform.value.getMaxScaleOnAxis() > 1.01;
      if (zoomed != _zoomed) setState(() => _zoomed = zoomed);
    });
  }

  @override
  void didUpdateWidget(covariant ReadingGraphCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.graph, widget.graph)) {
      _transform.value = Matrix4.identity();
    }
  }

  @override
  void dispose() {
    _transform.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, box) {
          final graph = widget.graph;
          final size = Size(box.maxWidth, box.maxHeight);
          final layout = ReadingGraphLayout(graph, size);
          Widget picture = CustomPaint(
            size: size,
            painter: ReadingGraphPainter(layout,
                selectedId: widget.selectedId, links: widget.links),
          );
          final onSelected = widget.onSelected;
          if (widget.interactive && onSelected != null) {
            picture = GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (details) {
                final hit = layout.hitTest(details.localPosition);
                if (hit != null) onSelected(hit);
              },
              child: picture,
            );
          }
          if (widget.interactive && widget.zoomable) {
            picture = InteractiveViewer(
              transformationController: _transform,
              maxScale: 4,
              panEnabled: _zoomed,
              child: picture,
            );
          }
          return Semantics(
            label:
                '독서 지도. 책 ${graph.books.length}권, 목차 ${graph.chapterCount}개, 풀어본 퀴즈 ${graph.questionCount}개.',
            child: picture,
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
    final fitX = max(1.0, size.width - 80) / spanX;
    final fitY = max(1.0, size.height - (size.height < 240 ? 40 : 96)) / spanY;
    final scale = min(fitX, fitY);
    // Tall cards (4.1/4.2) stretch the map vertically a little to fill them.
    final scaleY = min(fitY, scale * 1.4);
    nodeScale = (scale / .7).clamp(.5, 1.0);
    for (final node in graph.nodes) {
      positions[node.id] = Offset(
        size.width / 2 + (node.x - (minX + maxX) / 2) * scale,
        size.height / 2 - 8 + (node.y - (minY + maxY) / 2) * scaleY,
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
  ReadingGraphPainter(this.layout, {this.selectedId, this.links = const []});
  final ReadingGraphLayout layout;
  final String? selectedId;
  final List<ReadingMapLink> links;

  @override
  void paint(Canvas canvas, Size size) {
    final graph = layout.graph;
    final dot = Paint()..color = Bs.surface;
    for (var y = 9.0; y < size.height; y += 18) {
      for (var x = 9.0; x < size.width; x += 18) {
        canvas.drawCircle(Offset(x, y), 1, dot);
      }
    }
    if (graph.nodes.isEmpty) return;
    final selected = graph.nodeById(selectedId);
    final focusChapter = switch (selected?.kind) {
      ReadingNodeKind.chapter => selected!.id,
      ReadingNodeKind.question => selected!.parentId,
      _ => null,
    };
    final colors = {
      for (final (index, book) in graph.books.indexed)
        book.bookId: readingGraphPalette[index % readingGraphPalette.length],
    };
    bool active(ReadingNode node) =>
        selected == null || selected.bookId == node.bookId;
    final scale = layout.nodeScale;

    for (final node in graph.nodes) {
      final parent = layout.positions[node.parentId];
      if (parent == null) continue;
      final on = active(node);
      final chapter = node.kind == ReadingNodeKind.chapter;
      canvas.drawLine(
        parent,
        layout.positions[node.id]!,
        Paint()
          ..color = on
              ? colors[node.bookId]!.withValues(alpha: chapter ? .8 : .55)
              : _mutedEdge
          ..strokeWidth = (chapter ? 1.6 : 1.1) * scale
          ..strokeCap = StrokeCap.round,
      );
    }

    for (final link in links) {
      final first = layout.positions['q${link.quizAId}'];
      final second = layout.positions['q${link.quizBId}'];
      if (first == null || second == null) continue;
      canvas.drawLine(
        first,
        second,
        Paint()
          ..color = Bs.primary.withValues(alpha: .65)
          ..strokeWidth = 2.2 * scale
          ..strokeCap = StrokeCap.round,
      );
    }

    for (final kind in const [
      ReadingNodeKind.question,
      ReadingNodeKind.chapter,
      ReadingNodeKind.book,
    ]) {
      for (final node in graph.nodes.where((node) => node.kind == kind)) {
        final point = layout.positions[node.id]!;
        final base = colors[node.bookId]!;
        final color = active(node) ? base : _mutedNode;
        final radius = scale *
            switch (kind) {
              ReadingNodeKind.book => 12.0,
              ReadingNodeKind.chapter => 6.5,
              ReadingNodeKind.question => node.reviewCount > 0 ? 4.4 : 3.6,
            };
        if (kind == ReadingNodeKind.book) {
          canvas.drawCircle(point, radius + 6 * scale,
              Paint()..color = color.withValues(alpha: .25));
        }
        canvas.drawCircle(point, radius, Paint()..color = color);
        if (kind == ReadingNodeKind.chapter) {
          canvas.drawCircle(point, radius * .42, Paint()..color = Bs.white);
        }
        if (node.id == selectedId || node.id == focusChapter) {
          canvas.drawCircle(
            point,
            radius + 3.5,
            Paint()
              ..color = Color.lerp(base, Bs.black, .35)!
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.6,
          );
        }
      }
    }

    final occupied = [
      for (final node in graph.nodes)
        Rect.fromCircle(
            center: layout.positions[node.id]!,
            radius: (node.kind == ReadingNodeKind.question ? 4 : 7) * scale),
    ];
    void label(ReadingNode node, TextStyle style, double gap,
        {bool always = false}) {
      final point = layout.positions[node.id]!;
      final painter = TextPainter(
        text: TextSpan(text: node.label, style: style),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '…',
      )..layout(maxWidth: min(112.0, size.width - 16));
      final x = (point.dx - painter.width / 2)
          .clamp(8.0, max(8.0, size.width - painter.width - 8))
          .toDouble();
      final candidates = [
        for (final y in [
          point.dy + gap,
          point.dy - painter.height - gap,
          point.dy + gap + 18,
        ])
          Rect.fromLTWH(x, y, painter.width, painter.height),
      ];
      final rect = candidates
              .where((rect) =>
                  rect.top >= 0 &&
                  rect.bottom <= size.height &&
                  !occupied.any((other) => other.overlaps(rect.inflate(2))))
              .firstOrNull ??
          (always ? candidates.first : null);
      if (rect == null) return;
      canvas.drawRRect(
          RRect.fromRectAndRadius(rect.inflate(2), const Radius.circular(4)),
          Paint()..color = Bs.white.withValues(alpha: .85));
      painter.paint(canvas, rect.topLeft);
      occupied.add(rect);
    }

    final books = graph.books;
    final focusBook = selected?.bookId;
    for (final book in [
      ...books.where((book) => book.bookId == focusBook),
      ...books.where((book) => book.bookId != focusBook),
    ]) {
      if (books.length > 14 && book.bookId != focusBook) continue;
      label(
        book,
        Bs.text(11,
            weight: FontWeight.w600,
            color: active(book) ? Bs.g6 : Bs.g2,
            height: 1.3),
        13 * scale + 6,
        always: books.length <= 6 || book.bookId == focusBook,
      );
    }
    if (focusBook != null) {
      for (final chapter in graph.chaptersOf(focusBook)) {
        label(
          chapter,
          Bs.text(10,
              weight: chapter.id == focusChapter
                  ? FontWeight.w600
                  : FontWeight.w400,
              color: chapter.id == focusChapter ? Bs.g6 : Bs.g3,
              height: 1.3),
          7 * scale + 4,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant ReadingGraphPainter oldDelegate) =>
      oldDelegate.layout != layout ||
      oldDelegate.selectedId != selectedId ||
      oldDelegate.links != links;
}
