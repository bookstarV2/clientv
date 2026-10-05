import 'dart:async';

import 'package:bookstar/modules/learning/data/library_layout.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('missing or invalid stored layout defaults to list', () async {
    for (final value in [null, '', 'unknown', 'twoColumns ']) {
      SharedPreferences.setMockInitialValues({
        if (value != null) LibraryLayoutStore.preferenceKey: value,
      });
      expect(await LibraryLayoutStore().load(), LibraryLayout.list);
    }
  });

  test('the removed three-column choice restores as the 2열 grid', () async {
    SharedPreferences.setMockInitialValues(
        {LibraryLayoutStore.preferenceKey: 'threeColumns'});
    expect(await LibraryLayoutStore().load(), LibraryLayout.twoColumns);
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

  test('toggle switches between 목록 and 2열 and saves each choice', () async {
    final store = _Store();
    final controller = LibraryLayoutController(store);
    addTearDown(controller.dispose);

    await controller.toggle();
    expect(controller.state, LibraryLayout.twoColumns);
    await controller.toggle();
    expect(controller.state, LibraryLayout.list);
    expect(store.saved, [LibraryLayout.twoColumns, LibraryLayout.list]);
  });

  test('late preference restoration never overwrites a newer explicit choice',
      () async {
    final store = _Store()..pendingLoad = Completer<LibraryLayout>();
    final controller = LibraryLayoutController(store);
    addTearDown(controller.dispose);
    await controller.select(LibraryLayout.twoColumns);

    store.pendingLoad!.complete(LibraryLayout.list);
    await Future<void>.delayed(Duration.zero);

    expect(controller.state, LibraryLayout.twoColumns);
    expect(store.saved, [LibraryLayout.twoColumns]);
  });

  test('rapid choices are saved in order with the last selection winning',
      () async {
    final store = _Store()..saveGate = Completer<void>();
    final controller = LibraryLayoutController(store);
    addTearDown(controller.dispose);
    final first = controller.select(LibraryLayout.twoColumns);
    final last = controller.select(LibraryLayout.list);
    store.saveGate!.complete();
    await Future.wait([first, last]);

    expect(controller.state, LibraryLayout.list);
    expect(store.saved, [LibraryLayout.twoColumns, LibraryLayout.list]);
  });

  test('read and write failures keep the library usable', () async {
    final controller = LibraryLayoutController(_Store()
      ..failLoad = true
      ..failSave = true);
    addTearDown(controller.dispose);
    await Future<void>.delayed(Duration.zero);
    expect(controller.state, LibraryLayout.list);

    await controller.select(LibraryLayout.twoColumns);
    expect(controller.state, LibraryLayout.twoColumns);
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
