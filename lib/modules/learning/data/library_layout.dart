import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum LibraryLayout {
  list('목록', '제목과 저자를 편하게', 1),
  twoColumns('2열', '표지를 크게', 2),
  threeColumns('3열', '더 많은 책을 한눈에', 3);

  const LibraryLayout(this.label, this.description, this.columns);
  final String label;
  final String description;
  final int columns;

  static LibraryLayout parse(String? value) =>
      values.firstWhere((layout) => layout.name == value, orElse: () => list);
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

class LibraryLayoutPreference {
  const LibraryLayoutPreference(this.preferred, {this.notice});
  final LibraryLayout preferred;
  final String? notice;
}

final libraryLayoutProvider =
    StateNotifierProvider<LibraryLayoutController, LibraryLayoutPreference>(
        (ref) => LibraryLayoutController(ref.read(libraryLayoutStoreProvider)));

class LibraryLayoutController extends StateNotifier<LibraryLayoutPreference> {
  LibraryLayoutController(this._store)
      : super(const LibraryLayoutPreference(LibraryLayout.list)) {
    unawaited(_restore());
  }

  final LibraryLayoutStore _store;
  int _revision = 0;
  Future<void> _writes = Future<void>.value();

  Future<void> _restore() async {
    final revision = _revision;
    try {
      final preferred = await _store.load();
      if (mounted && revision == _revision) {
        state = LibraryLayoutPreference(preferred);
      }
    } catch (_) {
      if (mounted && revision == _revision) {
        state = const LibraryLayoutPreference(LibraryLayout.list,
            notice: '보기 설정을 읽지 못했어요. 원하는 보기를 다시 선택해 주세요.');
      }
    }
  }

  Future<void> select(LibraryLayout layout) async {
    final revision = ++_revision;
    state = LibraryLayoutPreference(layout);
    _writes = _writes.catchError((_) {}).then((_) => _store.save(layout));
    try {
      await _writes;
    } catch (_) {
      if (mounted && revision == _revision) {
        state = LibraryLayoutPreference(layout,
            notice: '보기 설정을 저장하지 못했어요. 다음 실행에는 유지되지 않을 수 있어요.');
      }
    }
  }
}

const libraryGridGap = 12.0;
const libraryGridPadding = 10.0;
const libraryGridTitleStyle =
    TextStyle(fontSize: 14, height: 1.35, fontWeight: FontWeight.w700);

LibraryLayout effectiveLibraryLayout(LibraryLayout preferred,
    {required double availableWidth,
    required TextScaler textScaler,
    required TextDirection textDirection,
    String? fontFamily}) {
  final title = TextPainter(
      text: TextSpan(
          text: '책의제목',
          style: libraryGridTitleStyle.copyWith(fontFamily: fontFamily)),
      textScaler: textScaler,
      textDirection: textDirection)
    ..layout();
  final minimumWidth = title.width;
  title.dispose();
  for (var columns = preferred.columns; columns > 1; columns--) {
    final innerWidth =
        (availableWidth - libraryGridGap * (columns - 1)) / columns -
            libraryGridPadding * 2;
    if (innerWidth >= minimumWidth) return LibraryLayout.values[columns - 1];
  }
  return LibraryLayout.list;
}
