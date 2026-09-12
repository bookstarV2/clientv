import 'package:bookstar/infra/network/dio_client.dart';
import 'package:bookstar/modules/learning/data/learning_access.dart';
import 'package:bookstar/modules/learning/view/learning_archive_screen.dart';
import 'package:bookstar/modules/learning/view/learning_design.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('empty archive explains preserved personal read-only history',
      (tester) async {
    final api = _ArchiveApi(empty: true);
    await _pump(tester, api);
    await _reveal(tester, find.text('아직 지난 기록이 없어요'));
    expect(find.textContaining('본인이 작성한 기록만'), findsOneWidget);
    expect(api.paths, ['/api/v3/me/reading-diaries']);
    expect(tester.takeException(), isNull);
  });

  testWidgets('archive load failure can be retried without losing the screen',
      (tester) async {
    final api = _ArchiveApi(empty: true)..failLoads = 1;
    await _pump(tester, api);
    await _reveal(tester, find.text('다시 불러오기'));
    await tester.tap(find.text('다시 불러오기'));
    await tester.pumpAndSettle();
    await _reveal(tester, find.text('아직 지난 기록이 없어요'));
    expect(api.paths, hasLength(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('pagination appends older records using only the me API cursor',
      (tester) async {
    final api = _ArchiveApi();
    await _pump(tester, api);
    await _reveal(tester, find.text('첫 번째 책'));
    await _reveal(tester, find.text('지난 기록 더 보기'));
    await tester.tap(find.text('지난 기록 더 보기'));
    await tester.pumpAndSettle();
    await _reveal(tester, find.text('두 번째 책'));
    expect(api.cursors, [null, 20]);
    expect(api.paths.every((path) => path == '/api/v3/me/reading-diaries'),
        isTrue);
    expect(find.text('지난 기록 더 보기'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'private detail 404 gives a personal-record message not raw error',
      (tester) async {
    final api = _ArchiveApi()..missing = true;
    await _pump(tester, api, detail: true);
    expect(find.text('기록을 찾을 수 없어요. 본인이 작성한 기록만 열 수 있어요.'), findsOneWidget);
    expect(find.textContaining('DioException'), findsNothing);
    expect(api.paths.single, '/api/v3/me/reading-diaries/20');
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'long archived text remains selectable and scrollable at 320px 2x',
      (tester) async {
    final api = _ArchiveApi(longText: true);
    await _pump(tester, api, detail: true, scale: 2);
    expect(tester.takeException(), isNull);
    expect(find.byType(SelectableText), findsOneWidget);
    expect(tester.widget<SelectableText>(find.byType(SelectableText)).data,
        api.content);
    await _reveal(tester, find.text('나의 지난 기록 · 읽기 전용'));
    expect(find.text('나의 지난 기록 · 읽기 전용').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _ArchiveApi {
  _ArchiveApi({this.empty = false, this.longText = false}) {
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      paths.add(options.path);
      if (failLoads-- > 0 || missing) {
        handler.reject(DioException(
            requestOptions: options,
            response: Response(
                requestOptions: options, statusCode: missing ? 404 : 503)));
        return;
      }
      final detail = options.path.endsWith('/20');
      final cursor = options.queryParameters['cursor'];
      if (!detail) cursors.add(cursor as int?);
      final data = detail
          ? _item(20)
          : {
              'items': empty ? [] : [_item(cursor == null ? 20 : 10)],
              'hasNext': !empty && cursor == null,
              'nextCursor': !empty && cursor == null ? 20 : null,
            };
      handler.resolve(Response(
          requestOptions: options, statusCode: 200, data: {'data': data}));
    }));
  }
  final bool empty;
  final bool longText;
  final dio = Dio(BaseOptions(baseUrl: 'http://example.invalid'));
  final paths = <String>[];
  final cursors = <int?>[];
  int failLoads = 0;
  bool missing = false;
  String get content => longText
      ? List.filled(50, '읽으며 남긴 긴 생각을 내 기록에서 다시 읽어요.').join('\n')
      : '책을 읽고 남긴 생각';
  Map<String, dynamic> _item(int id) => {
        'diaryId': id,
        'bookTitle': id == 20 ? '첫 번째 책' : '두 번째 책',
        'bookCover': '',
        'content': content,
        'createdAt': '2025-01-02T12:00:00',
        'images': [],
      };
}

Future<void> _pump(WidgetTester tester, _ArchiveApi api,
    {bool detail = false, double scale = 1}) async {
  tester.view.physicalSize = const Size(320, 568);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(ProviderScope(
      overrides: [
        dioClientProvider.overrideWithValue(api.dio),
        learningAccountProvider.overrideWithValue(1),
      ],
      child: MaterialApp(
          theme: LearningColors.theme,
          builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(scale)),
                child: child!,
              ),
          home: detail
              ? const LearningArchiveDetailScreen(diaryId: 20)
              : const LearningArchiveScreen())));
  await tester.pumpAndSettle();
}

Future<void> _reveal(WidgetTester tester, Finder finder) async {
  final scrollable = find.byType(Scrollable).first;
  tester.state<ScrollableState>(scrollable).position.jumpTo(0);
  await tester.pump();
  await tester.scrollUntilVisible(finder, 240,
      scrollable: scrollable, maxScrolls: 150);
  await tester.pumpAndSettle();
}
