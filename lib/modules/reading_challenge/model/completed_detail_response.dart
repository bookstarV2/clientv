import 'package:bookstar/modules/reading_challenge/model/challenge_response.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'completed_detail_response.freezed.dart';
part 'completed_detail_response.g.dart';

@freezed
abstract class CompletedDetailResponse with _$CompletedDetailResponse {
  const factory CompletedDetailResponse({
    @Default(-1) int completedCount,
    @Default([]) List<ChallengeResponse> challenges,
  }) = _CompletedDetailResponse;

  factory CompletedDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$CompletedDetailResponseFromJson(json);
}
