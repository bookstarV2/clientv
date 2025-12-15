// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'choice_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChoiceResult _$ChoiceResultFromJson(Map<String, dynamic> json) =>
    _ChoiceResult(
      choiceId: (json['choiceId'] as num?)?.toInt() ?? -1,
      choiceText: json['choiceText'] as String? ?? '',
      isCorrect: json['isCorrect'] as bool? ?? false,
      explanation: json['explanation'] as String? ?? '',
      isSelected: json['isSelected'] as bool? ?? false,
    );

Map<String, dynamic> _$ChoiceResultToJson(_ChoiceResult instance) =>
    <String, dynamic>{
      'choiceId': instance.choiceId,
      'choiceText': instance.choiceText,
      'isCorrect': instance.isCorrect,
      'explanation': instance.explanation,
      'isSelected': instance.isSelected,
    };
