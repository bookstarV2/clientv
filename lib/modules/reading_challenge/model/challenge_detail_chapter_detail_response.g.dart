// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge_detail_chapter_detail_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChallengeDetailChapterDetailResponse
    _$ChallengeDetailChapterDetailResponseFromJson(Map<String, dynamic> json) =>
        _ChallengeDetailChapterDetailResponse(
          chapters: (json['chapters'] as List<dynamic>?)
                  ?.map((e) => ChallengeDetailChapterDetail.fromJson(
                      e as Map<String, dynamic>))
                  .toList() ??
              const [],
        );

Map<String, dynamic> _$ChallengeDetailChapterDetailResponseToJson(
        _ChallengeDetailChapterDetailResponse instance) =>
    <String, dynamic>{
      'chapters': instance.chapters,
    };
