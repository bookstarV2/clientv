import 'package:freezed_annotation/freezed_annotation.dart';

part 'ranking_weekly_response.freezed.dart';
part 'ranking_weekly_response.g.dart';

@freezed
abstract class RankingWeeklyResponse with _$RankingWeeklyResponse {
  const factory RankingWeeklyResponse({
    @Default(-1) int rank,
    @Default(-1) int memberId,
    @Default("") String nickname,
    @Default("") String profileImage,
    @Default(-1) int participationDays,
    @Default(-1) int solvedCount,
    @Default(-1) int correctCount,
    @Default(false) bool myRank,
  }) = _RankingWeeklyResponse;

  factory RankingWeeklyResponse.fromJson(Map<String, dynamic> json) =>
      _$RankingWeeklyResponseFromJson(json);
}
