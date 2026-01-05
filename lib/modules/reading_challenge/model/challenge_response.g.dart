// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChallengeResponse _$ChallengeResponseFromJson(Map<String, dynamic> json) =>
    _ChallengeResponse(
      challengeId: (json['challengeId'] as num?)?.toInt() ?? -1,
      bookId: (json['bookId'] as num?)?.toInt() ?? -1,
      bookTitle: json['bookTitle'] as String? ?? '',
      bookAuthor: json['bookAuthor'] as String? ?? '',
      bookImageUrl: json['bookImageUrl'] as String? ?? '',
      totalPages: (json['totalPages'] as num?)?.toInt() ?? -1,
      totalChapters: (json['totalChapters'] as num?)?.toInt() ?? -1,
      completed: json['completed'] as bool? ?? false,
      abandoned: json['abandoned'] as bool? ?? false,
      completedAt: json['completedAt'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      hasQuiz: json['hasQuiz'] as bool? ?? false,
      progressRate: (json['progressRate'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$ChallengeResponseToJson(_ChallengeResponse instance) =>
    <String, dynamic>{
      'challengeId': instance.challengeId,
      'bookId': instance.bookId,
      'bookTitle': instance.bookTitle,
      'bookAuthor': instance.bookAuthor,
      'bookImageUrl': instance.bookImageUrl,
      'totalPages': instance.totalPages,
      'totalChapters': instance.totalChapters,
      'completed': instance.completed,
      'abandoned': instance.abandoned,
      'completedAt': instance.completedAt,
      'createdAt': instance.createdAt,
      'hasQuiz': instance.hasQuiz,
      'progressRate': instance.progressRate,
    };
