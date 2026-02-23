import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../repository/reading_challenge_repository.dart';
import '../state/abandoned_challenges_state.dart';

part 'abandoned_challenges_view_model.g.dart';

@riverpod
class AbandonedChallengesViewModel extends _$AbandonedChallengesViewModel {
  late ReadingChallengeRepository _readingChallengeRepository;

  @override
  Future<AbandonedChallengesState> build() async {
    _readingChallengeRepository = ref.read(readingChallengeRepositoryProvider);
    return await initState();
  }

  Future<AbandonedChallengesState> initState() async {
    final prev = state.value ?? AbandonedChallengesState();
    final response = await _readingChallengeRepository.getAbandonedChallenges();
    final challenges = response.data;
    final checkedList = List.generate(challenges.length, (_) => false);

    state = AsyncValue.data(prev.copyWith(
      challenges: challenges,
      checkedList: checkedList,
      isLoading: false,
    ));
    return state.value ?? AbandonedChallengesState();
  }

  void toggleCheck(int index) {
    final current = state.value ?? AbandonedChallengesState();

    final newCheckedList = List<bool>.from(current.checkedList);
    newCheckedList[index] = !newCheckedList[index];
    state = AsyncValue.data(current.copyWith(checkedList: newCheckedList));
  }

  Future<void> restartSelectedChallenges() async {
    final current = state.value ?? AbandonedChallengesState();
    final selectedIndices = <int>[];

    for (int i = 0; i < current.checkedList.length; i++) {
      if (current.checkedList[i]) {
        selectedIndices.add(i);
      }
    }

    if (selectedIndices.isEmpty) return;

    for (final index in selectedIndices) {
      final challenge = current.challenges[index];
      await _readingChallengeRepository.restartChallenge(challenge.challengeId);
    }
    // 성공 후 상태 초기화
    await initState();
  }

  Future<void> deleteSelectedChallenges() async {
    final current = state.value ?? AbandonedChallengesState();

    final selectedIndices = <int>[];
    for (int i = 0; i < current.checkedList.length; i++) {
      if (current.checkedList[i]) {
        selectedIndices.add(i);
      }
    }

    if (selectedIndices.isEmpty) return;

    // 선택된 챌린지들을 삭제
    for (final index in selectedIndices) {
      final challenge = current.challenges[index];
      await _readingChallengeRepository.deleteChallenge(challenge.challengeId);
    }

    // 성공 후 상태 초기화
    await initState();
  }

  bool get hasSelectedItems => state.value?.checkedList.contains(true) ?? false;
}
