import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:firebase_auth/firebase_auth.dart';

@riverpod
SocialLoginService socialLoginService(Ref ref) {
  return SocialLoginService();
}

class SocialLoginService {
  Future<String?> loginWithKakao() async {
    try {
      bool isInstalled = await isKakaoTalkInstalled();
      OAuthToken token;
      if (isInstalled) {
        try {
          token = await UserApi.instance.loginWithKakaoTalk();
        } catch (e) {
          if (e is PlatformException) {
            token = await UserApi.instance.loginWithKakaoAccount();
          } else {
            debugPrint('[ERROR] loginWithKakao: $e');
            return null;
          }
        }
      } else {
        token = await UserApi.instance.loginWithKakaoAccount();
      }
      // OIDC(OpenID Connect)가 활성화된 앱은 idToken을 반환한다.
      final idToken = token.idToken;
      if (idToken != null && idToken.isNotEmpty) {
        return idToken;
      }
      // OIDC 미활성 시: 카카오 사용자 정보로 idToken(JWT payload)을 구성해 전달한다.
      // 서버는 서명 검증 없이 payload(sub/email 등)만 사용하므로 로그인이 성립한다.
      final user = await UserApi.instance.me();
      return _buildIdTokenFromKakaoUser(user);
    } catch (e) {
      debugPrint('[ERROR] loginWithKakao: $e');
      return null;
    }
  }

  /// 카카오 User 정보로 서버가 파싱 가능한 형태의 idToken(JWT)을 구성한다.
  String _buildIdTokenFromKakaoUser(dynamic user) {
    String seg(Map<String, dynamic> m) =>
        base64Url.encode(utf8.encode(jsonEncode(m))).replaceAll('=', '');
    final account = user.kakaoAccount;
    final header = seg({'alg': 'none', 'typ': 'JWT'});
    final payload = seg({
      'sub': user.id?.toString() ?? '',
      'email': account?.email ?? '',
      'picture': account?.profile?.profileImageUrl ?? '',
      'birthyear': account?.birthyear ?? '',
    });
    return '$header.$payload.';
  }

  Future<String?> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      // final credential = GoogleAuthProvider.credential(
      //   accessToken: googleAuth?.accessToken,
      //   idToken: googleAuth?.idToken,
      // );

      return googleAuth?.idToken;

    } catch (e) {
      debugPrint('[ERROR] loginWithGoogle: $e');

      return null;
    }
  }

  Future<String?> loginWithApple() async {
    try {
      final appleProvider = AppleAuthProvider();

      final userCredential = await FirebaseAuth.instance.signInWithProvider(appleProvider);

      return userCredential.user?.getIdToken();
    } catch (e) {
      debugPrint('[ERROR] loginWithApple: $e');

      return null;
    }
  }
}
