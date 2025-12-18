// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ranking_weekly_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RankingWeeklyResponse _$RankingWeeklyResponseFromJson(
        Map<String, dynamic> json) =>
    _RankingWeeklyResponse(
      rank: (json['rank'] as num?)?.toInt() ?? -1,
      memberId: (json['memberId'] as num?)?.toInt() ?? -1,
      nickname: json['nickname'] as String? ?? "",
      profileImage: json['profileImage'] as String? ?? "",
      participationDays: (json['participationDays'] as num?)?.toInt() ?? -1,
      solvedCount: (json['solvedCount'] as num?)?.toInt() ?? -1,
      correctCount: (json['correctCount'] as num?)?.toInt() ?? -1,
      myRank: json['myRank'] as bool? ?? false,
    );

Map<String, dynamic> _$RankingWeeklyResponseToJson(
        _RankingWeeklyResponse instance) =>
    <String, dynamic>{
      'rank': instance.rank,
      'memberId': instance.memberId,
      'nickname': instance.nickname,
      'profileImage': instance.profileImage,
      'participationDays': instance.participationDays,
      'solvedCount': instance.solvedCount,
      'correctCount': instance.correctCount,
      'myRank': instance.myRank,
    };
