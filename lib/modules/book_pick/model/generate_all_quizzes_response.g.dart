// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'generate_all_quizzes_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GenerateAllQuizzesResponse _$GenerateAllQuizzesResponseFromJson(
        Map<String, dynamic> json) =>
    _GenerateAllQuizzesResponse(
      status: $enumDecodeNullable(
              _$GenerateAllQuizzesStatusEnumMap, json['status']) ??
          GenerateAllQuizzesStatus.PROCESSING,
      bookId: (json['bookId'] as num?)?.toInt() ?? 0,
      chapterCount: (json['chapterCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$GenerateAllQuizzesResponseToJson(
        _GenerateAllQuizzesResponse instance) =>
    <String, dynamic>{
      'status': _$GenerateAllQuizzesStatusEnumMap[instance.status]!,
      'bookId': instance.bookId,
      'chapterCount': instance.chapterCount,
    };

const _$GenerateAllQuizzesStatusEnumMap = {
  GenerateAllQuizzesStatus.PENDING: 'PENDING',
  GenerateAllQuizzesStatus.PROCESSING: 'PROCESSING',
  GenerateAllQuizzesStatus.ALREADY_EXISTS: 'ALREADY_EXISTS',
};
