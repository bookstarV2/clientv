// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_book_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SearchBookResponse _$SearchBookResponseFromJson(Map<String, dynamic> json) =>
    _SearchBookResponse(
      bookId: (json['bookId'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      bookCover: json['bookCover'] as String? ?? '',
      pubDate: json['pubDate'] as String? ?? '',
      author: json['author'] as String? ?? '',
      publisher: json['publisher'] as String? ?? '',
      hasChallenge: json['hasChallenge'] as bool? ?? false,
      hasChapter: json['hasChapter'] as bool? ?? false,
      hasQuiz: json['hasQuiz'] as bool? ?? false,
    );

Map<String, dynamic> _$SearchBookResponseToJson(_SearchBookResponse instance) =>
    <String, dynamic>{
      'bookId': instance.bookId,
      'title': instance.title,
      'bookCover': instance.bookCover,
      'pubDate': instance.pubDate,
      'author': instance.author,
      'publisher': instance.publisher,
      'hasChallenge': instance.hasChallenge,
      'hasChapter': instance.hasChapter,
      'hasQuiz': instance.hasQuiz,
    };
