import 'package:bookstar/modules/learning/data/learning_access.dart';
import 'package:bookstar/modules/learning/data/reading_map_remote.dart';
import 'package:bookstar/modules/learning/data/reading_points.dart';
import 'package:bookstar/modules/learning/view/learning_points_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

ReadingPoints wallet(
        {int balance = 110, List<ReadingPointEntry>? items, int? cursor}) =>
    ReadingPoints(
      balance: balance,
      quizReward: 10,
      createCost: 100,
      refreshCost: 100,
      items: items ??
          [
            entry(3, 'QUIZ_EARN', 10),
            entry(2, 'MAP_REFUND', 100),
            entry(1, 'MAP_RESERVE', -100)
          ],
      nextCursor: cursor,
    );

ReadingPointEntry entry(int id, String kind, int delta) => ReadingPointEntry(
      id: id,
      kind: kind,
      delta: delta,
      createdAt: DateTime(2026, 10, 19, 10),
    );

class PointsRemote extends ReadingMapRemote {
  PointsRemote() : super(Dio());
  int requests = 0;
  bool fail = false;
  final cursors = <int?>[];

  @override
  Future<ReadingPoints> points({int? cursor}) async {
    requests++;
    cursors.add(cursor);
    if (fail) throw StateError('unavailable');
    return cursor == null
        ? wallet(items: [entry(3, 'QUIZ_EARN', 10)], cursor: 3)
        : wallet(items: [
            entry(2, 'MAP_REFUND', 100),
            entry(1, 'MAP_RESERVE', -100)
          ]);
  }
}

void main() {
  test('parses nested history and treats hasNext as the end of pagination', () {
    final points = ReadingPoints.fromJson({
      'balance': 10,
      'quizReward': 10,
      'createCost': 100,
      'refreshCost': 100,
      'history': {
        'data': [
          {
            'id': 7,
            'kind': 'QUIZ_EARN',
            'delta': 10,
            'createdAt': '2026-10-19T10:00:00'
          }
        ],
        'nextCursor': -1,
        'hasNext': false
      },
    });
    expect(points.balance, 10);
    expect(points.items.single.delta, 10);
    expect(points.nextCursor, isNull);
  });

  testWidgets('shows balance, rules and earned, spent and refunded points',
      (tester) async {
    await tester.pumpWidget(ProviderScope(overrides: [
      learningAccountProvider.overrideWithValue(1),
      readingPointsProvider.overrideWith((ref) async => wallet()),
    ], child: const MaterialApp(home: LearningPointsScreen())));
    await tester.pumpAndSettle();
    expect(find.text('110 P'), findsOneWidget);
    expect(find.text('100P'), findsNWidgets(2));
    await tester.scrollUntilVisible(find.text('지도 연결 포인트 반환'), 250);
    expect(find.text('+100P'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('-100P'), 150);
    expect(find.text('지도 연결 요청'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('loads older history once and offers retry when unavailable',
      (tester) async {
    final remote = PointsRemote();
    await tester.pumpWidget(ProviderScope(overrides: [
      learningAccountProvider.overrideWithValue(1),
      readingMapRemoteProvider.overrideWithValue(remote),
    ], child: const MaterialApp(home: LearningPointsScreen())));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('이전 내역 더 보기'), 250);
    remote.fail = true;
    await tester.tap(find.text('이전 내역 더 보기'));
    await tester.pumpAndSettle();
    expect(find.text('이전 내역을 불러오지 못했어요. 다시 시도해 주세요.'), findsOneWidget);
    remote.fail = false;
    await tester.ensureVisible(find.text('이전 내역 더 보기'));
    await tester.tap(find.text('이전 내역 더 보기'));
    await tester.pumpAndSettle();
    expect(remote.cursors, [null, 3, 3]);
    expect(find.text('이전 내역 더 보기'), findsNothing);
    await tester.scrollUntilVisible(find.text('-100P'), 150);
    expect(find.text('-100P'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
