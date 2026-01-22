import 'package:bookstar/modules/reading_challenge/model/challenge_success_detail_response.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:bookstar/modules/reading_challenge/repository/reading_challenge_repository.dart';

part 'challenge_complete_view_model.freezed.dart';
part 'challenge_complete_view_model.g.dart';

@freezed
abstract class ChallengeCompleteState with _$ChallengeCompleteState {
  const factory ChallengeCompleteState({
    @Default(ChallengeSuccessDetailResponse())
    ChallengeSuccessDetailResponse detail,
  }) = _ChallengeCompleteState;
}

@riverpod
class ChallengeCompleteViewModel extends _$ChallengeCompleteViewModel {
  late final ReadingChallengeRepository _readingChallengeRepository;

  @override
  FutureOr<ChallengeCompleteState> build(int challengeId) async {
    _readingChallengeRepository = ref.watch(readingChallengeRepositoryProvider);

    return await _initState(challengeId);
  }

  Future<ChallengeCompleteState> _initState(int challengeId) async {
    final prev = state.value ?? ChallengeCompleteState();
    final response = await _readingChallengeRepository
        .getChallengeSuccessDetail(challengeId);
    state = AsyncValue.data(prev.copyWith(detail: response.data));
    return state.value ?? ChallengeCompleteState();
  }
}
