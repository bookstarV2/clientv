import 'dart:io';
import 'dart:ui' as ui;

import 'package:bookstar/modules/learning/data/learning_access.dart';
import 'package:bookstar/modules/learning/data/learning_repository.dart';
import 'package:bookstar/modules/learning/data/reading_graph.dart';
import 'package:bookstar/modules/learning/data/reading_map_remote.dart';
import 'package:bookstar/modules/learning/view/bs_ui.dart';
import 'package:bookstar/modules/learning/view/learning_shell.dart';
import 'package:bookstar/modules/learning/view/reading_map_preview.dart';
import 'package:bookstar/modules/learning/view/reading_map_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ui_v2_capture.dart';

const _question = '1장에서 동호가 상무관에서 시신들을 관리하며 촛불을 켜두는 행위가 상징하는 근본적인 의미는 무엇일까요?';

ReviewItem _item(
        int quizId, int bookId, String book, int chapterId, String chapter,
        {String question = _question}) =>
    ReviewItem(
      bookId: bookId,
      quizId: quizId,
      chapterId: chapterId,
      chapterTitle: chapter,
      bookTitle: book,
      bookCover: '',
      question: question,
      reviewCount: quizId.isEven ? 1 : 0,
      due: false,
      nextReviewAt: DateTime.utc(2030),
    );

/// 4.2: three books with three answered quizzes each.
final _allGraph = ReadingGraph.fromReviews([
  _item(101, 1, '소년이 온다', 11, '1장 어린 새'),
  _item(102, 1, '소년이 온다', 12, '2장 검은 숲', question: '검은 숲에서 정대가 본 것은?'),
  _item(103, 1, '소년이 온다', 13, '3장 쇠와 피', question: '쇠와 피가 뜻하는 것은?'),
  _item(201, 2, '커피우유와 소보로빵', 21, '1장 전학생'),
  _item(202, 2, '커피우유와 소보로빵', 21, '1장 전학생'),
  _item(203, 2, '커피우유와 소보로빵', 22, '2장 소보로빵'),
  _item(301, 3, '눈물꽃 소년', 31, '1장 눈물꽃'),
  _item(302, 3, '눈물꽃 소년', 32, '2장 할머니'),
  _item(303, 3, '눈물꽃 소년', 32, '2장 할머니'),
]);

/// 4.1 / 1.1: "3권에서 쌓인 6개의 생각".
final _tabGraph = ReadingGraph.fromReviews([
  _item(101, 1, '소년이 온다', 11, '1장 어린 새'),
  _item(102, 1, '소년이 온다', 12, '2장 검은 숲'),
  _item(103, 1, '소년이 온다', 13, '3장 쇠와 피'),
  _item(201, 2, '커피우유와 소보로빵', 21, '1장 전학생'),
  _item(202, 2, '커피우유와 소보로빵', 22, '2장 소보로빵'),
  _item(301, 3, '눈물꽃 소년', 31, '1장 눈물꽃'),
]);

Widget _app(Widget screen, ReadingGraph graph, {int? tab}) => ProviderScope(
      overrides: [
        learningAccountProvider.overrideWithValue(7),
        readingGraphProvider.overrideWith((ref) async => graph),
        readingMapStateProvider
            .overrideWith((ref) async => const ReadingMapState(
                  balance: 35,
                  createCost: 20,
                  refreshCost: 10,
                  answeredQuizCount: 6,
                  analyzedQuizCount: 0,
                  hasNewQuizzes: true,
                  status: null,
                  jobId: null,
                  version: 0,
                  links: [],
                )),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: tab == null
            ? screen
            : Scaffold(
                backgroundColor: Bs.bg,
                extendBody: true,
                body: screen,
                bottomNavigationBar: BsNavBar(currentIndex: tab, onTap: (_) {}),
              ),
      ),
    );

/// Like [captureBsScreen] but for frames exported taller than 812pt
/// (change_log `4.1 메인_Empty` is 750×1866).
Future<void> _captureTall(
    WidgetTester tester, Widget app, String name, double height) async {
  tester.view.physicalSize = Size(750, height);
  tester.view.devicePixelRatio = 2;
  tester.view.padding = const FakeViewPadding(top: 88, bottom: 68);
  tester.view.viewPadding = const FakeViewPadding(top: 88, bottom: 68);
  addTearDown(tester.view.reset);
  final key = GlobalKey();
  await tester.pumpWidget(RepaintBoundary(key: key, child: app));
  await settleBsImages(tester);
  final boundary = tester.renderObject<RenderRepaintBoundary>(find.byKey(key));
  final bytes = await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 2);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  });
  File('build/ui_v2_shots/$name.png')
    ..createSync(recursive: true)
    ..writeAsBytesSync(bytes!);
}

Future<void> _selectBook(WidgetTester tester) async {
  final row = find.text('소년이 온다').last;
  await tester.ensureVisible(row);
  await tester.pumpAndSettle();
  await tester.tap(row);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(setUpBsCapture);

  testWidgets('4.1 메인_Default', (tester) async {
    await captureBsScreen(tester,
        _app(const ReadingMapScreen(), _tabGraph, tab: 3), '4.1 메인_Default');
    expect(find.text('3권에서 쌓인 6개의 생각'), findsOneWidget);
  });

  testWidgets('4.1 메인_Empty', (tester) async {
    await _captureTall(
        tester,
        _app(const ReadingMapScreen(), const ReadingGraph([]), tab: 3),
        '4.1 메인_Empty',
        1866);
    expect(find.text('아직 읽은 책이 없어요'), findsOneWidget);
    expect(find.text('책 추가하기'), findsOneWidget);
  });

  testWidgets('4.2 전체보기_Default', (tester) async {
    await captureBsScreen(tester, _app(const ReadingMapAllScreen(), _allGraph),
        '4.2 전체보기_Default');
  });

  testWidgets('4.2 전체보기_Active', (tester) async {
    await captureBsScreen(
        tester, _app(const ReadingMapAllScreen(), _allGraph), '4.2 전체보기_Active',
        beforeCapture: () async {
      await _selectBook(tester);
    });
    expect(find.text('2장 검은 숲'), findsWidgets);
  });

  testWidgets('4.2 전체보기_Active-1', (tester) async {
    await captureBsScreen(tester, _app(const ReadingMapAllScreen(), _allGraph),
        '4.2 전체보기_Active-1', beforeCapture: () async {
      await _selectBook(tester);
      await tester.tap(find.text('1장 어린 새').last);
      await tester.pumpAndSettle();
    });
    expect(find.text(_question), findsOneWidget);
    expect(find.text('퀴즈 다시 풀기'), findsOneWidget);
  });

  testWidgets('4.2.1 독서지도 공유_Default', (tester) async {
    await captureBsScreen(tester, _app(const ReadingMapAllScreen(), _allGraph),
        '4.2.1 독서지도 공유_Default', beforeCapture: () async {
      await tester.tap(find.byTooltip('독서 지도 이미지로 공유'));
      await tester.pumpAndSettle();
    });
    expect(find.text('이 지도를 이미지로 공유할까요?'), findsOneWidget);
  });

  for (final (name, graph) in [
    ('map_preview', _tabGraph),
    ('map_preview_empty', const ReadingGraph([])),
  ]) {
    testWidgets(name, (tester) async {
      await captureBsScreen(
          tester,
          _app(
              BsScaffold(
                title: '독서 퀴즈',
                body: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 452.5, 16, 24),
                  children: const [ReadingMapPreview(mapHeight: 563)],
                ),
              ),
              graph,
              tab: 0),
          name);
    });
  }
}
