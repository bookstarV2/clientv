import 'package:bookstar/modules/reading_challenge/view/widgets/report_quiz_error_dialog.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'report_quiz_error_request.freezed.dart';
part 'report_quiz_error_request.g.dart';

@freezed
abstract class ReportQuizErrorRequest with _$ReportQuizErrorRequest {
  const factory ReportQuizErrorRequest({
    @Default(ReportQuizErrorType.OTHER) ReportQuizErrorType errorType,
    @Default('') String content,
  }) = _ReportQuizErrorRequest;

  factory ReportQuizErrorRequest.fromJson(Map<String, dynamic> json) =>
      _$ReportQuizErrorRequestFromJson(json);
}
