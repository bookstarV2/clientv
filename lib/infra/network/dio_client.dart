import 'dart:developer' as dev;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../modules/auth/view_model/auth_view_model.dart';

part 'dio_client.g.dart';

String get apiBaseUrl {
  const override = String.fromEnvironment('API_BASE_URL');
  return override.isNotEmpty ? override : dotenv.env['BASE_URL']!;
}

@Riverpod(keepAlive: true)
Dio dioClient(Ref ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 30),
      contentType: 'application/json',
    ),
  );

  dio.interceptors.add(CustomInterceptor(ref));

  return dio;
}

@Riverpod(keepAlive: true)
Dio baseDio(Ref ref) {
  return Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 30),
      contentType: 'application/json',
    ),
  );
}

class CustomInterceptor extends Interceptor {
  static const _sessionKey = 'bookstar.authSessionVersion';
  final Ref _ref;

  CustomInterceptor(this._ref);

  bool _isCurrent(RequestOptions options) =>
      options.cancelToken?.isCancelled != true &&
      options.extra[_sessionKey] ==
          _ref.read(authViewModelProvider.notifier).sessionVersion;

  DioException _staleRequest(RequestOptions options) => DioException(
        requestOptions: options,
        type: DioExceptionType.cancel,
        message: 'The request belongs to an ended session or was cancelled.',
      );

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    if (kDebugMode) {
      dev.log('[DIO] REQUEST: ${options.method} ${options.path}',
          name: 'NETWORK');
    }

    final auth = _ref.read(authViewModelProvider.notifier);
    options.extra[_sessionKey] = auth.sessionVersion;
    try {
      if (options.path != '/login') {
        final tokens = await auth.getTokens();
        if (!_isCurrent(options)) {
          return handler.reject(_staleRequest(options));
        }
        if (tokens.accessToken != null) {
          options.headers['Authorization'] = options.path == '/renew'
              ? 'Bearer ${tokens.refreshToken}'
              : 'Bearer ${tokens.accessToken}';
        }
      }
      if (!_isCurrent(options)) {
        return handler.reject(_staleRequest(options));
      }
      handler.next(options);
    } catch (_) {
      handler.reject(DioException(
          requestOptions: options,
          message: 'Session credentials unavailable.'));
    }
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (!_isCurrent(response.requestOptions)) {
      return handler.reject(_staleRequest(response.requestOptions));
    }
    if (kDebugMode) {
      dev.log(
          '[DIO] RESPONSE: ${response.statusCode} ${response.requestOptions.path}',
          name: 'NETWORK');
    }
    super.onResponse(response, handler);
  }

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    if (kDebugMode) {
      dev.log(
          '[DIO] ERROR: ${err.response?.statusCode} ${err.requestOptions.path}',
          name: 'NETWORK');
    }

    if (!_isCurrent(err.requestOptions)) {
      return handler.next(_staleRequest(err.requestOptions));
    }
    if (err.response?.statusCode == 401 &&
        err.requestOptions.path != '/login' &&
        err.requestOptions.path != '/renew') {
      final options = err.requestOptions;
      try {
        final newAuthData =
            await _ref.read(authViewModelProvider.notifier).refreshToken();
        if (!_isCurrent(options)) {
          return handler.next(_staleRequest(options));
        }
        if (newAuthData == null) return handler.next(err);
        options.headers['Authorization'] = 'Bearer ${newAuthData.accessToken}';
        final response = await _ref.read(baseDioProvider).fetch(options);
        if (!_isCurrent(options)) {
          return handler.next(_staleRequest(options));
        }
        return handler.resolve(response);
      } on DioException catch (error) {
        return handler
            .next(_isCurrent(options) ? error : _staleRequest(options));
      } catch (_) {
        return handler.next(err);
      }
    }
    super.onError(err, handler);
  }
}
