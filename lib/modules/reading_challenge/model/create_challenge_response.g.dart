// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_challenge_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateChallengeResponse _$CreateChallengeResponseFromJson(
        Map<String, dynamic> json) =>
    _CreateChallengeResponse(
      challengeId: (json['challengeId'] as num?)?.toInt() ?? -1,
      quizGenerationStatus: $enumDecodeNullable(
              _$QuizGenerationStatusEnumMap, json['quizGenerationStatus']) ??
          QuizGenerationStatus.PROCESSING,
      alreadyExists: json['alreadyExists'] as bool? ?? false,
      hasChapter: json['hasChapter'] as bool? ?? false,
    );

Map<String, dynamic> _$CreateChallengeResponseToJson(
        _CreateChallengeResponse instance) =>
    <String, dynamic>{
      'challengeId': instance.challengeId,
      'quizGenerationStatus':
          _$QuizGenerationStatusEnumMap[instance.quizGenerationStatus]!,
      'alreadyExists': instance.alreadyExists,
      'hasChapter': instance.hasChapter,
    };

const _$QuizGenerationStatusEnumMap = {
  QuizGenerationStatus.PROCESSING: 'PROCESSING',
  QuizGenerationStatus.ALREADY_EXISTS: 'ALREADY_EXISTS',
};
