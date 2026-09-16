import 'package:bookstar/modules/auth/model/auth_response.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_view_model.dart';

sealed class AuthState {}

class AuthIdle extends AuthState {}

// Credentials are retained when the server is temporarily unreachable.
class AuthRestoreFailed extends AuthState {}

class AuthSuccess extends AuthState {
  final int memberId;
  final String nickName;
  final String profileImage;
  final String providerType;
  final String email;
  final MemberRole memberRole;

  AuthSuccess({
    required this.memberId,
    required this.nickName,
    required this.profileImage,
    required this.providerType,
    required this.email,
    required this.memberRole,
  });
}

class AuthFailed extends AuthState {
  final String errorMsg;
  final int errorCode;

  AuthFailed({
    required this.errorMsg,
    required this.errorCode,
  });
}

class AuthLoading extends AuthState {}

class AuthWithdrawCompleted extends AuthState {}

mixin class UserState {
  AuthState watchAuthState(WidgetRef ref) {
    final state = ref.watch(authViewModelProvider);

    return state.when(
      data: (data) => data,
      loading: () => AuthLoading(),
      error: (e, t) => AuthFailed(errorMsg: '', errorCode: -1),
    );
  }

  AuthSuccess? watchUser(WidgetRef ref) {
    final state = ref.read(authViewModelProvider);

    return state.when(
      data: (data) {
        if (data is AuthSuccess) return data;
        return null;
      },
      loading: () => null,
      error: (e, t) => null,
    );
  }
}
