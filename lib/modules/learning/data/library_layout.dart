import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 2.1 내 서재 보기 방식: 목록 / 2열 토글.
enum LibraryLayout {
  list('목록'),
  twoColumns('2열');

  const LibraryLayout(this.label);
  final String label;

  LibraryLayout get toggled => this == list ? twoColumns : list;

  /// Unknown values fall back to the list; the removed 3열 keeps a grid.
  static LibraryLayout parse(String? value) => switch (value) {
        'twoColumns' || 'threeColumns' => twoColumns,
        _ => list,
      };
}

class LibraryLayoutStore {
  static const preferenceKey = 'learning.library.layout';

  Future<LibraryLayout> load() async => LibraryLayout.parse(
      (await SharedPreferences.getInstance()).getString(preferenceKey));

  Future<void> save(LibraryLayout layout) async {
    final saved = await (await SharedPreferences.getInstance())
        .setString(preferenceKey, layout.name);
    if (!saved) throw StateError('Library layout preference was not saved');
  }
}

final libraryLayoutStoreProvider =
    Provider<LibraryLayoutStore>((ref) => LibraryLayoutStore());

final libraryLayoutProvider =
    StateNotifierProvider<LibraryLayoutController, LibraryLayout>(
        (ref) => LibraryLayoutController(ref.read(libraryLayoutStoreProvider)));

class LibraryLayoutController extends StateNotifier<LibraryLayout> {
  LibraryLayoutController(this._store) : super(LibraryLayout.list) {
    unawaited(_restore());
  }

  final LibraryLayoutStore _store;
  bool _chosen = false;
  Future<void> _writes = Future<void>.value();

  Future<void> _restore() async {
    try {
      final saved = await _store.load();
      if (mounted && !_chosen) state = saved;
    } catch (_) {
      // An unreadable preference keeps the default list.
    }
  }

  /// Applies [layout] at once; persisting it for the next launch is best
  /// effort and writes are kept in order.
  Future<void> select(LibraryLayout layout) async {
    _chosen = true;
    state = layout;
    _writes = _writes.catchError((_) {}).then((_) => _store.save(layout));
    try {
      await _writes;
    } catch (_) {
      // The choice still applies for this session.
    }
  }

  Future<void> toggle() => select(state.toggled);
}
