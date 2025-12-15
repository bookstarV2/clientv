// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'submit_quiz_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SubmitQuizResponse _$SubmitQuizResponseFromJson(Map<String, dynamic> json) =>
    _SubmitQuizResponse(
      quizId: (json['quizId'] as num?)?.toInt() ?? -1,
      attemptId: (json['attemptId'] as num?)?.toInt() ?? -1,
      isCorrect: json['isCorrect'] as bool? ?? false,
      selectedChoiceId: (json['selectedChoiceId'] as num?)?.toInt() ?? -1,
      correctChoiceId: (json['correctChoiceId'] as num?)?.toInt() ?? -1,
      choiceResults: (json['choiceResults'] as List<dynamic>?)
              ?.map((e) => ChoiceResult.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      totalAttempts: (json['totalAttempts'] as num?)?.toInt() ?? -1,
      correctRate: (json['correctRate'] as num?)?.toDouble() ?? 0.0,
      isChallengeCompleted: json['isChallengeCompleted'] as bool? ?? false,
    );

Map<String, dynamic> _$SubmitQuizResponseToJson(_SubmitQuizResponse instance) =>
    <String, dynamic>{
      'quizId': instance.quizId,
      'attemptId': instance.attemptId,
      'isCorrect': instance.isCorrect,
      'selectedChoiceId': instance.selectedChoiceId,
      'correctChoiceId': instance.correctChoiceId,
      'choiceResults': instance.choiceResults,
      'totalAttempts': instance.totalAttempts,
      'correctRate': instance.correctRate,
      'isChallengeCompleted': instance.isChallengeCompleted,
    };
