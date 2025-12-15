import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_progress_request.freezed.dart';
part 'post_progress_request.g.dart';

@freezed
abstract class PostProgressRequest with _$PostProgressRequest {
  const factory PostProgressRequest({
    @Default(-1) int chapterId,
  }) = _PostProgressRequest;

  factory PostProgressRequest.fromJson(Map<String, dynamic> json) =>
      _$PostProgressRequestFromJson(json);
}
