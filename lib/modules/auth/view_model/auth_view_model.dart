import 'dart:async';
import 'dart:developer' as dev; // 추가
import 'package:flutter/foundation.dart'; // kDebugMode용 추가
import 'package:dio/dio.dart';

import 'package:bookstar/modules/auth/model/policy.dart';
import 'package:bookstar/modules/auth/repository/policy_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../infra/storage/secure_storage.dart';
import '../model/auth_response.dart';
import '../model/login_request.dart';
import '../repository/auth_repository.dart';
import '../repository/social_login_service.dart';
import 'auth_state.dart';

part 'auth_view_model.g.dart';

@Riverpod(keepAlive: true)
class AuthViewModel extends _$AuthViewModel {
  Future<AuthResponse?>? _refreshInFlight;
  Future<void>? _endingSession;
  Future<void> _tokenWrites = Future<void>.value();
  bool _loggingIn = false;
  int _sessionVersion = 0;
  int get sessionVersion => _sessionVersion;
  late final AuthRepository _authRepository = ref.read(authRepositoryProvider);
  late final SocialLoginService _socialLoginService = SocialLoginService();
  late final SecureStorageRepository _secureStorageRepository =
      ref.read(secureStorageRepositoryProvider);
  late final PolicyRepository _policyRepository =
      ref.read(policyRepositoryProvider);

  @override
  Future<AuthState> build() async {
    state = const AsyncLoading();

    try {
      await refreshToken();
    } catch (_) {
      state = AsyncData(AuthRestoreFailed());
    }

    return state.value ?? AuthIdle();
  }

  Future<void> login(ProviderType providerType) async {
    if (_loggingIn) return;
    await _endingSession;
    if (_loggingIn) return;
    final version = ++_sessionVersion;
    _loggingIn = true;
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() async {
      final String? idToken = await _getIdToken(providerType);

      if (idToken == null) {
        return AuthFailed(errorMsg: '', errorCode: -1);
      }
      final request =
          LoginRequest(providerType: providerType, idToken: idToken);
      final response = await _authRepository.login(request);
      final authData = response.data;
      if (version != _sessionVersion) return AuthIdle();

      if (kDebugMode) {
        dev.log('=== AUTH: Login Response Data ===', name: 'AUTH');
        dev.log('providerType: ${authData.providerType}', name: 'AUTH');
      }

      await _persistTokens(authData, version);

      return AuthSuccess(
        memberId: authData.memberId,
        nickName: authData.nickName,
        profileImage: authData.profileImage,
        providerType: authData.providerType,
        email: authData.email,
        memberRole: authData.memberRole,
      );
    });
    if (version == _sessionVersion) {
      state = result;
    }
    _loggingIn = false;
  }

  Future<String?> _getIdToken(ProviderType providerType) {
    switch (providerType) {
      case ProviderType.kakao:
        return _socialLoginService.loginWithKakao();
      case ProviderType.google:
        return _socialLoginService.loginWithGoogle();
      case ProviderType.apple:
        return _socialLoginService.loginWithApple();
    }
  }

  Future<void> signOut() {
    return _endingSession ??= _endSession().whenComplete(() {
      _endingSession = null;
    });
  }

  Future<void> _endSession() async {
    _sessionVersion++;
    await _refreshInFlight;
    await _tokenWrites.catchError((_) {});
    await _secureStorageRepository.deleteTokens();
    state = AsyncData(AuthIdle());
  }

  Future<void> withdraw() async {
    try {
      await _authRepository.withdraw();
      await signOut();
      state = AsyncData(AuthWithdrawCompleted());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> forceSignOut() async {
    if (kDebugMode) {
      dev.log('=== FORCE SIGNOUT: Clearing all tokens ===', name: 'AUTH');
    }
    await signOut();
  }

  Future<({String? accessToken, String? refreshToken})> getTokens() async {
    final accessToken = await _secureStorageRepository.getAccessToken();
    final refreshToken = await _secureStorageRepository.getRefreshToken();

    return (accessToken: accessToken, refreshToken: refreshToken);
  }

  Future<AuthResponse?> refreshToken() {
    if (_endingSession != null || _loggingIn) return Future.value(null);
    return _refreshInFlight ??=
        _restoreSession(_sessionVersion).whenComplete(() {
      _refreshInFlight = null;
    });
  }

  Future<void> _persistTokens(AuthResponse data, int version) {
    return _tokenWrites = _tokenWrites.catchError((_) {}).then((_) async {
      if (version != _sessionVersion) return;
      await _secureStorageRepository.saveTokens(
          accessToken: data.accessToken, refreshToken: data.refreshToken);
    });
  }

  Future<void> retryStoredSession() async {
    state = const AsyncLoading();
    try {
      await refreshToken();
    } catch (_) {
      state = AsyncData(AuthRestoreFailed());
    }
  }

  bool _isRejectedSession(DioException error) {
    final status = error.response?.statusCode;
    final data = error.response?.data;
    final response = data is Map ? data['statusResponse'] : null;
    final code = response is Map ? response['resultCode'] : null;
    return status == 401 ||
        status == 403 ||
        const ['B302', 'B303', 'M001'].contains(code);
  }

  Future<AuthResponse?> _restoreSession(int version) async {
    try {
      final oldRefreshToken = await _secureStorageRepository.getRefreshToken();
      if (version != _sessionVersion) return null;
      if (oldRefreshToken == null) {
        state = AsyncData(AuthIdle());
        return null;
      }
      final authDataResponse =
          await _authRepository.renewToken('Bearer $oldRefreshToken');
      final authData = authDataResponse.data;
      if (version != _sessionVersion) return null;

      if (authData == null) {
        await _secureStorageRepository.deleteTokens();
        state = AsyncData(AuthIdle());

        return null;
      }

      if (kDebugMode) {
        dev.log('=== AUTH: Refresh Token Response Data ===', name: 'AUTH');
        dev.log('providerType: ${authData.providerType}', name: 'AUTH');
      }

      await _persistTokens(authData, version);
      if (version != _sessionVersion) return null;

      // Handle cases where server might not return email and providerType yet
      final email = authData.email.isNotEmpty ? authData.email : '이메일 정보 없음';
      final providerType =
          authData.providerType.isNotEmpty ? authData.providerType : '연동 상태';

      state = AsyncData(
        AuthSuccess(
          memberId: authData.memberId,
          nickName: authData.nickName,
          profileImage: authData.profileImage,
          providerType: providerType,
          email: email,
          memberRole: authData.memberRole,
        ),
      );

      return authData;
    } catch (error) {
      if (version != _sessionVersion) return null;
      if (error is DioException && _isRejectedSession(error)) {
        await _secureStorageRepository.deleteTokens();
        state = AsyncData(AuthIdle());
      } else {
        state = AsyncData(AuthRestoreFailed());
      }
      return null;
    }
  }

  AuthSuccess? getUser() {
    return state.when(
      data: (data) {
        if (data is AuthSuccess) return data;
        return null;
      },
      loading: () => null,
      error: (e, t) => null,
    );
  }

  Future<Policy> getPolicy() async {
    final policyResponse = await _policyRepository.getPolicy();
    return policyResponse.data;
  }

  Future<void> setPolicy(Policy policy) async {
    await _policyRepository.updatePolicy(policy);
  }
}
