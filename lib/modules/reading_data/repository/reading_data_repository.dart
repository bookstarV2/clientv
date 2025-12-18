import 'package:bookstar/common/models/response_form.dart';
import 'package:bookstar/infra/network/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/ranking_weekly_response.dart';

part 'reading_data_repository.g.dart';

@Riverpod(keepAlive: true)
ReadingDataRepository readingDataRepository(Ref ref) {
  final dio = ref.watch(dioClientProvider);
  return ReadingDataRepository(dio);
}

@RestApi()
abstract class ReadingDataRepository {
  factory ReadingDataRepository(Dio dio, {String baseUrl}) =
      _ReadingDataRepository;

  @GET('/api/v1/ranking/weekly/top3')
  Future<ResponseForm<List<RankingWeeklyResponse>>> getRankingWeeklyTop3();

  @GET('/api/v1/ranking/weekly')
  Future<ResponseForm<List<RankingWeeklyResponse>>> getRankingWeekly();

  @GET('/api/v1/ranking/weekly/my')
  Future<ResponseForm<RankingWeeklyResponse>> getRankingWeeklyMy();
}
