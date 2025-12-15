import 'package:bookstar/modules/reading_challenge/model/challenge_detail_book_overview.dart';
import 'package:bookstar/modules/reading_challenge/model/challenge_detail_chapter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'challenge_detail_response.freezed.dart';
part 'challenge_detail_response.g.dart';

@freezed
abstract class ChallengeDetailResponse with _$ChallengeDetailResponse {
  const factory ChallengeDetailResponse({
    @Default(ChallengeDetailBookOverview())
    ChallengeDetailBookOverview bookOverview,
    @Default([]) List<ChallengeDetailChapter> chapters,
  }) = _ChallengeDetailResponse;

  factory ChallengeDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$ChallengeDetailResponseFromJson(json);
}
