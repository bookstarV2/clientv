// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'completed_detail_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CompletedDetailResponse _$CompletedDetailResponseFromJson(
        Map<String, dynamic> json) =>
    _CompletedDetailResponse(
      completedCount: (json['completedCount'] as num?)?.toInt() ?? -1,
      challenges: (json['challenges'] as List<dynamic>?)
              ?.map(
                  (e) => ChallengeResponse.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$CompletedDetailResponseToJson(
        _CompletedDetailResponse instance) =>
    <String, dynamic>{
      'completedCount': instance.completedCount,
      'challenges': instance.challenges,
    };
