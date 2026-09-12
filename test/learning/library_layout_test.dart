import 'dart:async';

import 'package:bookstar/modules/learning/data/library_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('missing or invalid stored layout defaults to list', () async {
    for (final value in [null, '', 'unknown', 'threeColumns ']) {
      SharedPreferences.setMockInitialValues({
        if (value != null) LibraryLayoutStore.preferenceKey: value,
      });
      expect(await LibraryLayoutStore().load(), LibraryLayout.list);
    }
  });

  test('only a layout name is persisted and restored by a new store', () async {
    for (final layout in LibraryLayout.values) {
      await LibraryLayoutStore().save(layout);
      expect(await LibraryLayoutStore().load(), layout);
      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getKeys(), {LibraryLayoutStore.preferenceKey});
      expect(
          preferences.getString(LibraryLayoutStore.preferenceKey), layout.name);
    }
  });

  test('late preference restoration never overwrites a newer explicit choice',
      () async {
    final store = _Store()..pendingLoad = Completer<LibraryLayout>();
    final controller = LibraryLayoutController(store);
    addTearDown(controller.dispose);
    await controller.select(LibraryLayout.threeColumns);

    store.pendingLoad!.complete(LibraryLayout.twoColumns);
    await Future<void>.delayed(Duration.zero);

    expect(controller.state.preferred, LibraryLayout.threeColumns);
    expect(store.saved, [LibraryLayout.threeColumns]);
  });

  test('rapid choices are saved in order with the last selection winning',
      () async {
    final store = _Store()..saveGate = Completer<void>();
    final controller = LibraryLayoutController(store);
    addTearDown(controller.dispose);
    final first = controller.select(LibraryLayout.twoColumns);
    final last = controller.select(LibraryLayout.threeColumns);
    store.saveGate!.complete();
    await Future.wait([first, last]);

    expect(controller.state.preferred, LibraryLayout.threeColumns);
    expect(store.saved, [LibraryLayout.twoColumns, LibraryLayout.threeColumns]);
  });

  test('read failure keeps list usable and reports the setting failure',
      () async {
    final controller = LibraryLayoutController(_Store()..failLoad = true);
    addTearDown(controller.dispose);
    await Future<void>.delayed(Duration.zero);

    expect(controller.state.preferred, LibraryLayout.list);
    expect(controller.state.notice, contains('읽지 못했어요'));
    await controller.select(LibraryLayout.twoColumns);
    expect(controller.state.preferred, LibraryLayout.twoColumns);
    expect(controller.state.notice, isNull);
  });

  test('failed save keeps current selection without claiming persistence',
      () async {
    final controller = LibraryLayoutController(_Store()..failSave = true);
    addTearDown(controller.dispose);

    await controller.select(LibraryLayout.threeColumns);

    expect(controller.state.preferred, LibraryLayout.threeColumns);
    expect(controller.state.notice, contains('저장하지 못했어요'));
  });

  test(
      'effective layout follows measured width and scaling without changing preference',
      () {
    LibraryLayout layout(double width, double scale) =>
        effectiveLibraryLayout(LibraryLayout.threeColumns,
            availableWidth: width,
            textScaler: TextScaler.linear(scale),
            textDirection: TextDirection.ltr);

    expect(layout(280, 1), LibraryLayout.threeColumns);
    expect(layout(280, 1.5), LibraryLayout.twoColumns);
    expect(layout(280, 3), LibraryLayout.list);
    expect(layout(280, 1), LibraryLayout.threeColumns);
    expect(layout(600, 1.5), LibraryLayout.threeColumns);
  });
}

class _Store extends LibraryLayoutStore {
  Completer<LibraryLayout>? pendingLoad;
  Completer<void>? saveGate;
  bool failLoad = false;
  bool failSave = false;
  final saved = <LibraryLayout>[];

  @override
  Future<LibraryLayout> load() async {
    if (failLoad) throw StateError('isolated read failure');
    return await pendingLoad?.future ?? LibraryLayout.list;
  }

  @override
  Future<void> save(LibraryLayout layout) async {
    await saveGate?.future;
    if (failSave) throw StateError('isolated write failure');
    saved.add(layout);
  }
}
