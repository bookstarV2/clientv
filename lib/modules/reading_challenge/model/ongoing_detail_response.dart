import 'package:bookstar/modules/reading_challenge/model/challenge_response.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'ongoing_detail_response.freezed.dart';
part 'ongoing_detail_response.g.dart';

@freezed
abstract class OngoingDetailResponse with _$OngoingDetailResponse {
  const factory OngoingDetailResponse({
    @Default(-1) int ongoingCount,
    @Default(-1) int completedCount,
    @Default([]) List<ChallengeResponse> challenges,
  }) = _OngoingDetailResponse;

  factory OngoingDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$OngoingDetailResponseFromJson(json);
}
