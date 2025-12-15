// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge_detail_book_overview.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChallengeDetailBookOverview _$ChallengeDetailBookOverviewFromJson(
        Map<String, dynamic> json) =>
    _ChallengeDetailBookOverview(
      id: (json['id'] as num?)?.toInt() ?? -1,
      title: json['title'] as String? ?? '',
      author: json['author'] as String? ?? '',
      cover: json['cover'] as String? ?? '',
      readingDiaryCount: (json['readingDiaryCount'] as num?)?.toInt() ?? -1,
      isbn: json['isbn'] as String? ?? '',
      publisher: json['publisher'] as String? ?? '',
      publishedDate: json['publishedDate'] as String? ?? '',
      aladinUrl: json['aladinUrl'] as String? ?? '',
      star: (json['star'] as num?)?.toInt() ?? -1,
      starFromMe: (json['starFromMe'] as num?)?.toInt() ?? -1,
      liked: json['liked'] as bool? ?? false,
    );

Map<String, dynamic> _$ChallengeDetailBookOverviewToJson(
        _ChallengeDetailBookOverview instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'author': instance.author,
      'cover': instance.cover,
      'readingDiaryCount': instance.readingDiaryCount,
      'isbn': instance.isbn,
      'publisher': instance.publisher,
      'publishedDate': instance.publishedDate,
      'aladinUrl': instance.aladinUrl,
      'star': instance.star,
      'starFromMe': instance.starFromMe,
      'liked': instance.liked,
    };
