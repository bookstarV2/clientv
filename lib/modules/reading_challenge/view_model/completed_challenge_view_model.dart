import 'package:bookstar/modules/reading_challenge/model/challenge_response.dart';
import 'package:bookstar/modules/reading_challenge/repository/reading_challenge_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'completed_challenge_view_model.freezed.dart';
part 'completed_challenge_view_model.g.dart';

@freezed
abstract class CompletedChallengeScreenState
    with _$CompletedChallengeScreenState {
  const factory CompletedChallengeScreenState({
    @Default([]) List<ChallengeResponse> challenges,
    @Default(-1) int completedCount,
    @Default(false) bool isSelectionMode,
    @Default({}) Set<int> selectedChallengeIds,
  }) = _CompletedChallengeScreenState;
}

@riverpod
class CompletedChallengeViewModel extends _$CompletedChallengeViewModel {
  late ReadingChallengeRepository _readingChallengeRepository;

  @override
  FutureOr<CompletedChallengeScreenState> build() async {
    _readingChallengeRepository = ref.read(readingChallengeRepositoryProvider);
    return await initState();
  }

  Future<CompletedChallengeScreenState> initState() async {
    final prev = state.value ?? CompletedChallengeScreenState();
    final response = await _readingChallengeRepository.getCompletedChallenges();
    state = AsyncValue.data(prev.copyWith(
        challenges: response.data.challenges,
        completedCount: response.data.completedCount));
    return state.value ?? CompletedChallengeScreenState();
  }
}
