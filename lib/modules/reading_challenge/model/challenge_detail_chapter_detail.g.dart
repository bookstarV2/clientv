// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge_detail_chapter_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChallengeDetailChapterDetail _$ChallengeDetailChapterDetailFromJson(
        Map<String, dynamic> json) =>
    _ChallengeDetailChapterDetail(
      chapterId: (json['chapterId'] as num?)?.toInt() ?? -1,
      chapterNumber: (json['chapterNumber'] as num?)?.toInt() ?? -1,
      chapterTitle: json['chapterTitle'] as String? ?? '',
      quizId: (json['quizId'] as num?)?.toInt() ?? -1,
      question: json['question'] as String? ?? '',
      choices: (json['choices'] as List<dynamic>?)
              ?.map((e) => QuizChoice.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      totalAttempts: (json['totalAttempts'] as num?)?.toInt() ?? -1,
      createdAt: json['createdAt'] as String? ?? '',
    );

Map<String, dynamic> _$ChallengeDetailChapterDetailToJson(
        _ChallengeDetailChapterDetail instance) =>
    <String, dynamic>{
      'chapterId': instance.chapterId,
      'chapterNumber': instance.chapterNumber,
      'chapterTitle': instance.chapterTitle,
      'quizId': instance.quizId,
      'question': instance.question,
      'choices': instance.choices,
      'totalAttempts': instance.totalAttempts,
      'createdAt': instance.createdAt,
    };
