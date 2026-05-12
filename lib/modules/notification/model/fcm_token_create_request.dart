import 'package:freezed_annotation/freezed_annotation.dart';

part 'fcm_token_create_request.freezed.dart';
part 'fcm_token_create_request.g.dart';

@freezed
abstract class FCMTokenCreateRequest with _$FCMTokenCreateRequest {
  const factory FCMTokenCreateRequest({
    required int userId,
    required String fcmToken,
    required String deviceType,
  }) = _FCMTokenCreateRequest;

  factory FCMTokenCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$FCMTokenCreateRequestFromJson(json);
}
