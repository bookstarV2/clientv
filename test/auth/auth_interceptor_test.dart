import 'dart:async';
import 'dart:typed_data';

import 'package:bookstar/common/models/response_form.dart';
import 'package:bookstar/common/models/status_response.dart';
import 'package:bookstar/infra/network/dio_client.dart';
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
  test('same-session 401 renews once and replays the original write', () async {
    final fixture = await _Fixture.create();
    fixture.original.respond = (_) async => _body(401);
    fixture.repository.renew = () async => _authResponse(7, revision: 1);

    final result = await fixture.dio.post<dynamic>('/error-reports',
        data: {'description': 'synthetic report'});

    expect(result.statusCode, 200);
    expect(fixture.repository.renewCalls, 2);
    expect(fixture.original.calls, 1);
    expect(fixture.replay.calls, 1);
    expect(fixture.replay.lastMethod, 'POST');
    expect(fixture.replay.lastPath, '/error-reports');
    expect(fixture.replay.lastData, {'description': 'synthetic report'});
    expect(fixture.replay.usedCredentialsFor(7, revision: 1), isTrue);
  });

  test('old-account 401 cannot renew or replay with the new account', () async {
    final fixture = await _Fixture.create();
    final pending = Completer<ResponseBody>();
    fixture.original.respond = (_) => pending.future;
    final result = _outcome(fixture.dio.post<dynamic>('/error-reports',
        data: {'description': 'account A report'}));
    await fixture.original.started.future;

    await fixture.switchAccount(8);
    final callsAfterSwitch = fixture.repository.renewCalls;
    pending.complete(_body(401));

    expect(await result, _cancelled);
    expect(fixture.repository.renewCalls, callsAfterSwitch);
    expect(fixture.replay.calls, 0);
    expect(fixture.container.read(authViewModelProvider).valueOrNull,
        isA<AuthSuccess>().having((state) => state.memberId, 'member', 8));
  });

  test('old-account successful response cannot update the new session',
      () async {
    final fixture = await _Fixture.create();
    final pending = Completer<ResponseBody>();
    fixture.original.respond = (_) => pending.future;
    final result = _outcome(fixture.dio.get<dynamic>('/learning/books'));
    await fixture.original.started.future;

    await fixture.switchAccount(8);
    pending.complete(_body(200));

    expect(await result, _cancelled);
    expect(fixture.replay.calls, 0);
    expect(fixture.repository.renewCalls, 2);
  });

  test('session change during token read prevents even the first dispatch',
      () async {
    final fixture = await _Fixture.create();
    fixture.storage.accessReadGate = Completer<void>();
    final result = _outcome(fixture.dio.post<dynamic>('/error-reports',
        data: {'description': 'not dispatched'}));
    await fixture.storage.accessReadStarted.future;

    await fixture.switchAccount(8);
    fixture.storage.accessReadGate!.complete();

    expect(await result, _cancelled);
    expect(fixture.original.calls, 0);
    expect(fixture.replay.calls, 0);
    expect(fixture.repository.renewCalls, 2);
  });

  test('logout during renew cancels the original request without replay',
      () async {
    final fixture = await _Fixture.create();
    fixture.original.respond = (_) async => _body(401);
    final pending = Completer<ResponseForm<AuthResponse?>>();
    final renewing = Completer<void>();
    fixture.repository.renew = () {
      renewing.complete();
      return pending.future;
    };
    final result = _outcome(fixture.dio.get<dynamic>('/learning/books'));
    await renewing.future;

    final logout = fixture.auth.signOut();
    pending.complete(_authResponse(7));
    await logout;

    expect(await result, _cancelled);
    expect(fixture.replay.calls, 0);
    expect(fixture.storage.isEmpty, isTrue);
  });

  test('logout while replay is pending discards its successful response',
      () async {
    final fixture = await _Fixture.create();
    fixture.original.respond = (_) async => _body(401);
    final pending = Completer<ResponseBody>();
    fixture.replay.respond = (_) => pending.future;
    final result = _outcome(fixture.dio.get<dynamic>('/learning/books'));
    await fixture.replay.started.future;

    await fixture.auth.signOut();
    pending.complete(_body(200));

    expect(await result, _cancelled);
    expect(fixture.replay.calls, 1);
    expect(fixture.storage.isEmpty, isTrue);
  });

  test('cancelled original request does not renew when a delayed 401 arrives',
      () async {
    final fixture = await _Fixture.create();
    final pending = Completer<ResponseBody>();
    fixture.original.respond = (_) => pending.future;
    final cancellation = CancelToken();
    final result = _outcome(
        fixture.dio.get<dynamic>('/learning/books', cancelToken: cancellation));
    await fixture.original.started.future;

    cancellation.cancel('isolated test cancellation');
    pending.complete(_body(401));

    expect(await result, _cancelled);
    expect(fixture.repository.renewCalls, 1);
    expect(fixture.replay.calls, 0);
  });

  test('cancellation while renewal is pending prevents replay', () async {
    final fixture = await _Fixture.create();
    fixture.original.respond = (_) async => _body(401);
    final pending = Completer<ResponseForm<AuthResponse?>>();
    final renewing = Completer<void>();
    fixture.repository.renew = () {
      renewing.complete();
      return pending.future;
    };
    final cancellation = CancelToken();
    final result = _outcome(
        fixture.dio.get<dynamic>('/learning/books', cancelToken: cancellation));
    await renewing.future;

    cancellation.cancel('isolated test cancellation');
    pending.complete(_authResponse(7));
    await fixture.auth.refreshToken();
    await Future<void>.delayed(Duration.zero);

    expect(await result, _cancelled);
    expect(fixture.replay.calls, 0);
  });

  test('storage read failure terminates without dispatch or credential loss',
      () async {
    final fixture = await _Fixture.create();
    fixture.storage.accessReadError = StateError('isolated storage failure');

    final result = await _outcome(fixture.dio.get<dynamic>('/learning/books'));

    expect(result, isA<DioException>());
    expect(fixture.original.calls, 0);
    expect(fixture.replay.calls, 0);
    expect(fixture.storage.isEmpty, isFalse);
    expect(fixture.repository.renewCalls, 1);
  });

  for (final path in ['/login', '/renew']) {
    test('$path 401 is never recursively renewed or replayed', () async {
      final fixture = await _Fixture.create();
      fixture.original.respond = (_) async => _body(401);

      final result = await _outcome(fixture.dio.post<dynamic>(path));

      expect(
          result,
          isA<DioException>()
              .having((error) => error.response?.statusCode, 'status', 401));
      expect(fixture.repository.renewCalls, 1);
      expect(fixture.replay.calls, 0);
    });
  }

  test('offline renew preserves credentials and returns the original 401',
      () async {
    final fixture = await _Fixture.create();
    fixture.original.respond = (_) async => _body(401);
    fixture.repository.renew = () async => throw DioException(
        requestOptions: RequestOptions(path: '/renew'),
        type: DioExceptionType.connectionError);

    final result = await _outcome(fixture.dio.get<dynamic>('/learning/books'));

    expect(
        result,
        isA<DioException>()
            .having((error) => error.response?.statusCode, 'status', 401));
    expect(fixture.repository.renewCalls, 2);
    expect(fixture.replay.calls, 0);
    expect(fixture.storage.isEmpty, isFalse);
    expect(fixture.container.read(authViewModelProvider).valueOrNull,
        isA<AuthRestoreFailed>());
  });
}

