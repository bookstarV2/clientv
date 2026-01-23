import 'package:bookstar/common/models/response_form.dart';
import 'package:bookstar/infra/network/dio_client.dart';
import 'package:bookstar/modules/reading_challenge/model/challenge_creation_response.dart';
import 'package:bookstar/modules/reading_challenge/model/challenge_success_detail_response.dart';
import 'package:bookstar/modules/reading_challenge/model/completed_detail_response.dart';
import 'package:bookstar/modules/reading_challenge/model/ongoing_detail_response.dart';
import 'package:bookstar/modules/reading_challenge/model/post_progress_request.dart';
import 'package:bookstar/modules/reading_challenge/model/post_reading_timer_request.dart';
import 'package:bookstar/modules/reading_challenge/model/challenge_detail_chapter_detail_response.dart';
import 'package:bookstar/modules/reading_challenge/model/challenge_progress_request.dart';
import 'package:bookstar/modules/reading_challenge/model/challenge_progress_response.dart';
import 'package:bookstar/modules/reading_challenge/model/reading_challenge_request.dart';
import 'package:bookstar/modules/reading_challenge/model/report_quiz_error_request.dart';
import 'package:bookstar/modules/reading_challenge/model/submit_quiz_response.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/challenge_detail_response.dart';
import '../model/challenge_response.dart';
import '../model/book_rating_request.dart';
import 'package:bookstar/modules/reading_diary/model/diary_thumbnail_response.dart';
import 'package:bookstar/modules/reading_diary/model/diary_response.dart';
import 'package:bookstar/common/models/cursor_page_response.dart';
import 'package:bookstar/common/models/dual_cursor_page_response.dart';

part 'reading_challenge_repository.g.dart';

@Riverpod(keepAlive: true)
ReadingChallengeRepository readingChallengeRepository(Ref ref) {
  final dio = ref.watch(dioClientProvider);
  return ReadingChallengeRepository(dio);
}

@RestApi()
abstract class ReadingChallengeRepository {
  factory ReadingChallengeRepository(Dio dio, {String baseUrl}) =
      _ReadingChallengeRepository;

  @GET('/api/v3/challenges/ongoing')
  Future<ResponseForm<OngoingDetailResponse>> getOngoingChallenges();

  @GET('/api/v3/challenges/abandoned')
  Future<ResponseForm<List<ChallengeResponse>>> getAbandonedChallenges();

  @GET('/api/v3/challenges/completed')
  Future<ResponseForm<CompletedDetailResponse>> getCompletedChallenges();

  @DELETE('/api/v3/challenges/{challengeId}')
  Future<ResponseForm<dynamic>> deleteChallenge(
    @Path('challengeId') int challengeId,
  );

  @GET('/api/v3/challenges/{challengeId}')
  Future<ResponseForm<ChallengeDetailResponse>> getChallenge(
    @Path('challengeId') int challengeId,
  );

  @POST('/api/v3/chapters/quizzes')
  Future<ResponseForm<ChallengeDetailChapterDetailResponse>> getQuizzes(
    @Body() List<int> chapterIds,
  );

  @POST('/api/v3/quizzes/challenge-submit')
  Future<ResponseForm<SubmitQuizResponse>> submitQuiz(
    @Query('quizId') int quizId,
    @Query('choiceId') int choiceId,
    @Query('challengeId') int challengeId,
  );

  @POST('/api/v1/reading-timers')
  Future<ResponseForm<void>> postReadingTimers(
    @Body() PostReadingTimerRequest request,
  );

  @POST('/api/v3/challenges/{challengeId}/progress')
  Future<ResponseForm<void>> postProgress(
    @Path('challengeId') int challengeId,
    @Body() PostProgressRequest request,
  );

  @POST('/api/v3/challenges/{challengeId}/abandon')
  Future<ResponseForm<dynamic>> abandonChallenge(
    @Path('challengeId') int challengeId,
  );

  @POST('/api/v3/quizzes/{quizId}/error-report')
  Future<ResponseForm<dynamic>> reportQuizError(
    @Path('quizId') int quizId,
    @Body() ReportQuizErrorRequest request,
  );

  @GET('/api/v3/challenges/{challengeId}/success-detail')
  Future<ResponseForm<ChallengeSuccessDetailResponse>>
      getChallengeSuccessDetail(
    @Path('challengeId') int challengeId,
  );

