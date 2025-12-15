// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_choice.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_QuizChoice _$QuizChoiceFromJson(Map<String, dynamic> json) => _QuizChoice(
      choiceId: (json['choiceId'] as num?)?.toInt() ?? -1,
      choiceOrder: (json['choiceOrder'] as num?)?.toInt() ?? -1,
      choiceText: json['choiceText'] as String? ?? '',
    );

Map<String, dynamic> _$QuizChoiceToJson(_QuizChoice instance) =>
    <String, dynamic>{
      'choiceId': instance.choiceId,
      'choiceOrder': instance.choiceOrder,
      'choiceText': instance.choiceText,
    };
