import 'dart:async';

import 'package:bookstar/common/models/response_form.dart';
import 'package:bookstar/common/models/status_response.dart';
import 'package:bookstar/infra/storage/secure_storage.dart';
import 'package:bookstar/modules/auth/model/auth_response.dart';
import 'package:bookstar/modules/auth/model/login_request.dart';
import 'package:bookstar/modules/auth/repository/auth_repository.dart';
import 'package:bookstar/modules/auth/view_model/auth_state.dart';
import 'package:bookstar/modules/auth/view_model/auth_view_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('missing refresh credentials stays idle without calling renew',
      () async {
    final storage = _MemoryStorage(access: null, refresh: null);
    final repository = _FakeAuthRepository();
    final container = _container(storage, repository);

    expect(await container.read(authViewModelProvider.future), isA<AuthIdle>());
    expect(repository.renewCalls, 0);
    expect(storage.deleteCalls, 0);
  });

  test('offline restoration preserves credentials and exposes retry state',
      () async {
    final storage = _MemoryStorage();
    final repository = _FakeAuthRepository()
      ..renew = (_) async => throw _networkFailure();
    final container = _container(storage, repository);

    expect(await container.read(authViewModelProvider.future),
        isA<AuthRestoreFailed>());
    expect(storage.hasOriginalCredentials, isTrue);
    expect(storage.deleteCalls, 0);
    expect(storage.saveCalls, 0);
  });

  test('initial storage read failure preserves credentials and retry recovers',
      () async {
    final storage = _MemoryStorage()..refreshReadFailures = 1;
    final repository = _FakeAuthRepository();
    final container = _container(storage, repository);

    expect(await container.read(authViewModelProvider.future),
        isA<AuthRestoreFailed>());
    expect(storage.hasOriginalCredentials, isTrue);
    expect(storage.deleteCalls, 0);
    expect(storage.saveCalls, 0);
    expect(repository.renewCalls, 0);

    await container.read(authViewModelProvider.notifier).retryStoredSession();

    expect(
        container.read(authViewModelProvider).valueOrNull, isA<AuthSuccess>());
    expect(storage.hasRotatedCredentials, isTrue);
    expect(repository.renewCalls, 1);
    expect(storage.saveCalls, 1);
    expect(storage.deleteCalls, 0);
  });

  test(
      'retry storage read failure completes with retry state instead of throwing',
      () async {
    final storage = _MemoryStorage()..refreshReadFailures = 2;
    final repository = _FakeAuthRepository();
    final container = _container(storage, repository);
    await container.read(authViewModelProvider.future);
    final notifier = container.read(authViewModelProvider.notifier);

    await notifier.retryStoredSession();

    expect(container.read(authViewModelProvider).valueOrNull,
        isA<AuthRestoreFailed>());
    expect(container.read(authViewModelProvider).isLoading, isFalse);
    expect(container.read(authViewModelProvider).hasError, isFalse);
    expect(storage.hasOriginalCredentials, isTrue);
    expect(storage.deleteCalls, 0);
    expect(repository.renewCalls, 0);

    await notifier.retryStoredSession();

    expect(
        container.read(authViewModelProvider).valueOrNull, isA<AuthSuccess>());
    expect(repository.renewCalls, 1);
  });

  test(
      'logout during pending credential read prevents renew and session revival',
      () async {
    final storage = _MemoryStorage()..refreshReadGate = Completer<void>();
    final repository = _FakeAuthRepository();
    final container = _container(storage, repository);
    final initial = container.read(authViewModelProvider.future);
    await storage.refreshReadStarted.future;

    final logout = container.read(authViewModelProvider.notifier).signOut();
    storage.refreshReadGate!.complete();
    await logout;
    await initial;

    expect(repository.renewCalls, 0);
    expect(storage.saveCalls, 0);
    expect(storage.deleteCalls, 1);
    expect(storage.isEmpty, isTrue);
    expect(container.read(authViewModelProvider).valueOrNull, isA<AuthIdle>());
  });

  test('retry after offline restores session and rotates credentials once',
      () async {
    final storage = _MemoryStorage();
    final repository = _FakeAuthRepository()
      ..renew = (_) async => throw _networkFailure();
    final container = _container(storage, repository);
    await container.read(authViewModelProvider.future);
    repository.renew = (_) async => _response();

    final result =
        await container.read(authViewModelProvider.notifier).refreshToken();

    expect(result?.memberId, 7);
    expect(container.read(authViewModelProvider).valueOrNull,
        isA<AuthSuccess>().having((state) => state.memberId, 'member', 7));
    expect(repository.renewCalls, 2);
    expect(storage.hasRotatedCredentials, isTrue);
    expect(storage.saveCalls, 1);
    expect(storage.deleteCalls, 0);
  });

  for (final status in [401, 403]) {
    test('renew $status clears credentials and returns idle', () async {
      final storage = _MemoryStorage();
      final repository = _FakeAuthRepository()
        ..renew = (_) async => throw _httpFailure(status);
      final container = _container(storage, repository);

      expect(
          await container.read(authViewModelProvider.future), isA<AuthIdle>());
      expect(storage.isEmpty, isTrue);
      expect(storage.deleteCalls, 1);
      expect(storage.saveCalls, 0);
    });
  }

  for (final status in [429, 500, 503]) {
    test('temporary renew $status keeps stored credentials', () async {
      final storage = _MemoryStorage();
      final repository = _FakeAuthRepository()
        ..renew = (_) async => throw _httpFailure(status);
      final container = _container(storage, repository);

      expect(await container.read(authViewModelProvider.future),
          isA<AuthRestoreFailed>());
      expect(storage.hasOriginalCredentials, isTrue);
      expect(storage.deleteCalls, 0);
    });
  }

  for (final code in ['B302', 'B303', 'M001']) {
    test('permanent session error $code clears credentials even with HTTP 404',
        () async {
      final storage = _MemoryStorage();
      final repository = _FakeAuthRepository()
        ..renew = (_) async => throw _httpFailure(404, code: code);
      final container = _container(storage, repository);

      expect(
          await container.read(authViewModelProvider.future), isA<AuthIdle>());
      expect(storage.isEmpty, isTrue);
      expect(storage.deleteCalls, 1);
    });
  }

  test('unknown server error does not erase stored credentials', () async {
    final storage = _MemoryStorage();
    final repository = _FakeAuthRepository()
      ..renew = (_) async => throw _httpFailure(500, code: 'UNKNOWN');
    final container = _container(storage, repository);

    expect(await container.read(authViewModelProvider.future),
        isA<AuthRestoreFailed>());
    expect(storage.hasOriginalCredentials, isTrue);
    expect(storage.deleteCalls, 0);
  });

  test('retryStoredSession shows loading while retry is pending then succeeds',
      () async {
    final storage = _MemoryStorage();
    final repository = _FakeAuthRepository()
      ..renew = (_) async => throw _networkFailure();
    final container = _container(storage, repository);
    await container.read(authViewModelProvider.future);
    final pending = Completer<ResponseForm<AuthResponse?>>();
    repository.renew = (_) => pending.future;

    final retry =
        container.read(authViewModelProvider.notifier).retryStoredSession();
    expect(container.read(authViewModelProvider).isLoading, isTrue);
    pending.complete(_response());
    await retry;

    expect(container.read(authViewModelProvider).isLoading, isFalse);
    expect(
        container.read(authViewModelProvider).valueOrNull, isA<AuthSuccess>());
    expect(storage.hasRotatedCredentials, isTrue);
    expect(repository.renewCalls, 2);
  });

  test('concurrent restoration callers share one renew request', () async {
    final storage = _MemoryStorage();
    final pending = Completer<ResponseForm<AuthResponse?>>();
    final repository = _FakeAuthRepository()..renew = (_) => pending.future;
    final container = _container(storage, repository);
    final initial = container.read(authViewModelProvider.future);
    await repository.firstRenewStarted.future;
    final notifier = container.read(authViewModelProvider.notifier);

    final first = notifier.refreshToken();
    final second = notifier.refreshToken();
    final third = notifier.refreshToken();
    expect(identical(first, second), isTrue);
    expect(identical(second, third), isTrue);
    pending.complete(_response());
    await Future.wait([first, second, third]);
    await initial;

    expect(repository.renewCalls, 1);
    expect(storage.saveCalls, 1);
    expect(storage.hasRotatedCredentials, isTrue);
  });

  test('sign out waits for in-flight renew and prevents session resurrection',
      () async {
    final storage = _MemoryStorage();
    final pending = Completer<ResponseForm<AuthResponse?>>();
    final repository = _FakeAuthRepository()..renew = (_) => pending.future;
    final container = _container(storage, repository);
    final initial = container.read(authViewModelProvider.future);
    await repository.firstRenewStarted.future;

    final signOut = container.read(authViewModelProvider.notifier).signOut();
    pending.complete(_response());
    await signOut;
    await initial;

    expect(storage.isEmpty, isTrue);
    expect(storage.saveCalls, 0);
    expect(container.read(authViewModelProvider).valueOrNull, isA<AuthIdle>());
  });

  test('sign out deletes credentials after an already-started storage write',
      () async {
    final storage = _MemoryStorage()..saveGate = Completer<void>();
    final repository = _FakeAuthRepository();
    final container = _container(storage, repository);
    final initial = container.read(authViewModelProvider.future);
    await storage.saveStarted.future;

    final signOut = container.read(authViewModelProvider.notifier).signOut();
    storage.saveGate!.complete();
    await signOut;
    await initial;

    expect(storage.events, ['saved', 'deleted']);
    expect(storage.isEmpty, isTrue);
    expect(container.read(authViewModelProvider).valueOrNull, isA<AuthIdle>());
  });

  test('withdrawal finishes after refresh and clears the restored session',
      () async {
    final storage = _MemoryStorage();
    final pending = Completer<ResponseForm<AuthResponse?>>();
    final repository = _FakeAuthRepository()..renew = (_) => pending.future;
    final container = _container(storage, repository);
    final initial = container.read(authViewModelProvider.future);
    await repository.firstRenewStarted.future;

    final withdraw = container.read(authViewModelProvider.notifier).withdraw();
    pending.complete(_response());
    await withdraw;
    await initial;

    expect(repository.withdrawCalls, 1);
    expect(storage.isEmpty, isTrue);
    expect(container.read(authViewModelProvider).valueOrNull,
        isA<AuthWithdrawCompleted>());
  });

  test('failed withdrawal preserves current credentials and authentication',
      () async {
    final storage = _MemoryStorage();
    final repository = _FakeAuthRepository();
    final container = _container(storage, repository);
    await container.read(authViewModelProvider.future);
    repository.withdrawError = _networkFailure();

    await expectLater(container.read(authViewModelProvider.notifier).withdraw(),
        throwsA(isA<DioException>()));

    expect(storage.hasRotatedCredentials, isTrue);
    expect(storage.deleteCalls, 0);
    expect(
        container.read(authViewModelProvider).valueOrNull, isA<AuthSuccess>());
  });

  test('renew started while sign out deletes storage cannot revive a session',
      () async {
    final storage = _MemoryStorage();
    final repository = _FakeAuthRepository();
    final container = _container(storage, repository);
    await container.read(authViewModelProvider.future);
    final notifier = container.read(authViewModelProvider.notifier);
    storage.deleteGate = Completer<void>();
    final signOut = notifier.signOut();
    await storage.deleteStarted.future;
    final pending = Completer<ResponseForm<AuthResponse?>>();
    repository.renew = (_) => pending.future;
    final lateRefresh = notifier.refreshToken();
    await Future<void>.delayed(Duration.zero);
    storage.deleteGate!.complete();
    await signOut;
    pending.complete(_response());
    await lateRefresh;

    expect(storage.isEmpty, isTrue);
    expect(container.read(authViewModelProvider).valueOrNull, isA<AuthIdle>());
  });

  test('renew started while withdrawal deletes storage cannot revive a session',
      () async {
    final storage = _MemoryStorage();
    final repository = _FakeAuthRepository();
    final container = _container(storage, repository);
    await container.read(authViewModelProvider.future);
    final notifier = container.read(authViewModelProvider.notifier);
    storage.deleteGate = Completer<void>();
    final withdraw = notifier.withdraw();
    await storage.deleteStarted.future;
    final pending = Completer<ResponseForm<AuthResponse?>>();
    repository.renew = (_) => pending.future;
    final lateRefresh = notifier.refreshToken();
    await Future<void>.delayed(Duration.zero);
    storage.deleteGate!.complete();
    await withdraw;
    pending.complete(_response());
    await lateRefresh;

    expect(storage.isEmpty, isTrue);
    expect(container.read(authViewModelProvider).valueOrNull,
        isA<AuthWithdrawCompleted>());
  });
}

