import 'package:freezed_annotation/freezed_annotation.dart';

part 'like_book_response.freezed.dart';
part 'like_book_response.g.dart';

@freezed
abstract class LikeBookResponse with _$LikeBookResponse {
  const factory LikeBookResponse({
    @Default(0) int bookId,
    @Default('') String title,
    @Default('') String bookCover,
    @Default('') String pubDate,
    @Default('') String author,
    @Default('') String publisher,
    @Default(false) bool hasChallenge,
    @Default(false) bool hasChapter,
    @Default(false) bool hasQuiz,
  }) = _LikeBookResponse;

  factory LikeBookResponse.fromJson(Map<String, dynamic> json) =>
      _$LikeBookResponseFromJson(json);
}
