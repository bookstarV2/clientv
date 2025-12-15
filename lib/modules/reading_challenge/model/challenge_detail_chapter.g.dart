// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge_detail_chapter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChallengeDetailChapter _$ChallengeDetailChapterFromJson(
        Map<String, dynamic> json) =>
    _ChallengeDetailChapter(
      chapterId: (json['chapterId'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      chapterNumber: (json['chapterNumber'] as num?)?.toInt() ?? 0,
      status: $enumDecodeNullable(_$ChapterStatusEnumMap, json['status']) ??
          ChapterStatus.LOCKED,
    );

Map<String, dynamic> _$ChallengeDetailChapterToJson(
        _ChallengeDetailChapter instance) =>
    <String, dynamic>{
      'chapterId': instance.chapterId,
      'title': instance.title,
      'chapterNumber': instance.chapterNumber,
      'status': _$ChapterStatusEnumMap[instance.status]!,
    };

const _$ChapterStatusEnumMap = {
  ChapterStatus.COMPLETED: 'COMPLETED',
  ChapterStatus.PROCESSING: 'PROCESSING',
  ChapterStatus.LOCKED: 'LOCKED',
};
