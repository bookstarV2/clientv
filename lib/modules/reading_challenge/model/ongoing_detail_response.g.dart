// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ongoing_detail_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OngoingDetailResponse _$OngoingDetailResponseFromJson(
        Map<String, dynamic> json) =>
    _OngoingDetailResponse(
      ongoingCount: (json['ongoingCount'] as num?)?.toInt() ?? -1,
      completedCount: (json['completedCount'] as num?)?.toInt() ?? -1,
      challenges: (json['challenges'] as List<dynamic>?)
              ?.map(
                  (e) => ChallengeResponse.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$OngoingDetailResponseToJson(
        _OngoingDetailResponse instance) =>
    <String, dynamic>{
      'ongoingCount': instance.ongoingCount,
      'completedCount': instance.completedCount,
      'challenges': instance.challenges,
    };
