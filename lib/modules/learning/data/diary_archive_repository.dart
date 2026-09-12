import 'package:bookstar/infra/network/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'learning_access.dart';

final diaryArchiveRepositoryProvider = Provider<DiaryArchiveRepository>((ref) {
  ref.watch(learningAccountProvider);
  return DiaryArchiveRepository(ref.watch(dioClientProvider));
});

class DiaryArchiveRepository {
  DiaryArchiveRepository(this._dio);
  final Dio _dio;

  Future<DiaryArchivePage> getPage({int? cursor}) async {
    final response = await _dio.get<Map<String, dynamic>>(
        '/api/v3/me/reading-diaries',
        queryParameters: {'size': 20, if (cursor != null) 'cursor': cursor});
    return DiaryArchivePage.fromJson(
        response.data!['data'] as Map<String, dynamic>);
  }

  Future<DiaryArchiveItem> getDetail(int id) async {
    final response =
        await _dio.get<Map<String, dynamic>>('/api/v3/me/reading-diaries/$id');
    return DiaryArchiveItem.fromJson(
        response.data!['data'] as Map<String, dynamic>);
  }
}

class DiaryArchivePage {
  const DiaryArchivePage(this.items, this.hasNext, this.nextCursor);
  final List<DiaryArchiveItem> items;
  final bool hasNext;
  final int? nextCursor;

  factory DiaryArchivePage.fromJson(Map<String, dynamic> json) =>
      DiaryArchivePage(
          (json['items'] as List<dynamic>)
              .map((item) =>
                  DiaryArchiveItem.fromJson(item as Map<String, dynamic>))
              .toList(),
          json['hasNext'] == true,
          (json['nextCursor'] as num?)?.toInt());
}

class DiaryArchiveItem {
  const DiaryArchiveItem(
      {required this.id,
      required this.bookTitle,
      required this.bookCover,
      required this.content,
      this.createdAt,
      this.images = const []});
  final int id;
  final String bookTitle;
  final String bookCover;
  final String content;
  final DateTime? createdAt;
  final List<String> images;

  factory DiaryArchiveItem.fromJson(Map<String, dynamic> json) =>
      DiaryArchiveItem(
          id: (json['diaryId'] as num).toInt(),
          bookTitle: json['bookTitle'] as String? ?? '지난 독서 기록',
          bookCover: json['bookCover'] as String? ?? '',
          content: (json['content'] ?? json['preview']) as String? ?? '',
          createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
          images: (json['images'] as List<dynamic>? ?? [])
              .map((image) =>
                  (image as Map<String, dynamic>)['imageUrl'] as String? ?? '')
              .where((url) => url.isNotEmpty)
              .toList());
}