final _cancelled = isA<DioException>()
    .having((error) => error.type, 'type', DioExceptionType.cancel);

Future<Object?> _outcome(Future<Response<dynamic>> request) async {
  try {
    return await request;
  } catch (error) {
    return error;
  }
}

ResponseBody _body(int status) =>
    ResponseBody.fromString('{"ok":true}', status, headers: {
      'content-type': ['application/json']
    });

class _Fixture {
  final storage = _Storage();
  final repository = _Repository();
  final original = _Adapter();
  final replay = _Adapter();
  late final ProviderContainer container;
  late final Dio dio;
  AuthViewModel get auth => container.read(authViewModelProvider.notifier);

  static Future<_Fixture> create() async {
    final fixture = _Fixture();
    final replayDio = Dio(BaseOptions(baseUrl: 'https://example.invalid'))
      ..httpClientAdapter = fixture.replay;
    fixture.container = ProviderContainer(overrides: [
      secureStorageRepositoryProvider.overrideWithValue(fixture.storage),
      authRepositoryProvider.overrideWithValue(fixture.repository),
      baseDioProvider.overrideWithValue(replayDio),
      dioClientProvider.overrideWith((ref) {
        return Dio(BaseOptions(baseUrl: 'https://example.invalid'))
          ..httpClientAdapter = fixture.original
          ..interceptors.add(CustomInterceptor(ref));
      }),
    ]);
    fixture.dio = fixture.container.read(dioClientProvider);
    addTearDown(() {
      fixture.dio.close(force: true);
      replayDio.close(force: true);
      fixture.container.dispose();
    });
    await fixture.container.read(authViewModelProvider.future);
    return fixture;
  }

