import 'package:bookstar/modules/book_pick/model/generate_all_quizzes_status.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'generate_all_quizzes_response.freezed.dart';
part 'generate_all_quizzes_response.g.dart';

@freezed
abstract class GenerateAllQuizzesResponse with _$GenerateAllQuizzesResponse {
  const factory GenerateAllQuizzesResponse({
    @Default(GenerateAllQuizzesStatus.PROCESSING) GenerateAllQuizzesStatus status,
    @Default(0) int bookId,
    @Default(0) int chapterCount,
  }) = _GenerateAllQuizzesResponse;

  factory GenerateAllQuizzesResponse.fromJson(Map<String, dynamic> json) =>
      _$GenerateAllQuizzesResponseFromJson(json);
}
