import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:bookstar/modules/learning/data/footprint_export.dart';
import 'package:bookstar/modules/learning/data/learning_access.dart';
import 'package:bookstar/modules/learning/data/learning_footprint.dart';
import 'package:bookstar/modules/learning/data/learning_repository.dart';
import 'package:bookstar/modules/learning/view/footprint_story_card.dart';
import 'package:bookstar/modules/learning/view/learning_design.dart';
import 'package:bookstar/modules/learning/view/learning_footprint_screen.dart';
import 'package:bookstar/modules/learning/view/learning_footprint_share_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final _record = LearningFootprint(
    answeredQuizCount: 126,
    reviewedQuizCount: 37,
    bookCount: 9,
    generatedAt: DateTime.utc(2026, 9, 9));
final _account = StateProvider<int?>((ref) => 7);

class _Api extends LearningRepository {
  _Api() : super(Dio());
  LearningFootprint record = _record;
  Completer<LearningFootprint>? gate;
  bool fail = false;
  bool selectedBooksRemoved = false;
  @override
  Future<LearningFootprint> getFootprint() async {
    if (fail) throw StateError('offline');
    return gate == null ? record : gate!.future;
  }

  @override
  Future<FootprintBookPage> getFootprintBooks(
          {int? cursor, List<int>? bookIds}) async =>
      FootprintBookPage(
          items: bookIds != null && selectedBooksRemoved ? [] : List.generate(
              4,
              (i) => FootprintBook(
                  bookId: i + 1, title: '선택 도서 ${i + 1}', author: '가상 저자')),
          hasNext: false,
          totalCount: 4);
}

class _Export extends FootprintExport {
  int shares = 0;
  int saves = 0;
  Uint8List? image;
  @override
  Future<bool> save(Uint8List bytes, bool Function() stillOwner) async {
    if (!stillOwner()) return false;
    saves++;
    image = bytes;
    return true;
  }

  @override
  Future<void> share(
      Uint8List bytes, Rect origin, bool Function() stillOwner) async {
    if (stillOwner()) {
      shares++;
      image = bytes;
    }
  }
}

Future<ProviderContainer> _pump(WidgetTester tester, Widget screen,
    {double scale = 1, _Api? api, _Export? exporter}) async {
  tester.view.physicalSize = const Size(320, 568);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final container = ProviderContainer(overrides: [
    learningAccountProvider.overrideWith((ref) => ref.watch(_account)),
    learningRepositoryProvider.overrideWithValue(api ?? _Api()),
    footprintExportProvider.overrideWithValue(exporter ?? _Export()),
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
          home: screen)));
  await tester.pumpAndSettle();
  return container;
}

Future<void> _reveal(WidgetTester tester, Finder target) async {
  if (target.evaluate().isEmpty) {
    await tester.scrollUntilVisible(target, 180,
        scrollable: find.byType(Scrollable).last);
  }
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
}

