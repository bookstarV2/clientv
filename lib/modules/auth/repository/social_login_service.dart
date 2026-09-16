import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

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
      // 서버는 카카오가 서명한 OIDC 토큰만 인증한다.
      debugPrint('Kakao login requires OpenID Connect configuration.');
      return null;
    } catch (e) {
      debugPrint('[ERROR] loginWithKakao: $e');
      return null;
    }
  }

  Future<String?> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

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
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email],
      );
      return credential.identityToken;
    } catch (e) {
      debugPrint('[ERROR] loginWithApple: $e');

      return null;
    }
  }
}