  @POST('/api/v2/reading-challenges')
  Future<ResponseForm<ChallengeCreationResponse>> createChallenge(
    @Body() ReadingChallengeRequest request,
  );

  @POST('/api/v2/reading-challenges/{challengeId}/progress')
  Future<ResponseForm<ChallengeProgressResponse>> updateChallengeProgress(
    @Path('challengeId') int challengeId,
    @Body() ChallengeProgressRequest request,
  );

  @GET('/api/v2/reading-challenges/members/{memberId}')
  Future<ResponseForm<List<ChallengeResponse>>> getChallengesByMember(
    @Path('memberId') int memberId,
  );

  @POST('/api/v2/books/{bookId}/ratings')
  Future<ResponseForm<dynamic>> createBookRating(
    @Path('bookId') String bookId,
    @Body() BookRatingRequest request,
  );

  @DELETE('/api/v2/books/{bookId}/ratings')
  Future<ResponseForm<dynamic>> deleteBookRating(
    @Path('bookId') String bookId,
  );

  @POST('/api/v2/reading-challenges/{challengeId}/restart')
  Future<ResponseForm<ChallengeResponse>> restartChallenge(
    @Path('challengeId') int challengeId,
  );

  @GET('/api/v2/reading-challenges/books/{bookId}')
  Future<ResponseForm<ChallengeDetailResponse>> getChallengeByBookId(
    @Path('bookId') String bookId,
  );

  @GET('/api/v2/reading-challenges/exists/books/{bookId}')
  Future<ResponseForm<bool>> checkChallengeExists(
    @Path('bookId') String bookId,
  );

  @GET('/reading-diaries/members/{memberId}/thumbnail')
  Future<ResponseForm<CursorPageResponse<DiaryThumbnail>>> getMemberDiaries(
    @Path('memberId') int memberId, {
    @Query('cursorId') int? cursorId,
    @Query('size') int? size,
  });

  /// 특정 사용자가 작성한 독서일기 피드 목록을 최신순으로 조회합니다.
  @GET('/reading-diaries/members/{memberId}/feed')
  Future<ResponseForm<CursorPageResponse<DiaryResponse>>>
      getLatestDiariesFeedByMember(
    @Path('memberId') int memberId, {
    @Query('cursor') int? cursor, // 서버 명세에 따라 파라미터 이름이 다를 수 있음
    @Query('size') int? size,
  });

  /// 특정 챌린지의 독서일기 썸네일 목록을 최신순으로 조회합니다.
  @GET('/challenges/{challengeId}/reading-diaries/thumbnail')
  Future<ResponseForm<CursorPageResponse<DiaryThumbnail>>>
      getLatestDiaryThumbnailsByChallenge(
    @Path('challengeId') int challengeId, {
    @Query('cursorId') int? cursorId,
    @Query('size') int? size,
  });

  /// 특정 챌린지의 독서일기 썸네일 목록을 인기순(Redis 기반)으로 조회합니다.
  @GET('/challenges/{challengeId}/reading-diaries/thumbnail/popular')
  Future<ResponseForm<DualCursorPageResponse<DiaryThumbnail>>>
      getPopularDiaryThumbnailsByChallenge(
    @Path('challengeId') int challengeId, {
    @Query('page') int? page,
    @Query('size') int? size,
  });

  /// 특정 챌린지의 독서일기 피드 목록을 최신순으로 조회합니다.
  @GET('/challenges/{challengeId}/reading-diaries/feed')
  Future<ResponseForm<CursorPageResponse<DiaryResponse>>>
      getLatestDiaryFeedsByChallenge(
    @Path('challengeId') int challengeId, {
    @Query('cursorId') int? cursorId,
    @Query('size') int? size,
  });

  /// 특정 챌린지의 독서일기 피드 목록을 인기순(Redis 기반)으로 조회합니다.
  @GET('/challenges/{challengeId}/reading-diaries/feed/popular')
  Future<ResponseForm<DualCursorPageResponse<DiaryResponse>>>
      getPopularDiaryFeedsByChallenge(
    @Path('challengeId') int challengeId, {
    @Query('page') int? page,
    @Query('size') int? size,
  });
}
