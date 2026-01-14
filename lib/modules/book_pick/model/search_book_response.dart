import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_book_response.freezed.dart';
part 'search_book_response.g.dart';

@freezed
abstract class SearchBookResponse with _$SearchBookResponse {
  const factory SearchBookResponse({
    @Default(0) int bookId,
    @Default('') String title,
    @Default('') String bookCover,
    @Default('') String pubDate,
    @Default('') String author,
    @Default('') String publisher,
    @Default(false) bool alreadyExists,
    @Default(false) bool hasChapter,
    @Default(false) bool hasQuiz,
  }) = _SearchBookResponse;

  factory SearchBookResponse.fromJson(Map<String, dynamic> json) =>
      _$SearchBookResponseFromJson(json);
}
