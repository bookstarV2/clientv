// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge_success_detail_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChallengeSuccessDetailResponse _$ChallengeSuccessDetailResponseFromJson(
        Map<String, dynamic> json) =>
    _ChallengeSuccessDetailResponse(
      totalTime: (json['totalTime'] as num?)?.toInt() ?? -1,
      totalCollect: (json['totalCollect'] as num?)?.toInt() ?? -1,
      readingSpeedPerMinute:
          (json['readingSpeedPerMinute'] as num?)?.toInt() ?? -1,
      bookTitle: json['bookTitle'] as String? ?? '',
      bookAuthor: json['bookAuthor'] as String? ?? '',
      bookCover: json['bookCover'] as String? ?? '',
      bookPublisher: json['bookPublisher'] as String? ?? '',
    );

Map<String, dynamic> _$ChallengeSuccessDetailResponseToJson(
        _ChallengeSuccessDetailResponse instance) =>
    <String, dynamic>{
      'totalTime': instance.totalTime,
      'totalCollect': instance.totalCollect,
      'readingSpeedPerMinute': instance.readingSpeedPerMinute,
      'bookTitle': instance.bookTitle,
      'bookAuthor': instance.bookAuthor,
      'bookCover': instance.bookCover,
      'bookPublisher': instance.bookPublisher,
    };
