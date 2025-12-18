import 'package:bookstar/modules/reading_data/model/ranking_weekly_top3_response.dart';
import 'package:bookstar/modules/reading_data/repository/reading_data_repository.dart';
import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reading_data_view_model.freezed.dart';
part 'reading_data_view_model.g.dart';

@freezed
abstract class ReadingDataState with _$ReadingDataState {
  const factory ReadingDataState({
    @Default(null) RankingWeeklyTop3Response? top1,
    @Default(null) RankingWeeklyTop3Response? top2,
    @Default(null) RankingWeeklyTop3Response? top3,
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
    final response = await _readingDataRepository.getRankingWeeklyTop3();
    final top1 = response.data.firstWhereOrNull((e) => e.rank == 1);
    final top2 = response.data.firstWhereOrNull((e) => e.rank == 2);
    final top3 = response.data.firstWhereOrNull((e) => e.rank == 3);
    state = AsyncValue.data(prev.copyWith(top1: top1, top2: top2, top3: top3));
    return state.value ?? ReadingDataState();
  }
}
