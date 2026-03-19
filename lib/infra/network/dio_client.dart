import 'dart:developer' as dev;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../modules/auth/view_model/auth_view_model.dart';

part 'dio_client.g.dart';

@Riverpod(keepAlive: true)
Dio dioClient(Ref ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: dotenv.env['BASE_URL']!,
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
      baseUrl: dotenv.env['BASE_URL']!,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 30),
      contentType: 'application/json',
    ),
  );
}

class CustomInterceptor extends Interceptor {
  final Ref _ref;

  CustomInterceptor(this._ref);

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    if (kDebugMode) {
      dev.log('[DIO] REQUEST: ${options.method} ${options.path}', name: 'NETWORK');
    }
    
    if (options.path == '/login') {
      // login은 토큰이 없어도 가능
    } else {
      final tokens = await _ref.read(authViewModelProvider.notifier).getTokens();
      if (tokens.accessToken != null) {
        if (options.path == '/renew') {
          options.headers['Authorization'] = 'Bearer ${tokens.refreshToken}';
        } else {
          options.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
        }
      }
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      dev.log('[DIO] RESPONSE: ${response.statusCode} ${response.requestOptions.path}', name: 'NETWORK');
    }
    super.onResponse(response, handler);
  }

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    if (kDebugMode) {
      dev.log('[DIO] ERROR: ${err.response?.statusCode} ${err.requestOptions.path}', name: 'NETWORK');
    }

    if (err.response?.statusCode == 401 &&
        err.requestOptions.path != '/login' &&
        err.requestOptions.path != '/renew') {
      final newAuthData =
          await _ref.read(authViewModelProvider.notifier).refreshToken();

      if (newAuthData != null) {
        final options = err.requestOptions;
        options.headers['Authorization'] = 'Bearer ${newAuthData.accessToken}';

        try {
          final response = await _ref.read(baseDioProvider).fetch(options);
          return handler.resolve(response);
        } on DioException catch (e) {
          return handler.next(e);
        }
      }
    }
    super.onError(err, handler);
  }
}
