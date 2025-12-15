// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_reading_timer_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PostReadingTimerRequest _$PostReadingTimerRequestFromJson(
        Map<String, dynamic> json) =>
    _PostReadingTimerRequest(
      challengeId: (json['challengeId'] as num?)?.toInt() ?? -1,
      seconds: (json['seconds'] as num?)?.toInt() ?? -1,
    );

Map<String, dynamic> _$PostReadingTimerRequestToJson(
        _PostReadingTimerRequest instance) =>
    <String, dynamic>{
      'challengeId': instance.challengeId,
      'seconds': instance.seconds,
    };
