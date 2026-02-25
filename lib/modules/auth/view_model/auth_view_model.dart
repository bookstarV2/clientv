import 'dart:async';
import 'dart:developer' as dev; // 추가
import 'package:flutter/foundation.dart'; // kDebugMode용 추가

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
    } catch (e, t) {
      state = AsyncError(e, t);
    }

    return state.value ?? AuthIdle();
  }

  Future<void> login(ProviderType providerType) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final String? idToken = await _getIdToken(providerType);

      if (idToken == null) {
        return AuthFailed(errorMsg: '', errorCode: -1);
      }
      final request =
          LoginRequest(providerType: providerType, idToken: idToken);
      final response = await _authRepository.login(request);
      final authData = response.data;

      if (kDebugMode) {
        dev.log('=== AUTH: Login Response Data ===', name: 'AUTH');
        dev.log('memberId: ${authData.memberId}', name: 'AUTH');
        dev.log('nickName: ${authData.nickName}', name: 'AUTH');
        dev.log('providerType: ${authData.providerType}', name: 'AUTH');
        dev.log('email: ${authData.email}', name: 'AUTH');
        dev.log('accessToken: ${authData.accessToken.substring(0, 10)}...', name: 'AUTH');
        dev.log('memberRole: ${authData.memberRole}', name: 'AUTH');
      }

      await _secureStorageRepository.saveTokens(
        accessToken: authData.accessToken,
        refreshToken: authData.refreshToken,
      );

      return AuthSuccess(
          memberId: authData.memberId,
          nickName: authData.nickName,
          profileImage: authData.profileImage,
          providerType: authData.providerType,
          email: authData.email,
          memberRole: authData.memberRole,
        );
    });
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

  Future<void> signOut() async {
    await _secureStorageRepository.deleteTokens();
    state = AsyncData(AuthIdle());
  }

  Future<void> withdraw() async {
    try {
      await _authRepository.withdraw();
      await _secureStorageRepository.deleteTokens();
      state = AsyncData(AuthWithdrawCompleted());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> forceSignOut() async {
    if (kDebugMode) {
      dev.log('=== FORCE SIGNOUT: Clearing all tokens ===', name: 'AUTH');
    }
    await _secureStorageRepository.deleteTokens();
    state = AsyncData(AuthIdle());
  }

  Future<({String? accessToken, String? refreshToken})> getTokens() async {
    final accessToken = await _secureStorageRepository.getAccessToken();
    final refreshToken = await _secureStorageRepository.getRefreshToken();

    return (accessToken: accessToken, refreshToken: refreshToken);
  }

  Future<AuthResponse?> refreshToken() async {
    final oldRefreshToken = await _secureStorageRepository.getRefreshToken();
    if (oldRefreshToken == null) {
      await signOut();

      return null;
    }

    try {
      final authDataResponse =
          await _authRepository.renewToken('Bearer $oldRefreshToken');
      final authData = authDataResponse.data;

      if (authData == null) {
        await signOut();

        return null;
      }

      if (kDebugMode) {
        dev.log('=== AUTH: Refresh Token Response Data ===', name: 'AUTH');
        dev.log('memberId: ${authData.memberId}', name: 'AUTH');
        dev.log('nickName: ${authData.nickName}', name: 'AUTH');
        dev.log('providerType: ${authData.providerType}', name: 'AUTH');
        dev.log('email: ${authData.email}', name: 'AUTH');
        dev.log('New AccessToken: ${authData.accessToken.substring(0, 10)}...', name: 'AUTH');
        dev.log('memberRole: ${authData.memberRole}', name: 'AUTH');
      }

      await _secureStorageRepository.saveTokens(
        accessToken: authData.accessToken,
        refreshToken: authData.refreshToken,
      );

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
    } catch (e, _) {
      await signOut();

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
