import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'learning_access.dart';
import 'learning_repository.dart';

final readingGraphProvider =
    FutureProvider.autoDispose<ReadingGraph>((ref) async {
  final owner = ref.watch(learningAccountProvider);
  if (owner == null) throw StateError('Sign in required');
  final repository = ref.watch(learningRepositoryProvider);
  final items = <ReviewItem>[];
  final cursors = <int>{};
  int? cursor;
  var unavailable = 0;
  for (var pageIndex = 0; pageIndex < 10; pageIndex++) {
    final page = await repository.getReviews(cursor: cursor);
    items.addAll(page.items);
    unavailable = page.unavailableCount;
    if (!page.hasNext) {
      return ReadingGraph.fromReviews(items, unavailableCount: unavailable);
    }
    final next = page.nextCursor;
    if (next == null ||
        !cursors.add(next) ||
        (cursor != null && next >= cursor)) {
      throw const FormatException('Non-progressing graph cursor');
    }
    cursor = next;
  }
  return ReadingGraph.fromReviews(items,
      truncated: true, unavailableCount: unavailable);
});

enum ReadingNodeKind { book, chapter, question }

class ReadingNode {
  const ReadingNode({
    required this.id,
    required this.kind,
    required this.label,
    required this.bookId,
    required this.bookTitle,
    required this.x,
    required this.y,
    this.chapterId,
    this.reviewCount = 0,
    this.parentId,
  });
  final String id;
  final ReadingNodeKind kind;
  final String label;
  final int bookId;
  final String bookTitle;
  final int? chapterId;
  final String? parentId;
  final int reviewCount;
  final double x;
  final double y;
}

class ReadingGraph {
  const ReadingGraph(this.nodes,
      {this.truncated = false, this.unavailableCount = 0});
  final List<ReadingNode> nodes;
  final bool truncated;
  final int unavailableCount;

  List<ReadingNode> get books =>
      nodes.where((node) => node.kind == ReadingNodeKind.book).toList();
  int get questionCount =>
      nodes.where((node) => node.kind == ReadingNodeKind.question).length;
  int get chapterCount =>
      nodes.where((node) => node.kind == ReadingNodeKind.chapter).length;

  factory ReadingGraph.fromReviews(List<ReviewItem> reviews,
      {bool truncated = false, int unavailableCount = 0}) {
    final unique = <int, ReviewItem>{};
    for (final item in reviews) {
      if (item.bookId == null || item.bookId! <= 0) {
        throw const FormatException('Graph requires a stable book identity');
      }
      unique[item.quizId] = item;
    }
    final grouped = <int, List<ReviewItem>>{};
    for (final item in unique.values) {
      grouped.putIfAbsent(item.bookId!, () => []).add(item);
    }
    final ids = grouped.keys.toList()..sort();
    final nodes = <ReadingNode>[];
    for (var index = 0; index < ids.length; index++) {
      final id = ids[index];
      final items = grouped[id]!;
      final angle = index * 2.399963229728653;
      final radius = index == 0 ? 0.0 : 170 * sqrt(index.toDouble());
      final bx = cos(angle) * radius;
      final by = sin(angle) * radius;
      final title = items.first.bookTitle;
      nodes.add(ReadingNode(
          id: 'b$id',
          kind: ReadingNodeKind.book,
          label: title,
          bookId: id,
          bookTitle: title,
          x: bx,
          y: by));
      final chapters = <int, List<ReviewItem>>{};
      for (final item in items) {
        chapters.putIfAbsent(item.chapterId, () => []).add(item);
      }
      final chapterIds = chapters.keys.toList()..sort();
      for (var c = 0; c < chapterIds.length; c++) {
        final chapterId = chapterIds[c];
        final questions = chapters[chapterId]!
          ..sort((a, b) => a.quizId.compareTo(b.quizId));
        final ca = c * 2.399963229728653 + (id % 11) * .4;
        final cr = 54.0 + 22 * sqrt(c.toDouble());
        final cx = bx + cos(ca) * cr;
        final cy = by + sin(ca) * cr;
        nodes.add(ReadingNode(
            id: 'c$chapterId',
            kind: ReadingNodeKind.chapter,
            label: questions.first.chapterTitle,
            bookId: id,
            bookTitle: title,
            chapterId: chapterId,
            parentId: 'b$id',
            x: cx,
            y: cy));
        for (var q = 0; q < questions.length; q++) {
          final item = questions[q];
          final qa = q * 2.399963229728653 + ca;
          final qr = 19.0 + 8 * sqrt(q.toDouble());
          nodes.add(ReadingNode(
              id: 'q${item.quizId}',
              kind: ReadingNodeKind.question,
              label: item.question,
              bookId: id,
              bookTitle: title,
              chapterId: chapterId,
              parentId: 'c$chapterId',
              reviewCount: item.reviewCount,
              x: cx + cos(qa) * qr,
              y: cy + sin(qa) * qr));
        }
      }
    }
    return ReadingGraph(List.unmodifiable(nodes),
        truncated: truncated, unavailableCount: unavailableCount);
  }
}
