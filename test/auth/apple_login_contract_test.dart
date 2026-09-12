import 'package:bookstar/modules/auth/repository/social_login_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel =
      MethodChannel('com.aboutyou.dart_packages.sign_in_with_apple');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test(
      'returns Apple identity token, without requiring Firebase authentication',
      () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'performAuthorizationRequest');
      return {
        'type': 'appleid',
        'authorizationCode': 'single-use-test-code',
        'identityToken': 'apple-signed-test-identity-token',
        'userIdentifier': 'test-apple-user',
      };
    });
    expect(await SocialLoginService().loginWithApple(),
        'apple-signed-test-identity-token');
  });

  test('does not manufacture a token if Apple returns none', () async {
    messenger.setMockMethodCallHandler(
        channel,
        (_) async => {
              'type': 'appleid',
              'authorizationCode': 'single-use-test-code',
            });
    expect(await SocialLoginService().loginWithApple(), isNull);
  });

  test('does not authenticate when authorization is cancelled', () async {
    messenger.setMockMethodCallHandler(channel, (_) async {
      throw PlatformException(code: 'AuthorizationErrorCode.canceled');
    });
    expect(await SocialLoginService().loginWithApple(), isNull);
  });
}
