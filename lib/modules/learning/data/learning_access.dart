import 'package:bookstar/modules/auth/model/policy.dart';
import 'package:bookstar/modules/auth/repository/policy_repository.dart';
import 'package:bookstar/modules/auth/view_model/auth_state.dart';
import 'package:bookstar/modules/auth/view_model/auth_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final learningAccountProvider =
    Provider<int?>((ref) => ref.watch(authViewModelProvider.select((state) {
          final user = state.valueOrNull;
          return user is AuthSuccess ? user.memberId : null;
        })));

final learningPolicyProvider = FutureProvider<Policy?>((ref) async {
  final memberId = ref.watch(learningAccountProvider);
  if (memberId == null) return null;
  return (await ref.watch(policyRepositoryProvider).getPolicy()).data;
});

bool hasRequiredLearningPolicy(Policy? policy) =>
    policy?.serviceUsingAgree == PolicyAgree.Y &&
    policy?.personalInformationAgree == PolicyAgree.Y;

// Only local learning routes may be resumed after authentication.
String learningReturnPath(String? candidate) {
  final uri = Uri.tryParse(candidate ?? '');
  if (uri == null || uri.hasScheme || uri.hasAuthority) return '/quiz';
  final path = uri.path;
  if (path == '/quiz' ||
      path == '/library' ||
      path == '/review' ||
      path == '/settings' ||
      path == '/library/search' ||
      path == '/library/footprint' ||
      path == '/settings/archive' ||
      path == '/settings/notifications' ||
      RegExp(r'^/settings/archive/[1-9][0-9]*$').hasMatch(path) ||
      RegExp(r'^/library/[1-9][0-9]*/chapters$').hasMatch(path) ||
      RegExp(r'^/library/[1-9][0-9]*/quiz/[1-9][0-9]*$').hasMatch(path) ||
      RegExp(r'^/review/quiz/[1-9][0-9]*$').hasMatch(path)) {
    return path;
  }
  return '/quiz';
}

String learningEntryLocation(String route, String? next) =>
    Uri(path: route, queryParameters: {'next': learningReturnPath(next)})
        .toString();