  Future<void> switchAccount(int memberId) async {
    await auth.signOut();
    await storage.saveTokens(
        accessToken: 'synthetic-access-$memberId',
        refreshToken: 'synthetic-refresh-$memberId');
    repository.renew = () async => _authResponse(memberId);
    await auth.refreshToken();
  }
}

class _Adapter implements HttpClientAdapter {
  Future<ResponseBody> Function(RequestOptions) respond =
      (_) async => _body(200);
  final started = Completer<void>();
  int calls = 0;
  String? lastMethod;
  String? lastPath;
  Object? lastData;
  Object? _authorization;

  bool usedCredentialsFor(int memberId, {int revision = 0}) =>
      _authorization == 'Bearer synthetic-access-$memberId-$revision';

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) {
    calls++;
    lastMethod = options.method;
    lastPath = options.path;
    lastData = options.data;
    _authorization = options.headers['Authorization'];
    if (!started.isCompleted) started.complete();
    return respond(options);
  }

  @override
  void close({bool force = false}) {}
}

class _Storage extends SecureStorageRepository {
  String? _access = 'synthetic-access-7';
  String? _refresh = 'synthetic-refresh-7';
  Completer<void>? accessReadGate;
  Object? accessReadError;
  final accessReadStarted = Completer<void>();
  bool get isEmpty => _access == null && _refresh == null;

  @override
  Future<String?> getAccessToken() async {
    if (accessReadError case final error?) throw error;
    final snapshot = _access;
    if (!accessReadStarted.isCompleted) accessReadStarted.complete();
    await accessReadGate?.future;
    return snapshot;
  }

  @override
  Future<String?> getRefreshToken() async => _refresh;

  @override
  Future<void> saveTokens(
      {required String accessToken, required String refreshToken}) async {
    _access = accessToken;
    _refresh = refreshToken;
  }

  @override
  Future<void> deleteTokens() async {
    _access = null;
    _refresh = null;
  }
}

const _ok = StatusResponse(resultCode: 'OK', resultMessage: 'OK');

ResponseForm<AuthResponse?> _authResponse(int memberId, {int revision = 0}) =>
    ResponseForm(
      statusResponse: _ok,
      data: AuthResponse(
        memberId: memberId,
        accessToken: 'synthetic-access-$memberId-$revision',
        refreshToken: 'synthetic-refresh-$memberId',
        accessTokenExpiration: DateTime.utc(2030),
        refreshTokenExpiration: DateTime.utc(2031),
        memberRole: MemberRole.USER,
      ),
    );

class _Repository implements AuthRepository {
  Future<ResponseForm<AuthResponse?>> Function() renew =
      () async => _authResponse(7);
  int renewCalls = 0;

  @override
  Future<ResponseForm<AuthResponse?>> renewToken(String refreshToken) {
    renewCalls++;
    return renew();
  }

  @override
  Future<ResponseForm<void>> withdraw() async =>
      const ResponseForm<void>(statusResponse: _ok, data: null);

  @override
  Future<ResponseForm<AuthResponse>> login(LoginRequest request) =>
      throw UnimplementedError('OAuth must not run in interceptor tests');

  @override
  Future<ResponseForm<dynamic>> loginByAccessToken(String accessToken) =>
      throw UnimplementedError('External login must not run in these tests');
}
