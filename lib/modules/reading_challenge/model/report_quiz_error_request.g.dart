// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_quiz_error_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReportQuizErrorRequest _$ReportQuizErrorRequestFromJson(
        Map<String, dynamic> json) =>
    _ReportQuizErrorRequest(
      errorType: $enumDecodeNullable(
              _$ReportQuizErrorTypeEnumMap, json['errorType']) ??
          ReportQuizErrorType.OTHER,
      content: json['content'] as String? ?? '',
    );

Map<String, dynamic> _$ReportQuizErrorRequestToJson(
        _ReportQuizErrorRequest instance) =>
    <String, dynamic>{
      'errorType': _$ReportQuizErrorTypeEnumMap[instance.errorType]!,
      'content': instance.content,
    };

const _$ReportQuizErrorTypeEnumMap = {
  ReportQuizErrorType.DIFFERENT_FROM_BOOK: 'DIFFERENT_FROM_BOOK',
  ReportQuizErrorType.NOT_IN_BOOK: 'NOT_IN_BOOK',
  ReportQuizErrorType.SUBJECTIVE_CONTENT: 'SUBJECTIVE_CONTENT',
  ReportQuizErrorType.OTHER: 'OTHER',
};