void main() {
  test('footprint uses explicit stored scope and rejects inconsistent counts',
      () {
    final json = {
      'answeredQuizCount': 3,
      'reviewedQuizCount': 1,
      'bookCount': 1,
      'generatedAt': '2026-09-09T00:00:00Z',
      'scope': 'STORED_RECORDS'
    };
    expect(LearningFootprint.fromJson(json).answeredQuizCount, 3);
    expect(
        () => LearningFootprint.fromJson({...json, 'scope': 'ALL_KNOWLEDGE'}),
        throwsFormatException);
    expect(() => LearningFootprint.fromJson({...json, 'reviewedQuizCount': 4}),
        throwsFormatException);
    expect(() => LearningFootprint.fromJson({...json, 'bookCount': -1}),
        throwsFormatException);
    expect(learningReturnPath('/library/footprint'), '/library/footprint');
  });

  test('book page requires progressing pagination metadata', () {
    expect(
        () => FootprintBookPage.fromJson({
              'scope': 'STORED_RECORDS',
              'items': [],
              'hasNext': true,
              'totalCount': 10
            }),
        throwsFormatException);
  });

  for (final scale in [1.0, 2.0, 3.0]) {
    testWidgets('private footprint and editor fit 320px at ${scale}x',
        (tester) async {
      await _pump(tester, const LearningFootprintScreen(), scale: scale);
      await _reveal(tester, find.text('내 기록 카드 만들기'));
      await tester.tap(find.text('내 기록 카드 만들기'));
      await tester.pumpAndSettle();
      await _reveal(tester, find.text('이미지 공유'));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('zero record offers first action without a share reward',
      (tester) async {
    final api = _Api()
      ..record = LearningFootprint(
          answeredQuizCount: 0,
          reviewedQuizCount: 0,
          bookCount: 0,
          generatedAt: DateTime.utc(2026));
    await _pump(tester, const LearningFootprintScreen(), api: api);
    expect(find.text('내 기록 카드 만들기'), findsNothing);
    await _reveal(tester, find.text('AI 퀴즈 풀 책 찾기'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('error is not a zero record and can retry', (tester) async {
    final api = _Api()..fail = true;
    await _pump(tester, const LearningFootprintScreen(), api: api);
    expect(find.text('첫 흔적은\n한 문제부터.'), findsNothing);
    api.fail = false;
    await tester.tap(find.text('다시 불러오기'));
    await tester.pumpAndSettle();
    expect(find.text('126개'), findsOneWidget);
  });

  testWidgets('numbers opt out and books require explicit choice, max three',
      (tester) async {
    await _pump(
        tester, LearningFootprintShareScreen(ownerId: 7, footprint: _record));
    var card =
        tester.widget<FootprintStoryCard>(find.byType(FootprintStoryCard));
    expect(card.books, isEmpty);
    await tester.tap(find.text('누적 수치 담기'));
    await tester.pumpAndSettle();
    card = tester.widget<FootprintStoryCard>(find.byType(FootprintStoryCard));
    expect(card.showNumbers, false);
    await _reveal(tester, find.text('이미지 공유'));
    final button = tester.widget<FilledButton>(find
        .ancestor(
            of: find.text('이미지 공유'),
            matching:
                find.byWidgetPredicate((widget) => widget is FilledButton))
        .first);
    expect(button.onPressed, isNull);
    await _reveal(tester, find.text('담을 책 직접 고르기 · 최대 3권'));
    await tester.tap(find.text('담을 책 직접 고르기 · 최대 3권'));
    await tester.pumpAndSettle();
    expect(
        tester
            .widgetList<CheckboxListTile>(find.byType(CheckboxListTile))
            .every((item) => item.value == false),
        true);
    for (var i = 1; i <= 3; i++) {
      await tester.tap(find.text('선택 도서 $i'));
    }
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<CheckboxListTile>(
                find.widgetWithText(CheckboxListTile, '선택 도서 4'))
            .onChanged,
        isNull);
    await tester.tap(find.text('선택한 3권 담기'));
    await tester.pumpAndSettle();
    card = tester.widget<FootprintStoryCard>(find.byType(FootprintStoryCard));
    expect(card.books.length, 3);
    expect(card.showNumbers, false);
    await _reveal(tester, find.text('숫자 중심'));
    await tester.tap(find.text('숫자 중심'));
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<FootprintStoryCard>(find.byType(FootprintStoryCard))
            .books,
        isEmpty);
  });

  testWidgets('changed counts refresh preview without exporting',
      (tester) async {
    final exporter = _Export();
    final api = _Api()
      ..record = LearningFootprint(
          answeredQuizCount: 127,
          reviewedQuizCount: 37,
          bookCount: 9,
          generatedAt: DateTime.utc(2026));
    await _pump(
        tester, LearningFootprintShareScreen(ownerId: 7, footprint: _record),
        api: api, exporter: exporter);
    await _reveal(tester, find.text('이미지 공유'));
    await tester.tap(find.text('이미지 공유'));
    await tester.pumpAndSettle();
    expect(exporter.shares, 0);
    expect(
        tester
            .widget<FootprintStoryCard>(find.byType(FootprintStoryCard))
            .footprint
            .answeredQuizCount,
        127);
  });

  testWidgets('account switch discards delayed export and previous preview',
      (tester) async {
    final api = _Api()..gate = Completer<LearningFootprint>();
    final exporter = _Export();
    final container = await _pump(
        tester, LearningFootprintShareScreen(ownerId: 7, footprint: _record),
        api: api, exporter: exporter);
    await _reveal(tester, find.text('이미지 공유'));
    await tester.tap(find.text('이미지 공유'));
    await tester.pump();
    container.read(_account.notifier).state = 8;
    await tester.pump();
    container.read(_account.notifier).state = 7;
    await tester.pump();
    api.gate!.complete(_record);
    await tester.pumpAndSettle();
    expect(find.byType(FootprintStoryCard), findsNothing);
    expect(exporter.shares, 0);
  });

  testWidgets('removed selected book blocks export even with unchanged counts', (tester) async {
    final api = _Api();
    final exporter = _Export();
    await _pump(tester, LearningFootprintShareScreen(ownerId: 7, footprint: _record),
      api: api, exporter: exporter);
    await tester.tap(find.text('담을 책 직접 고르기 · 최대 3권'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('선택 도서 1'));
    await tester.pump();
    await tester.tap(find.text('선택한 1권 담기'));
    await tester.pumpAndSettle();
    api.selectedBooksRemoved = true;
    await _reveal(tester, find.text('이미지 공유'));
    await tester.tap(find.text('이미지 공유'));
    await tester.pumpAndSettle();
    expect(exporter.shares, 0);
    expect(tester.widget<FootprintStoryCard>(find.byType(FootprintStoryCard)).books, isEmpty);
  });

  testWidgets('book picker header and list remain usable at 320px 3x', (tester) async {
    await _pump(tester, LearningFootprintShareScreen(ownerId: 7, footprint: _record), scale: 3);
    await _reveal(tester, find.text('담을 책 직접 고르기 · 최대 3권'));
    await tester.tap(find.text('담을 책 직접 고르기 · 최대 3권'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('선택 도서 1'), 100,
        scrollable: find.byType(Scrollable).last);
    final checkbox = find.descendant(of: find.widgetWithText(CheckboxListTile, '선택 도서 1'),
      matching: find.byType(Checkbox));
    await tester.ensureVisible(checkbox);
    await tester.pumpAndSettle();
    await tester.tap(checkbox);
    await tester.pumpAndSettle();
    expect(find.text('선택한 1권 담기'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('story raster is 1080x1920 and excludes editor placeholders',
      (tester) async {
    final key = GlobalKey();
    await tester.pumpWidget(MaterialApp(
        home: FittedBox(
            child: RepaintBoundary(
                key: key,
                child: FootprintStoryCard(
                    footprint: _record,
                    books: const [
                      FootprintBook(bookId: 1, title: '길이가 아주 긴 책 제목을 가지는 책'),
                      FootprintBook(bookId: 2, title: '두 번째 책'),
                      FootprintBook(bookId: 3, title: '세 번째 책')
                    ],
                    showNumbers: false,
                    style: FootprintCardStyle.books)))));
    await tester.pumpAndSettle();
    expect(find.textContaining('직접 골라'), findsNothing);
    expect(find.textContaining('126'), findsNothing);
    final boundary =
        key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = (await tester.runAsync(() => boundary.toImage(pixelRatio: 3)))!;
    expect(image.width, 1080);
    expect(image.height, 1920);
    final bytes = await tester.runAsync(() => image.toByteData(format: ui.ImageByteFormat.png));
    expect(bytes!.lengthInBytes, greaterThan(1000));
    image.dispose();
    expect(tester.takeException(), isNull);
  });
}
