import 'package:bookstar/infra/network/dio_client.dart';
import 'package:bookstar/modules/auth/model/policy.dart';
import 'package:bookstar/modules/learning/data/learning_access.dart';
import 'package:bookstar/modules/learning/data/learning_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('return path accepts only known internal learning destinations', () {
    for (final path in [
      '/quiz',
      '/library',
      '/review',
      '/settings',
      '/library/search',
      '/settings/archive',
      '/library/12/chapters',
      '/library/12/quiz/34',
      '/review/quiz/34',
    ]) {
      expect(learningReturnPath(path), path, reason: path);
    }
    expect(learningReturnPath('/library/search?next=https://outside.invalid#x'),
        '/library/search');
  });

  test('external schemes authorities malformed and unrelated paths fall back',
      () {
    for (final path in <String?>[
      null,
      '',
      'https://outside.invalid/library/search',
      '//outside.invalid/library/search',
      'javascript:alert(1)',
      'data:text/html,hello',
      'file:///library/search',
      '/%2f%2foutside.invalid',
      '/library%2fsearch',
      '/login',
      '/policies/privacy',
      '/settings/delete-account',
      '/library/0/chapters',
      '/library/-1/chapters',
      '/library/2/quiz/not-a-number',
      '/review/quiz/0',
      '/book-log',
    ]) {
      expect(learningReturnPath(path), '/quiz', reason: '$path');
    }
  });

  test('entry URL carries one normalized local next without query injection',
      () {
    final location = Uri.parse(
        learningEntryLocation('/login', '/library/search?other=1#fragment'));
    expect(location.path, '/login');
    expect(location.queryParameters, {'next': '/library/search'});
    expect(
        Uri.parse(learningEntryLocation('/entry', 'https://outside.invalid'))
            .queryParameters['next'],
        '/quiz');
  });

  test('required agreements need both flags and never require marketing', () {
    expect(hasRequiredLearningPolicy(null), isFalse);
    expect(hasRequiredLearningPolicy(const Policy()), isFalse);
    expect(
        hasRequiredLearningPolicy(
            const Policy(serviceUsingAgree: PolicyAgree.Y)),
        isFalse);
    expect(
        hasRequiredLearningPolicy(
            const Policy(personalInformationAgree: PolicyAgree.Y)),
        isFalse);
    for (final marketing in PolicyAgree.values) {
      expect(
          hasRequiredLearningPolicy(Policy(
              serviceUsingAgree: PolicyAgree.Y,
              personalInformationAgree: PolicyAgree.Y,
              marketingAgree: marketing)),
          isTrue);
    }
  });

  test('account switch reloads personal books reviews and repository identity',
      () async {
    final account = StateProvider<int?>((ref) => 1);
    late ProviderContainer container;
    final dio = Dio(BaseOptions(baseUrl: 'http://example.invalid'));
    final requests = <String>[];
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      final memberId = container.read(account);
      requests.add('$memberId:${options.path}');
      final data = options.path == '/api/v3/quiz-reviews'
          ? {
              'items': [],
              'totalCount': memberId ?? 0,
              'dueCount': 0,
              'reviewedTodayCount': 0,
              'hasNext': false,
            }
          : {
              'challenges': [
                {'bookTitle': 'member-$memberId-book'}
              ],
            };
      handler.resolve(Response(requestOptions: options, statusCode: 200, data: {
        'statusResponse': {'resultCode': 'OK', 'resultMessage': 'OK'},
        'data': data,
      }));
    }));
    container = ProviderContainer(overrides: [
      dioClientProvider.overrideWithValue(dio),
      learningAccountProvider.overrideWith((ref) => ref.watch(account)),
    ]);
    addTearDown(container.dispose);
    final firstRepository = container.read(learningRepositoryProvider);
    expect(
        (await container.read(learningBooksProvider.future)).single.bookTitle,
        'member-1-book');
    expect(
        (await container.read(finishedLearningBooksProvider.future))
            .single
            .bookTitle,
        'member-1-book');
    expect((await container.read(reviewOverviewProvider.future)).totalCount, 1);

    container.read(account.notifier).state = 2;
    await container.pump();
    expect(container.read(learningRepositoryProvider),
        isNot(same(firstRepository)));
    expect(
        (await container.read(learningBooksProvider.future)).single.bookTitle,
        'member-2-book');
    expect(
        (await container.read(finishedLearningBooksProvider.future))
            .single
            .bookTitle,
        'member-2-book');
    expect((await container.read(reviewOverviewProvider.future)).totalCount, 2);
    expect(requests.where((request) => request.startsWith('2:')), hasLength(3));

    container.read(account.notifier).state = null;
    await container.pump();
    final requestsBeforeBooks = requests.length;
    expect(await container.read(learningBooksProvider.future), isEmpty);
    expect(await container.read(finishedLearningBooksProvider.future), isEmpty);
    expect(requests.length, requestsBeforeBooks);
  });
}
