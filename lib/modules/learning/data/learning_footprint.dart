import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'learning_access.dart';
import 'learning_repository.dart';

final learningFootprintProvider =
    FutureProvider.autoDispose<LearningFootprint>((ref) {
  if (ref.watch(learningAccountProvider) == null) {
    throw StateError('Sign in required');
  }
  return ref.watch(learningRepositoryProvider).getFootprint();
});

class LearningFootprint {
  const LearningFootprint(
      {required this.answeredQuizCount,
      required this.reviewedQuizCount,
      required this.bookCount,
      required this.generatedAt});
  final int answeredQuizCount;
  final int reviewedQuizCount;
  final int bookCount;
  final DateTime generatedAt;

  factory LearningFootprint.fromJson(Map<String, dynamic> json) {
    if (json['scope'] != 'STORED_RECORDS') {
      throw const FormatException('Unsupported footprint scope');
    }
    final result = LearningFootprint(
      answeredQuizCount: (json['answeredQuizCount'] as num).toInt(),
      reviewedQuizCount: (json['reviewedQuizCount'] as num).toInt(),
      bookCount: (json['bookCount'] as num).toInt(),
      generatedAt: DateTime.parse(json['generatedAt'] as String),
    );
    if (result.answeredQuizCount < 0 ||
        result.reviewedQuizCount < 0 ||
        result.bookCount < 0 ||
        result.reviewedQuizCount > result.answeredQuizCount) {
      throw const FormatException('Invalid footprint counts');
    }
    return result;
  }
}

class FootprintBook {
  const FootprintBook(
      {required this.bookId,
      required this.title,
      this.author = '',
      this.cover = ''});
  final int bookId;
  final String title;
  final String author;
  final String cover;

  factory FootprintBook.fromJson(Map<String, dynamic> json) => FootprintBook(
        bookId: (json['bookId'] as num).toInt(),
        title: json['title'] as String,
        author: json['author'] as String? ?? '',
        cover: json['cover'] as String? ?? '',
      );
}

class FootprintBookPage {
  const FootprintBookPage(
      {required this.items,
      required this.hasNext,
      required this.totalCount,
      this.nextCursor});
  final List<FootprintBook> items;
  final bool hasNext;
  final int totalCount;
  final int? nextCursor;

  factory FootprintBookPage.fromJson(Map<String, dynamic> json) {
    if (json['scope'] != 'STORED_RECORDS') {
      throw const FormatException('Unsupported footprint scope');
    }
    final page = FootprintBookPage(
      items: (json['items'] as List)
          .map((item) => FootprintBook.fromJson(item as Map<String, dynamic>))
          .toList(),
      hasNext: json['hasNext'] == true,
      totalCount: (json['totalCount'] as num).toInt(),
      nextCursor: (json['nextCursor'] as num?)?.toInt(),
    );
    if (page.hasNext && page.nextCursor == null) {
      throw const FormatException('Missing footprint cursor');
    }
    return page;
  }
}
