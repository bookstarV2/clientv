import 'package:bookstar/infra/network/dio_client.dart';
import 'package:bookstar/modules/learning/data/diary_archive_repository.dart';
import 'package:bookstar/modules/learning/data/learning_repository.dart';
import 'package:bookstar/modules/learning/data/reading_graph.dart';
import 'package:bookstar/modules/learning/view/learning_archive_screen.dart';
import 'package:bookstar/modules/learning/view/learning_design.dart';
import 'package:bookstar/modules/learning/view/learning_home_screen.dart';
import 'package:bookstar/modules/learning/view/reading_graph_screen.dart';
import 'package:bookstar/modules/learning/view/learning_library_screen.dart';
import 'package:bookstar/modules/learning/view/learning_review_screen.dart';
import 'package:bookstar/modules/learning/view/learning_search_screen.dart';
import 'package:bookstar/modules/reading_challenge/model/challenge_response.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const _title = '보존할 책';
const _author = '보존할 저자';
const _question = '다시 떠올릴 질문의 전체 내용은 무엇인가요?';
const _preview = '예전에 남긴 기록의 미리보기 내용';
const _book = ChallengeResponse(
    challengeId: 7, bookId: 5, bookTitle: _title, bookAuthor: _author);

void main() {
  testWidgets('card opts into one complete label with an accessible tap',
      (tester) async {
    final handle = tester.ensureSemantics();
    try {
      var taps = 0;
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: LearningCard(
        label: '책, 저자, 목차 열기',
        excludeChildSemantics: true,
        onTap: () => taps++,
        child: const Column(children: [Text('책'), Text('저자')]),
      ))));
      final node = _singleNode(tester, '책, 저자, 목차 열기');
      expect(node.getSemanticsData().hasFlag(SemanticsFlag.isEnabled), isTrue);
      node.owner!.performAction(node.id, SemanticsAction.tap);
      await tester.pump();
      expect(taps, 1);
    } finally {
      handle.dispose();
    }
  });

  testWidgets('temporarily disabled opted-in card remains a disabled button',
      (tester) async {
    final handle = tester.ensureSemantics();
    try {
      await tester.pumpWidget(const MaterialApp(
          home: Scaffold(
              body: LearningCard(
        label: '책, 목차 여는 중',
        excludeChildSemantics: true,
        child: Text('책'),
      ))));
      final node = _singleNode(tester, '책, 목차 여는 중', enabled: false);
      expect(node.getSemanticsData().hasFlag(SemanticsFlag.hasEnabledState),
          isTrue);
    } finally {
      handle.dispose();
    }
  });

  testWidgets(
      'default reading card preserves text and independent child actions',
      (tester) async {
    final handle = tester.ensureSemantics();
    try {
      var taps = 0;
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: LearningCard(
        label: '추가 설명',
        child: Column(children: [
          const Text('읽을 본문'),
          TextButton(onPressed: () => taps++, child: const Text('독립된 동작'))
        ]),
      ))));
      expect(find.bySemanticsLabel(RegExp('읽을 본문')), findsOneWidget);
      final node = tester.getSemantics(find.bySemanticsLabel('독립된 동작'));
      node.owner!.performAction(node.id, SemanticsAction.tap);
      await tester.pump();
      expect(taps, 1);
      expect(tester.takeException(), isNull);
    } finally {
      handle.dispose();
    }
  });

  for (final finished in [false, true]) {
    testWidgets(
        'library ${finished ? 'finished' : 'ongoing'} retains author and status once',
        (tester) async {
      final handle = tester.ensureSemantics();
      try {
        await _pump(tester, const LearningLibraryScreen());
        if (finished) {
          await _reveal(tester, find.text('퀴즈를 마친 책'));
          await tester.tap(find.text('퀴즈를 마친 책'));
          await tester.pumpAndSettle();
        }
        await _reveal(tester, find.text(_title));
        final label =
            '$_title, $_author, ${finished ? '퀴즈를 마친 책' : '읽고 있는 책'}, 목차 열기';
        final node = _singleNode(tester, label);
        expect(node.getSemanticsData().label.split(_title), hasLength(2));
        await _open(tester, node, '/library/7/chapters');
      } finally {
        handle.dispose();
      }
    });
  }

  testWidgets(
      'search retains author and prepared count without claiming another add',
      (tester) async {
    final handle = tester.ensureSemantics();
    try {
      await _pump(tester, const LearningSearchScreen(), page: true);
      await _reveal(tester, find.text(_title));
      final node =
          _singleNode(tester, '$_title, $_author, 목차 퀴즈 5개 준비됨, 목차 열기');
      expect(node.getSemanticsData().label, isNot(contains('추가')));
      await _open(tester, node, '/library/7/chapters');
    } finally {
      handle.dispose();
    }
  });

  for (final due in [true, false]) {
    testWidgets(
        'review card retains question and ${due ? 'due state' : 'next date'}',
        (tester) async {
      final handle = tester.ensureSemantics();
      try {
        await _pump(tester, LearningReviewScreen(allQuizzes: !due), due: due);
        await _reveal(tester, find.text(_question));
        final label =
            '$_title, 보존할 목차, $_question, ${due ? '지금 떠올려 볼 시간' : '9월 10일 09:30 예정'}, 복습하기';
        final node = _singleNode(tester, label);
        await _open(tester, node, '/review/quiz/12');
      } finally {
        handle.dispose();
      }
    });
  }

  testWidgets(
      'archive card retains date and preview without repeated book title',
      (tester) async {
    final handle = tester.ensureSemantics();
    try {
      await _pump(tester, const LearningArchiveScreen(), page: true);
      await _reveal(tester, find.text(_preview));
      final node =
          _singleNode(tester, '$_title, 2026년 9월 9일, $_preview, 지난 기록 읽기');
      await _open(tester, node, '/settings/archive/20');
    } finally {
      handle.dispose();
    }
  });

  testWidgets(
      'quiz home provides an accessible primary start route to the library',
      (tester) async {
    final handle = tester.ensureSemantics();
    try {
      await _pump(tester, const LearningHomeScreen());
      await _reveal(tester, find.text('내 책으로 퀴즈 풀기'));
      expect(
          tester
              .getSemantics(find.bySemanticsLabel('내 책으로 퀴즈 풀기'))
              .getSemanticsData()
              .hasAction(SemanticsAction.tap),
          isTrue);
      await _open(
          tester,
          tester.getSemantics(find.bySemanticsLabel('내 책으로 퀴즈 풀기')),
          '/library');
    } finally {
      handle.dispose();
    }
  });

  testWidgets(
      'map can be explored through accessible book and chapter controls',
      (tester) async {
    final handle = tester.ensureSemantics();
    try {
      await _pump(tester, const ReadingGraphScreen());
      await _reveal(tester, find.byType(ListTile));
      await tester.tap(find.byType(ListTile));
      await tester.pumpAndSettle();
      await _reveal(tester, find.text('보존할 목차'));
      await tester.tap(find.text('보존할 목차'));
      await tester.pumpAndSettle();
      await _reveal(tester, find.text('이 목차 다시 열기'));
      await _open(
          tester,
          tester.getSemantics(find.bySemanticsLabel('이 목차 다시 열기')),
          '/review/quiz/12');
    } finally {
      handle.dispose();
    }
  });
}

