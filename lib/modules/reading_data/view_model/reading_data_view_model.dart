import 'package:bookstar/modules/reading_data/model/ranking_weekly_response.dart';
import 'package:bookstar/modules/reading_data/repository/reading_data_repository.dart';
import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reading_data_view_model.freezed.dart';
part 'reading_data_view_model.g.dart';

@freezed
abstract class ReadingDataState with _$ReadingDataState {
  const factory ReadingDataState({
    @Default(null) RankingWeeklyResponse? top1,
    @Default(null) RankingWeeklyResponse? top2,
    @Default(null) RankingWeeklyResponse? top3,
    @Default([]) List<RankingWeeklyResponse> list,
    @Default(RankingWeeklyResponse()) RankingWeeklyResponse my,
  }) = _ReadingDataState;
}

@riverpod
class ReadingDataViewModel extends _$ReadingDataViewModel {
  late final ReadingDataRepository _readingDataRepository;

  @override
  FutureOr<ReadingDataState> build() async {
    _readingDataRepository = ref.watch(readingDataRepositoryProvider);

    return await initState();
  }

  Future<ReadingDataState> initState() async {
    final prev = state.value ?? ReadingDataState();
    final top3Response = await _readingDataRepository.getRankingWeeklyTop3();
    final top1 = top3Response.data.firstWhereOrNull((e) => e.rank == 1);
    final top2 = top3Response.data.firstWhereOrNull((e) => e.rank == 2);
    final top3 = top3Response.data.firstWhereOrNull((e) => e.rank == 3);

    final weeklyResponse = await _readingDataRepository.getRankingWeekly();
    final list = weeklyResponse.data;

    final myResponse = await _readingDataRepository.getRankingWeeklyMy();
    final my = myResponse.data;

    state = AsyncValue.data(
        prev.copyWith(top1: top1, top2: top2, top3: top3, list: list, my: my));
    return state.value ?? ReadingDataState();
  }
}
