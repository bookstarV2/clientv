import 'dart:async';

import 'package:bookstar/common/models/response_form.dart';
import 'package:bookstar/common/models/status_response.dart';
import 'package:bookstar/modules/auth/model/policy.dart';
import 'package:bookstar/modules/auth/repository/policy_repository.dart';
import 'package:bookstar/modules/learning/data/learning_access.dart';
import 'package:bookstar/modules/learning/view/learning_design.dart';
import 'package:bookstar/modules/learning/view/learning_entry_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('required agreements start unchecked and need separate choices',
      (tester) async {
    await _pumpEntry(tester, _PolicyRepository());
    expect(_checkboxes(tester), [false, false]);
    await _reveal(tester, find.text('동의하고 계속하기'));
    expect(_saveButton(tester).onPressed, isNull);
    await _check(tester, 0);
    expect(_checkboxes(tester), [true, false]);
    await _reveal(tester, find.text('동의하고 계속하기'));
    expect(_saveButton(tester).onPressed, isNull);
    await _check(tester, 1);
    await _reveal(tester, find.text('동의하고 계속하기'));
    expect(_saveButton(tester).onPressed, isNotNull);
  });

  for (final marketing in PolicyAgree.values) {
    testWidgets('saving required choices preserves marketing $marketing',
        (tester) async {
      final repository =
          _PolicyRepository(policy: Policy(marketingAgree: marketing));
      await _pumpEntry(tester, repository);
      await _check(tester, 0);
      await _check(tester, 1);
      await _reveal(tester, find.text('동의하고 계속하기'));
      await tester.tap(find.text('동의하고 계속하기'));
      await tester.pumpAndSettle();
      expect(repository.saved, hasLength(1));
      expect(
          repository.saved.single,
          Policy(
            serviceUsingAgree: PolicyAgree.Y,
            personalInformationAgree: PolicyAgree.Y,
            marketingAgree: marketing,
          ));
      expect(repository.loads, greaterThanOrEqualTo(2));
      expect(find.text('동의 저장 확인'), findsOneWidget);
    });
  }

  testWidgets('save failure keeps selected checks and can be retried',
      (tester) async {
    final repository = _PolicyRepository()..failSaves = 1;
    await _pumpEntry(tester, repository);
    await _check(tester, 0);
    await _check(tester, 1);
    await _reveal(tester, find.text('동의하고 계속하기'));
    await tester.tap(find.text('동의하고 계속하기'));
    await tester.pumpAndSettle();
    expect(_checkboxes(tester), [true, true]);
    expect(find.text('동의 저장 확인'), findsNothing);
    await _reveal(tester, find.text('동의하고 계속하기'));
    await tester.tap(find.text('동의하고 계속하기'));
    await tester.pumpAndSettle();
    expect(repository.saved, hasLength(2));
    expect(repository.saved.first, repository.saved.last);
    expect(find.text('동의 저장 확인'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pending save disables repeated submission and checkbox changes',
      (tester) async {
    final repository = _PolicyRepository()..saveGate = Completer<void>();
    await _pumpEntry(tester, repository);
    await _check(tester, 0);
    await _check(tester, 1);
    await _reveal(tester, find.text('동의하고 계속하기'));
    await tester.tap(find.text('동의하고 계속하기'));
    await tester.pump();
    expect(_saveButton(tester).onPressed, isNull);
    expect(
        tester
            .widgetList<CheckboxListTile>(find.byType(CheckboxListTile))
            .every((tile) => tile.onChanged == null),
        isTrue);
    expect(repository.saved, hasLength(1));
    repository.saveGate!.complete();
    await tester.pumpAndSettle();
    expect(find.text('동의 저장 확인'), findsOneWidget);
  });

  testWidgets('policy load failure offers retry without assuming agreement',
      (tester) async {
    final repository = _PolicyRepository()..failLoads = 1;
    await _pumpEntry(tester, repository);
    expect(find.text('불러오지 못했어요'), findsOneWidget);
    expect(find.byType(CheckboxListTile), findsNothing);
    await tester.tap(find.text('다시 불러오기'));
    await tester.pumpAndSettle();
    expect(repository.loads, 2);
    expect(_checkboxes(tester), [false, false]);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      '320px double-size text can read and submit both required choices',
      (tester) async {
    await _pumpEntry(tester, _PolicyRepository(), scale: 2);
    expect(tester.takeException(), isNull);
    await _check(tester, 0);
    await _check(tester, 1);
    await _reveal(tester, find.text('동의하고 계속하기'));
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('동의하고 계속하기'));
    await tester.pumpAndSettle();
    expect(find.text('동의 저장 확인'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _PolicyRepository implements PolicyRepository {
  _PolicyRepository({this.policy = const Policy()});
  Policy policy;
  int loads = 0;
  int failLoads = 0;
  int failSaves = 0;
  Completer<void>? saveGate;
  final List<Policy> saved = [];

  @override
  Future<ResponseForm<Policy>> getPolicy() async {
    loads++;
    if (failLoads-- > 0) throw StateError('test policy load failure');
    return ResponseForm(
        statusResponse:
            const StatusResponse(resultCode: 'OK', resultMessage: 'OK'),
        data: policy);
  }

  @override
  Future<ResponseForm<void>> updatePolicy(Policy body) async {
    saved.add(body);
    if (failSaves-- > 0) {
      throw DioException(
          requestOptions: RequestOptions(path: '/policy'),
          type: DioExceptionType.receiveTimeout);
    }
    await saveGate?.future;
    policy = body;
    return const ResponseForm(
        statusResponse: StatusResponse(resultCode: 'OK', resultMessage: 'OK'),
        data: null);
  }
}

List<bool?> _checkboxes(WidgetTester tester) => tester
    .widgetList<CheckboxListTile>(find.byType(CheckboxListTile))
    .map((tile) => tile.value)
    .toList();

FilledButton _saveButton(WidgetTester tester) =>
    tester.widget<FilledButton>(find.byType(FilledButton));

Future<void> _check(WidgetTester tester, int index) async {
  final label =
      index == 0 ? find.text('서비스 이용약관 (필수)') : find.text('개인정보 수집 및 이용 (필수)');
  await _reveal(tester, label);
  await tester.tap(label);
  await tester.pumpAndSettle();
}

Future<void> _pumpEntry(WidgetTester tester, _PolicyRepository repository,
    {double scale = 1}) async {
  tester.view.physicalSize = const Size(320, 568);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(ProviderScope(
    overrides: [
      learningAccountProvider.overrideWithValue(1),
      policyRepositoryProvider.overrideWithValue(repository),
    ],
    child: MaterialApp(
      theme: LearningColors.theme,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: Consumer(builder: (context, ref, child) {
        final policy = ref.watch(learningPolicyProvider).valueOrNull;
        return hasRequiredLearningPolicy(policy)
            ? const Scaffold(body: Text('동의 저장 확인'))
            : const LearningEntryScreen();
      }),
    ),
  ));
  await tester.pumpAndSettle();
}

Future<void> _reveal(WidgetTester tester, Finder finder) async {
  final scrollable = find.byType(Scrollable).first;
  tester.state<ScrollableState>(scrollable).position.jumpTo(0);
  await tester.pump();
  await tester.scrollUntilVisible(finder, 130,
      scrollable: scrollable, maxScrolls: 40);
  await tester.pumpAndSettle();
}
