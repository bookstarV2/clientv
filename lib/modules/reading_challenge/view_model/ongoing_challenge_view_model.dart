import 'package:bookstar/common/models/response_form.dart';
import 'package:bookstar/modules/reading_challenge/model/challenge_response.dart';
import 'package:bookstar/modules/reading_challenge/repository/reading_challenge_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ongoing_challenge_view_model.freezed.dart';
part 'ongoing_challenge_view_model.g.dart';

@freezed
abstract class OngoingChallengeScreenState with _$OngoingChallengeScreenState {
  const factory OngoingChallengeScreenState({
    @Default([]) List<ChallengeResponse> challenges,
    @Default(false) bool isSelectionMode,
    @Default({}) Set<int> selectedChallengeIds,
  }) = _OngoingChallengeScreenState;
}

@riverpod
class OngoingChallengeViewModel extends _$OngoingChallengeViewModel {
  late ReadingChallengeRepository _readingChallengeRepository;

  @override
  FutureOr<OngoingChallengeScreenState> build() async {
    _readingChallengeRepository = ref.read(readingChallengeRepositoryProvider);
    return await initState();
  }

  Future<OngoingChallengeScreenState> initState() async {
    final prev = state.value ?? OngoingChallengeScreenState();
    final response = await _readingChallengeRepository.getOngoingChallenges();
    state = AsyncValue.data(prev.copyWith(challenges: response.data));
    return state.value ?? OngoingChallengeScreenState();
  }

  void toggleSelectionMode() {
    final prev = state.value ?? OngoingChallengeScreenState();

    final newMode = !prev.isSelectionMode;
    state = AsyncValue.data(prev.copyWith(
      isSelectionMode: newMode,
      // 선택 모드 해제 시 선택 목록 초기화
      selectedChallengeIds: newMode ? prev.selectedChallengeIds : {},
    ));
  }

  void toggleChallengeSelection(int challengeId) {
    final prev = state.value ?? OngoingChallengeScreenState();
    final newSelection = Set<int>.from(prev.selectedChallengeIds);
    if (newSelection.contains(challengeId)) {
      newSelection.remove(challengeId);
    } else {
      newSelection.add(challengeId);
    }
    state = AsyncValue.data(prev.copyWith(selectedChallengeIds: newSelection));
  }

  Future<void> deleteSelectedChallenges() async {
    final prev = state.value ?? OngoingChallengeScreenState();
    final idsToDelete = List<int>.from(prev.selectedChallengeIds);

    for (var id in idsToDelete) {
      await _readingChallengeRepository.abandonChallenge(id);
    }

    state = AsyncValue.data(prev.copyWith(
      selectedChallengeIds: {},
      isSelectionMode: false,
    ));
    ref.invalidateSelf();
  }

  Future<void> abandonChallenge(int challengeId) async {
    await _readingChallengeRepository.abandonChallenge(challengeId);
  }

  Future<void> pollingUntilHasQuiz(int challengeId) async {
    pollStream<ResponseForm<List<ChallengeResponse>>>(
      fetcher: () => _readingChallengeRepository.getOngoingChallenges(),
      until: (response) => response.data.any((challenge) =>
          challenge.challengeId == challengeId && challenge.hasQuiz),
      onBreak: (response) {
        final prev = state.value ?? OngoingChallengeScreenState();
        state = AsyncValue.data(prev.copyWith(challenges: response.data));
      },
    ).listen((_) {});
  }

  // 3. Stream 기반 폴링
  Stream<T> pollStream<T>({
    required Future<T> Function() fetcher,
    required bool Function(T) until,
    required Function(T) onBreak,
    Duration interval = const Duration(seconds: 3),
  }) async* {
    while (true) {
      try {
        final data = await fetcher();
        yield data;

        if (until(data)) {
          onBreak(data);
          break;
        }
      } catch (e) {
        yield* Stream.error(e);
      }

      await Future.delayed(interval);
    }
  }

  Future<void> abandonChallenges(List<int> challengeIds) async {
    for (var id in challengeIds) {
      await _readingChallengeRepository.abandonChallenge(id);
    }
  }
}
