import 'dart:io';
import 'dart:ui' as ui;

import 'package:bookstar/modules/auth/model/auth_response.dart';
import 'package:bookstar/modules/auth/model/policy.dart';
import 'package:bookstar/modules/auth/repository/policy_repository.dart';
import 'package:bookstar/common/models/response_form.dart';
import 'package:bookstar/common/models/status_response.dart';
import 'package:bookstar/modules/auth/view_model/auth_state.dart';
import 'package:bookstar/modules/auth/view_model/auth_view_model.dart';
import 'package:bookstar/modules/learning/data/diary_archive_repository.dart';
import 'package:bookstar/modules/learning/data/learning_access.dart';
import 'package:bookstar/modules/learning/data/learning_repository.dart';
import 'package:bookstar/modules/learning/data/reading_graph.dart';
import 'package:bookstar/modules/learning/view/bs_ui.dart';
import 'package:bookstar/modules/learning/view/learning_archive_screen.dart';
import 'package:bookstar/modules/learning/view/learning_design.dart';
import 'package:bookstar/modules/learning/view/learning_home_screen.dart';
import 'package:bookstar/modules/learning/view/learning_notification_settings_screen.dart';
import 'package:bookstar/modules/learning/view/learning_settings_screen.dart';
import 'package:bookstar/modules/learning/view/learning_shell.dart';
import 'package:bookstar/modules/learning/view/reading_map_preview.dart';
import 'package:bookstar/modules/reading_challenge/model/challenge_response.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ui_v2_capture.dart';

const _books = [
  ChallengeResponse(
      challengeId: 1, bookId: 1, bookTitle: '수족관', bookAuthor: '유래혁'),
  ChallengeResponse(
      challengeId: 2, bookId: 2, bookTitle: '작별인사', bookAuthor: '김영하'),
  ChallengeResponse(
      challengeId: 3, bookId: 3, bookTitle: '아몬드', bookAuthor: '손원평'),
  ChallengeResponse(
      challengeId: 4, bookId: 4, bookTitle: '불편한 편의점', bookAuthor: '김호연'),
  ChallengeResponse(
      challengeId: 5, bookId: 5, bookTitle: '파친코', bookAuthor: '이민진'),
];

ReviewItem _review(int quizId, int bookId) => ReviewItem(
    bookId: bookId,
    quizId: quizId,
    chapterId: bookId * 10 + quizId % 2,
    chapterTitle: '목차 $quizId',
    bookTitle: _books[bookId - 1].bookTitle,
    bookCover: '',
    question: '질문 $quizId',
    reviewCount: 0,
    due: false,
    nextReviewAt: DateTime.utc(2030));

final _mapGraph = ReadingGraph.fromReviews([
  _review(1, 1),
  _review(2, 1),
  _review(3, 2),
  _review(4, 2),
  _review(5, 3),
  _review(6, 3),
]);

Widget _home({required List<ChallengeResponse> books, required bool map}) =>
    ProviderScope(
      overrides: [
        learningAccountProvider.overrideWithValue(1),
        learningBooksProvider.overrideWith((ref) async => books),
        readingGraphProvider.overrideWith(
            (ref) async => map ? _mapGraph : const ReadingGraph([])),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: LearningColors.theme,
        home: Scaffold(
          backgroundColor: Bs.bg,
          extendBody: true,
          body: const LearningHomeScreen(),
          bottomNavigationBar: BsNavBar(currentIndex: 0, onTap: (_) {}),
        ),
      ),
    );

class _Auth extends AuthViewModel {
  @override
  Future<AuthState> build() async => AuthSuccess(
      memberId: 1,
      nickName: '북스타',
      profileImage: '',
      providerType: 'KAKAO',
      email: 'bookstar1234@gmail.com',
      memberRole: MemberRole.USER);
}