SemanticsNode _singleNode(WidgetTester tester, String label,
    {bool enabled = true}) {
  final finder = find.bySemanticsLabel(RegExp('^${RegExp.escape(label)}\$'));
  expect(finder, findsOneWidget);
  final node = tester.getSemantics(finder);
  expect(node.getSemanticsData().label, label);
  expect(node.getSemanticsData().hasFlag(SemanticsFlag.isButton), isTrue);
  expect(node.getSemanticsData().hasAction(SemanticsAction.tap), enabled);
  var children = 0;
  node.visitChildren((_) {
    children++;
    return true;
  });
  expect(children, 0,
      reason:
          'No additional cover/title/body announcement under the complete label');
  return node;
}

Future<void> _open(WidgetTester tester, SemanticsNode node, String path) async {
  node.owner!.performAction(node.id, SemanticsAction.tap);
  await tester.pumpAndSettle();
  expect(find.text('destination $path'), findsOneWidget);
  expect(tester.takeException(), isNull);
}

class _Repository extends LearningRepository {
  _Repository(this.due) : super(Dio());
  final bool due;
  ReviewItem get item => ReviewItem(
      bookId: 5,
      quizId: 30,
      chapterId: 12,
      chapterTitle: '보존할 목차',
      bookTitle: _title,
      bookCover: '',
      question: _question,
      reviewCount: 1,
      due: due,
      nextReviewAt: DateTime(2026, 9, 10, 9, 30));
  @override
  Future<ReviewPage> getReviews({int? cursor, bool dueOnly = false}) async =>
      ReviewPage(
          items: dueOnly && !due ? [] : [item],
          totalCount: 1,
          dueCount: due ? 1 : 0,
          reviewedTodayCount: 0,
          hasNext: false);
  @override
  Future<LearningBookPage> searchBooks(String query, {int? cursor}) async =>
      const LearningBookPage(
          [LearningBook(5, _title, _author, '', 5)], false, null);
}

