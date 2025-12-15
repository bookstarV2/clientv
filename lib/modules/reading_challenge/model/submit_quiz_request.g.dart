// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'submit_quiz_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SubmitQuizRequest _$SubmitQuizRequestFromJson(Map<String, dynamic> json) =>
    _SubmitQuizRequest(
      choiceId: (json['choiceId'] as num?)?.toInt() ?? -1,
    );

Map<String, dynamic> _$SubmitQuizRequestToJson(_SubmitQuizRequest instance) =>
    <String, dynamic>{
      'choiceId': instance.choiceId,
    };
