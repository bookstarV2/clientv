import 'package:bookstar/modules/book/model/book_summary.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'ranking_weekly_top3_response.freezed.dart';
part 'ranking_weekly_top3_response.g.dart';

@freezed
abstract class RankingWeeklyTop3Response with _$RankingWeeklyTop3Response {
  const factory RankingWeeklyTop3Response({
    @Default(-1) int rank,
    @Default(-1) int memberId,
    @Default("") String nickname,
    @Default("") String profileImage,
    @Default(-1) int participationDays,
    @Default(-1) int solvedCount,
    @Default(-1) int correctCount,
    @Default(false) bool myRank,
  }) = _RankingWeeklyTop3Response;

  factory RankingWeeklyTop3Response.fromJson(Map<String, dynamic> json) =>
      _$RankingWeeklyTop3ResponseFromJson(json);
}
