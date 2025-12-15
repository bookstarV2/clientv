import 'package:bookstar/modules/reading_challenge/model/challenge_detail_response.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:bookstar/modules/reading_challenge/repository/reading_challenge_repository.dart';

part 'challenge_start_view_model.freezed.dart';
part 'challenge_start_view_model.g.dart';

@freezed
abstract class ChallengeStartState with _$ChallengeStartState {
  const factory ChallengeStartState({
    @Default(ChallengeDetailResponse()) ChallengeDetailResponse detail,
  }) = _ChallengeStartState;
}

@riverpod
class ChallengeStartViewModel extends _$ChallengeStartViewModel {
  late final ReadingChallengeRepository _readingChallengeRepository;

  @override
  FutureOr<ChallengeStartState> build(int challengeId) async {
    _readingChallengeRepository = ref.watch(readingChallengeRepositoryProvider);

    return await initState(challengeId);
  }

  Future<ChallengeStartState> initState(int challengeId) async {
    final prev = state.value ?? ChallengeStartState();
    final detail = await _readingChallengeRepository.getChallenge(challengeId);
    state = AsyncValue.data(prev.copyWith(detail: detail.data));
    return state.value ?? ChallengeStartState();
  }
}
