import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'learning_access.dart';
import 'reading_map_remote.dart';

final readingPointsProvider = FutureProvider.autoDispose<ReadingPoints>((ref) {
  if (ref.watch(learningAccountProvider) == null) {
    throw StateError('Sign in required');
  }
  return ref.watch(readingMapRemoteProvider).points();
});

class ReadingPoints {
  const ReadingPoints({
    required this.balance,
    required this.quizReward,
    required this.createCost,
    required this.refreshCost,
    required this.items,
    this.nextCursor,
  });

  final int balance;
  final int quizReward;
  final int createCost;
  final int refreshCost;
  final List<ReadingPointEntry> items;
  final int? nextCursor;

  factory ReadingPoints.fromJson(Map<String, dynamic> json) => ReadingPoints(
        balance: (json['balance'] as num).toInt(),
        quizReward: (json['quizReward'] as num).toInt(),
        createCost: (json['createCost'] as num).toInt(),
        refreshCost: (json['refreshCost'] as num).toInt(),
        items:
            ((json['history'] as Map<String, dynamic>)['data'] as List<dynamic>)
                .map((item) =>
                    ReadingPointEntry.fromJson(item as Map<String, dynamic>))
                .toList(),
        nextCursor: (json['history'] as Map<String, dynamic>)['hasNext'] == true
            ? ((json['history'] as Map<String, dynamic>)['nextCursor'] as num)
                .toInt()
            : null,
      );
}

class ReadingPointEntry {
  const ReadingPointEntry(
      {required this.id,
      required this.kind,
      required this.delta,
      required this.createdAt});

  final int id;
  final String kind;
  final int delta;
  final DateTime createdAt;

  String get label => switch (kind) {
        'QUIZ_EARN' => '퀴즈 첫 풀이 적립',
        'MAP_RESERVE' => '지도 연결 요청',
        'MAP_REFUND' => '지도 연결 포인트 반환',
        _ => '포인트 내역',
      };

  factory ReadingPointEntry.fromJson(Map<String, dynamic> json) =>
      ReadingPointEntry(
        id: (json['id'] as num).toInt(),
        kind: json['kind'] as String,
        delta: (json['delta'] as num).toInt(),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
