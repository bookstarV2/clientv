// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge_detail_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChallengeDetailResponse _$ChallengeDetailResponseFromJson(
        Map<String, dynamic> json) =>
    _ChallengeDetailResponse(
      bookOverview: json['bookOverview'] == null
          ? const ChallengeDetailBookOverview()
          : ChallengeDetailBookOverview.fromJson(
              json['bookOverview'] as Map<String, dynamic>),
      chapters: (json['chapters'] as List<dynamic>?)
              ?.map((e) =>
                  ChallengeDetailChapter.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ChallengeDetailResponseToJson(
        _ChallengeDetailResponse instance) =>
    <String, dynamic>{
      'bookOverview': instance.bookOverview,
      'chapters': instance.chapters,
    };