ProviderContainer _container(
    _MemoryStorage storage, _FakeAuthRepository repository) {
  final container = ProviderContainer(overrides: [
    secureStorageRepositoryProvider.overrideWithValue(storage),
    authRepositoryProvider.overrideWithValue(repository),
  ]);
  addTearDown(container.dispose);
  return container;
}

const _ok = StatusResponse(resultCode: 'OK', resultMessage: 'OK');

ResponseForm<AuthResponse?> _response() => ResponseForm(
      statusResponse: _ok,
      data: AuthResponse(
        memberId: 7,
        nickName: 'test-reader',
        providerType: 'GOOGLE',
        accessToken: 'synthetic-rotated-access',
        refreshToken: 'synthetic-rotated-refresh',
        accessTokenExpiration: DateTime.utc(2030),
        refreshTokenExpiration: DateTime.utc(2031),
        memberRole: MemberRole.USER,
      ),
    );

DioException _networkFailure() => DioException(
      requestOptions: RequestOptions(path: '/renew'),
      type: DioExceptionType.connectionError,
      message: 'isolated offline test',
    );

DioException _httpFailure(int status, {String? code}) {
  final request = RequestOptions(path: '/renew');
  return DioException(
    requestOptions: request,
    type: DioExceptionType.badResponse,
    response: Response(
      requestOptions: request,
      statusCode: status,
      data: code == null
          ? null
          : {
              'statusResponse': {'resultCode': code},
            },
    ),
  );
}