class _Archive extends DiaryArchiveRepository {
  _Archive() : super(Dio());
  @override
  Future<DiaryArchivePage> getPage({int? cursor}) async => DiaryArchivePage([
        DiaryArchiveItem(
            id: 20,
            bookTitle: _title,
            bookCover: '',
            content: _preview,
            createdAt: DateTime(2026, 9, 9)),
      ], false, null);
}

Future<void> _pump(WidgetTester tester, Widget screen,
    {bool page = false, bool due = true}) async {
  tester.view.physicalSize = const Size(320, 568);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final repository = _Repository(due);
  final dio = Dio();
  dio.interceptors.add(InterceptorsWrapper(onRequest: (request, handler) {
    if (request.path == '/api/v3/challenges/ongoing') {
      handler.resolve(Response(requestOptions: request, statusCode: 200, data: {
        'statusResponse': {'resultCode': 'OK', 'resultMessage': 'OK'},
        'data': {
          'challenges': [_book.toJson()]
        },
      }));
    } else {
      handler.reject(DioException(
          requestOptions: request,
          error: StateError('Unexpected request ${request.path}')));
    }
  }));
  addTearDown(dio.close);
  final router = GoRouter(initialLocation: '/test', routes: [
    GoRoute(
        path: '/test',
        builder: (_, __) => page ? screen : Scaffold(body: screen)),
    for (final path in [
      '/library/7/chapters',
      '/review/quiz/12',
      '/settings/archive/20',
      '/library'
    ])
      GoRoute(
          path: path,
          builder: (_, __) => Scaffold(body: Text('destination $path'))),
  ]);
  addTearDown(router.dispose);
  await tester.pumpWidget(ProviderScope(
      overrides: [
        learningBooksProvider.overrideWith((ref) async => [_book]),
        finishedLearningBooksProvider.overrideWith((ref) async => [_book]),
        learningRepositoryProvider.overrideWithValue(repository),
        readingGraphProvider.overrideWith(
            (ref) async => ReadingGraph.fromReviews([repository.item])),
        reviewOverviewProvider
            .overrideWith((ref) => repository.getReviews(dueOnly: true)),
        diaryArchiveRepositoryProvider.overrideWithValue(_Archive()),
        dioClientProvider.overrideWithValue(dio),
      ],
      child: MaterialApp.router(
          theme: LearningColors.theme,
          routerConfig: router,
          builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(2)),
              child: child!))));
  await tester.pumpAndSettle();
}

Future<void> _reveal(WidgetTester tester, Finder target) async {
  final scrollable = find.byType(Scrollable).first;
  tester.state<ScrollableState>(scrollable).position.jumpTo(0);
  await tester.pump();
  await tester.scrollUntilVisible(target, 140,
      scrollable: scrollable, maxScrolls: 60);
  await tester.pumpAndSettle();
}
