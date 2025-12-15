import 'package:bookstar/modules/reading_challenge/model/challenge_detail_chapter_detail.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'challenge_detail_chapter_detail_response.freezed.dart';
part 'challenge_detail_chapter_detail_response.g.dart';

@freezed
abstract class ChallengeDetailChapterDetailResponse
    with _$ChallengeDetailChapterDetailResponse {
  const factory ChallengeDetailChapterDetailResponse({
    @Default([]) List<ChallengeDetailChapterDetail> chapters,
  }) = _ChallengeDetailChapterDetailResponse;

  factory ChallengeDetailChapterDetailResponse.fromJson(
          Map<String, dynamic> json) =>
      _$ChallengeDetailChapterDetailResponseFromJson(json);
}