class _MemoryStorage extends SecureStorageRepository {
  _MemoryStorage({
    this.access = 'synthetic-original-access',
    this.refresh = 'synthetic-original-refresh',
  });

  String? access;
  String? refresh;
  int saveCalls = 0;
  int deleteCalls = 0;
  int refreshReadFailures = 0;
  final events = <String>[];
  Completer<void>? saveGate;
  Completer<void>? deleteGate;
  Completer<void>? refreshReadGate;
  final refreshReadStarted = Completer<void>();
  final saveStarted = Completer<void>();
  final deleteStarted = Completer<void>();

  bool get isEmpty => access == null && refresh == null;
  bool get hasOriginalCredentials =>
      access == 'synthetic-original-access' &&
      refresh == 'synthetic-original-refresh';
  bool get hasRotatedCredentials =>
      access == 'synthetic-rotated-access' &&
      refresh == 'synthetic-rotated-refresh';

  @override
  Future<String?> getAccessToken() async => access;

  @override
  Future<String?> getRefreshToken() async {
    final snapshot = refresh;
    if (!refreshReadStarted.isCompleted) refreshReadStarted.complete();
    await refreshReadGate?.future;
    if (refreshReadFailures > 0) {
      refreshReadFailures--;
      throw StateError('isolated credential read failure');
    }
    return snapshot;
  }

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    saveCalls++;
    if (!saveStarted.isCompleted) saveStarted.complete();
    await saveGate?.future;
    access = accessToken;
    refresh = refreshToken;
    events.add('saved');
  }

  @override
  Future<void> deleteTokens() async {
    deleteCalls++;
    if (!deleteStarted.isCompleted) deleteStarted.complete();
    await deleteGate?.future;
    access = null;
    refresh = null;
    events.add('deleted');
  }
}

class _FakeAuthRepository implements AuthRepository {
  Future<ResponseForm<AuthResponse?>> Function(String) renew =
      (_) async => _response();
  int renewCalls = 0;
  int withdrawCalls = 0;
  Object? withdrawError;
  final firstRenewStarted = Completer<void>();

  @override
  Future<ResponseForm<AuthResponse?>> renewToken(String refreshToken) {
    renewCalls++;
    if (!firstRenewStarted.isCompleted) firstRenewStarted.complete();
    return renew(refreshToken);
  }

  @override
  Future<ResponseForm<void>> withdraw() async {
    withdrawCalls++;
    if (withdrawError case final error?) throw error;
    return const ResponseForm<void>(statusResponse: _ok, data: null);
  }

  @override
  Future<ResponseForm<AuthResponse>> login(LoginRequest request) =>
      throw UnimplementedError(
          'social login must not run in restoration tests');

  @override
  Future<ResponseForm<dynamic>> loginByAccessToken(String accessToken) =>
      throw UnimplementedError('access-token login is outside these tests');
}