Widget _page(Widget screen,
        {TargetPlatform? platform, List<Override> overrides = const []}) =>
    ProviderScope(
      overrides: [
        learningAccountProvider.overrideWithValue(1),
        authViewModelProvider.overrideWith(_Auth.new),
        ...overrides,
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: LearningColors.theme.copyWith(platform: platform),
        home: screen,
      ),
    );

class _Policies implements PolicyRepository {
  @override
  Future<ResponseForm<Policy>> getPolicy() async => const ResponseForm(
      statusResponse: StatusResponse(resultCode: 'OK', resultMessage: 'OK'),
      data: Policy(marketingAgree: PolicyAgree.Y));

  @override
  Future<ResponseForm<void>> updatePolicy(Policy body) async =>
      throw UnimplementedError();
}

class _Archive extends DiaryArchiveRepository {
  _Archive() : super(Dio());

  @override
  Future<DiaryArchivePage> getPage({int? cursor}) async => DiaryArchivePage([
        DiaryArchiveItem(
            id: 1,
            bookTitle: '수족관',
            bookCover: '',
            content: '물속을 오래 들여다보던 장면이 마음에 남았다. 나도 누군가의 수족관이 되어 줄 수 있을까.',
            createdAt: DateTime(2025, 3, 2)),
        DiaryArchiveItem(
            id: 2,
            bookTitle: '작별인사',
            bookCover: '',
            content: '기계와 인간의 경계를 묻는 질문이 계속 떠올랐다.',
            createdAt: DateTime(2024, 11, 18)),
      ], true, 2);
}

/// [captureBsScreen] for frames taller than the iPhone viewport (1.2 is a
/// 375×918pt full-page export).
Future<void> _captureTall(
    WidgetTester tester, Widget app, String name, double heightPt) async {
  final key = GlobalKey();
  tester.view.physicalSize = Size(750, heightPt * 2);
  tester.view.devicePixelRatio = 2;
  tester.view.padding = const FakeViewPadding(top: 88, bottom: 68);
  tester.view.viewPadding = const FakeViewPadding(top: 88, bottom: 68);
  addTearDown(tester.view.reset);
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

void main() {
  setUpAll(setUpBsCapture);

  testWidgets('1.1 메인_Default', (tester) async {
    await captureBsScreen(
        tester, _home(books: _books, map: true), '1.1 메인_Default');
    expect(find.text('3권에서 쌓인 6개의 생각'), findsOneWidget);
  });

  testWidgets('1.1 메인_Default-1', (tester) async {
    await captureBsScreen(
        tester, _home(books: _books, map: false), '1.1 메인_Default-1');
    expect(find.byType(ReadingMapPreview), findsNothing);
  });

  testWidgets('1.1 메인_Empty', (tester) async {
    await captureBsScreen(
        tester, _home(books: const [], map: false), '1.1 메인_Empty');
    expect(find.text('아직 읽은 책이 없어요'), findsOneWidget);
  });

  testWidgets('1.2 설정_Default (iOS)', (tester) async {
    await _captureTall(
        tester,
        _page(const LearningSettingsScreen(), platform: TargetPlatform.iOS),
        '1.2 설정_Default',
        918);
  });

  testWidgets('1.3 설정_Default (Android)', (tester) async {
    await captureBsScreen(
        tester,
        _page(const LearningSettingsScreen(), platform: TargetPlatform.android),
        '1.3 설정_Default');
  });

  testWidgets('알림 설정 (no Figma frame)', (tester) async {
    await captureBsScreen(
        tester,
        _page(const LearningNotificationSettingsScreen(), overrides: [
          policyRepositoryProvider.overrideWithValue(_Policies())
        ]),
        'B 알림 설정 (no frame)');
  });

  testWidgets('나의 지난 독서 기록 (no Figma frame)', (tester) async {
    await captureBsScreen(
        tester,
        _page(const LearningArchiveScreen(), overrides: [
          diaryArchiveRepositoryProvider.overrideWithValue(_Archive())
        ]),
        'B 나의 지난 독서 기록 (no frame)');
  });
}
