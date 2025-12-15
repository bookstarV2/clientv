import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_reading_timer_request.freezed.dart';
part 'post_reading_timer_request.g.dart';

@freezed
abstract class PostReadingTimerRequest with _$PostReadingTimerRequest {
  const factory PostReadingTimerRequest({
    @Default(-1) int challengeId,
    @Default(-1) int seconds,
  }) = _PostReadingTimerRequest;

  factory PostReadingTimerRequest.fromJson(Map<String, dynamic> json) =>
      _$PostReadingTimerRequestFromJson(json);
}
