import 'dart:async';

import 'package:bookstar/common/models/response_form.dart';
import 'package:bookstar/common/models/status_response.dart';
import 'package:bookstar/modules/auth/model/policy.dart';
import 'package:bookstar/modules/auth/repository/policy_repository.dart';
import 'package:bookstar/modules/learning/data/learning_access.dart';
import 'package:bookstar/modules/learning/view/learning_design.dart';
import 'package:bookstar/modules/learning/view/learning_notification_settings_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final _account = StateProvider<int?>((ref) => 1);
const _ok = StatusResponse(resultCode: 'OK', resultMessage: 'OK');

void main() {
  for (final marketing in PolicyAgree.values) {
    testWidgets('loads actual marketing $marketing without implicit changes',
        (tester) async {
      final api = _Policies(Policy(marketingAgree: marketing));
      await _pump(tester, api);
      await _reveal(tester, find.byType(SwitchListTile));
      expect(_switch(tester).value, marketing == PolicyAgree.Y);
      await _reveal(tester, find.text('변경 내용 저장'));
      expect(_save(tester).onPressed, isNull);
      expect(api.saved, isEmpty);
    });
  }

  testWidgets('unavailable policy is unknown, not an editable default off',
      (tester) async {
    final api = _Policies(const Policy(marketingAgree: PolicyAgree.Y))
      ..failLoads = 1;
    await _pump(tester, api);
    expect(find.byType(SwitchListTile), findsNothing);
    await tester.tap(find.text('다시 불러오기'));
    await tester.pumpAndSettle();
    await _reveal(tester, find.byType(SwitchListTile));
    expect(_switch(tester).value, isTrue);
    expect(api.saved, isEmpty);
  });

  testWidgets('save rereads current required flags and changes marketing only',
      (tester) async {
    final api = _Policies(const Policy(marketingAgree: PolicyAgree.Y));
    await _pump(tester, api);
    await _toggle(tester);
    api.current = const Policy(
        serviceUsingAgree: PolicyAgree.Y,
        personalInformationAgree: PolicyAgree.Y,
        marketingAgree: PolicyAgree.Y);
    await _reveal(tester, find.text('변경 내용 저장'));
    await tester.tap(find.text('변경 내용 저장'));
    await tester.pumpAndSettle();
    expect(
        api.saved.single,
        const Policy(
            serviceUsingAgree: PolicyAgree.Y,
            personalInformationAgree: PolicyAgree.Y,
            marketingAgree: PolicyAgree.N));
    expect(api.loads, 2);
    expect(find.text('수신 동의 설정을 저장했어요.'), findsOneWidget);
    await _reveal(tester, find.text('현재 저장된 설정: 동의 안 함'));
    expect(find.text('변경한 설정은 아직 저장되지 않았어요.'), findsNothing);
  });

  testWidgets(
      'uncertain save keeps draft and reload reconciles committed value',
      (tester) async {
    final api = _Policies(const Policy(marketingAgree: PolicyAgree.Y))
      ..commitThenTimeout = true;
    await _pump(tester, api);
    await _toggle(tester);
    await _reveal(tester, find.text('변경 내용 저장'));
    await tester.tap(find.text('변경 내용 저장'));
    await tester.pumpAndSettle();
    await _reveal(tester, find.text('현재 저장된 설정: 동의'));
    expect(find.text('현재 저장된 설정: 동의'), findsOneWidget);
    await _reveal(tester, find.byType(SwitchListTile));
    expect(_switch(tester).value, isFalse);
    await _reveal(tester, find.text('저장된 설정 다시 불러오기'));
    await tester.tap(find.text('저장된 설정 다시 불러오기'));
    await tester.pumpAndSettle();
    await _reveal(tester, find.text('현재 저장된 설정: 동의 안 함'));
    expect(find.text('변경한 설정은 아직 저장되지 않았어요.'), findsNothing);
    expect(find.text('저장된 설정 다시 불러오기'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pending save disables controls and does not duplicate requests',
      (tester) async {
    final api = _Policies(const Policy())..saveGate = Completer<void>();
    await _pump(tester, api);
    await _toggle(tester);
    await _reveal(tester, find.text('변경 내용 저장'));
    await tester.tap(find.text('변경 내용 저장'));
    await tester.pump();
    expect(_save(tester).onPressed, isNull);
    expect(api.saved, hasLength(1));
    await _reveal(tester, find.byType(SwitchListTile));
    expect(_switch(tester).onChanged, isNull);
    api.saveGate!.complete();
    await tester.pumpAndSettle();
    expect(api.saved, hasLength(1));
  });

  testWidgets(
      'account change during pre-save lookup prevents writing stale intent',
      (tester) async {
    final api = _Policies(const Policy());
    final container = await _pump(tester, api);
    await _toggle(tester);
    api.loadGate = Completer<void>();
    await _reveal(tester, find.text('변경 내용 저장'));
    await tester.tap(find.text('변경 내용 저장'));
    await tester.pump();
    container.read(_account.notifier).state = 2;
    api.loadGate!.complete();
    await tester.pumpAndSettle();
    expect(api.saved, isEmpty);
    expect(find.text('수신 동의 설정을 저장했어요.'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'marketing settings remain operable at 320px with double-size text',
      (tester) async {
    final api = _Policies(const Policy());
    await _pump(tester, api, scale: 2);
    await _toggle(tester);
    await _reveal(tester, find.text('변경 내용 저장'));
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('변경 내용 저장'));
    await tester.pumpAndSettle();
    expect(api.saved.single.marketingAgree, PolicyAgree.Y);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'account replacement clears old consent and loads the new account',
      (tester) async {
    final api = _Policies(const Policy(marketingAgree: PolicyAgree.Y));
    final container = await _pump(tester, api);
    api.current = const Policy(marketingAgree: PolicyAgree.N);
    container.read(_account.notifier).state = 2;
    await tester.pumpAndSettle();
    await _reveal(tester, find.byType(SwitchListTile));
    expect(_switch(tester).value, isFalse,
        reason:
            'A previously loaded consent must not become account B\'s draft');
    expect(api.loads, 2);
    expect(api.saved, isEmpty);
    await _reveal(tester, find.text('변경 내용 저장'));
    expect(_save(tester).onPressed, isNull);
  });
  testWidgets('late failed lookup cannot clear a newer account loading state',
      (tester) async {
    final api = _Policies(const Policy(marketingAgree: PolicyAgree.Y));
    final container = await _pump(tester, api);
    final older = Completer<ResponseForm<Policy>>();
    final newer = Completer<ResponseForm<Policy>>();
    api.queuedLoads.addAll([older, newer]);
    container.read(_account.notifier).state = 2;
    await tester.pump();
    container.read(_account.notifier).state = 3;
    await tester.pump();
    expect(api.loads, 3);

    older.completeError(StateError('old account lookup failed'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget,
        reason:
            'The old finally must not stop the new account request spinner');
    expect(find.byType(LearningError), findsNothing);
    expect(find.byType(SwitchListTile), findsNothing);

    newer.complete(const ResponseForm(
        statusResponse: _ok, data: Policy(marketingAgree: PolicyAgree.N)));
    await tester.pumpAndSettle();
    await _reveal(tester, find.byType(SwitchListTile));
    expect(_switch(tester).value, isFalse);
    expect(find.byType(LearningError), findsNothing);
    expect(api.saved, isEmpty);
    expect(tester.takeException(), isNull);
  });
}

class _Policies implements PolicyRepository {
  _Policies(this.current);
  Policy current;
  int loads = 0;
  int failLoads = 0;
  bool commitThenTimeout = false;
  Completer<void>? loadGate;
  Completer<void>? saveGate;
  final queuedLoads = <Completer<ResponseForm<Policy>>>[];
  final saved = <Policy>[];
  @override
  Future<ResponseForm<Policy>> getPolicy() async {
    loads++;
    if (queuedLoads.isNotEmpty) return queuedLoads.removeAt(0).future;
    if (failLoads-- > 0) throw StateError('test load failure');
    await loadGate?.future;
    return ResponseForm(statusResponse: _ok, data: current);
  }

  @override
  Future<ResponseForm<void>> updatePolicy(Policy body) async {
    saved.add(body);
    await saveGate?.future;
    current = body;
    if (commitThenTimeout) {
      throw DioException(
          requestOptions: RequestOptions(path: '/policy'),
          type: DioExceptionType.receiveTimeout);
    }
    return const ResponseForm(statusResponse: _ok, data: null);
  }
}

SwitchListTile _switch(WidgetTester tester) =>
    tester.widget<SwitchListTile>(find.byType(SwitchListTile));
FilledButton _save(WidgetTester tester) =>
    tester.widget<FilledButton>(find.byType(FilledButton));
Future<void> _toggle(WidgetTester tester) async {
  await _reveal(tester, find.byType(SwitchListTile));
  await tester.tap(find.byType(SwitchListTile));
  await tester.pumpAndSettle();
}

Future<ProviderContainer> _pump(WidgetTester tester, _Policies api,
    {double scale = 1}) async {
  tester.view.physicalSize = const Size(320, 568);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final container = ProviderContainer(overrides: [
    learningAccountProvider.overrideWith((ref) => ref.watch(_account)),
    policyRepositoryProvider.overrideWithValue(api),
  ]);
  addTearDown(container.dispose);
  await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
          theme: LearningColors.theme,
          builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(scale)),
              child: child!),
          home: const LearningNotificationSettingsScreen())));
  await tester.pumpAndSettle();
  return container;
}

Future<void> _reveal(WidgetTester tester, Finder finder) async {
  final scrollable = find.byType(Scrollable).first;
  tester.state<ScrollableState>(scrollable).position.jumpTo(0);
  await tester.pump();
  await tester.scrollUntilVisible(finder, 140,
      scrollable: scrollable, maxScrolls: 40);
  await tester.pumpAndSettle();
}
