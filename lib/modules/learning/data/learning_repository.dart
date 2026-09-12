import 'dart:math';

import 'package:bookstar/infra/network/dio_client.dart';
import 'package:bookstar/modules/reading_challenge/model/challenge_detail_chapter_detail.dart';
import 'package:bookstar/modules/reading_challenge/model/challenge_detail_response.dart';
import 'package:bookstar/modules/reading_challenge/model/choice_result.dart';
import 'package:bookstar/modules/reading_challenge/model/challenge_response.dart';
import 'package:bookstar/modules/reading_challenge/repository/reading_challenge_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'learning_access.dart';
import 'learning_footprint.dart';

final learningRepositoryProvider = Provider<LearningRepository>(
  (ref) {
    ref.watch(learningAccountProvider);
    return LearningRepository(ref.watch(dioClientProvider));
  },
);

final learningBooksProvider =
    FutureProvider<List<ChallengeResponse>>((ref) async {
  if (ref.watch(learningAccountProvider) == null) return [];
  final response = await ref
      .watch(readingChallengeRepositoryProvider)
      .getOngoingChallenges();
  return response.data.challenges;
});

final finishedLearningBooksProvider =
    FutureProvider<List<ChallengeResponse>>((ref) async {
  if (ref.watch(learningAccountProvider) == null) return [];
  final response = await ref
      .watch(readingChallengeRepositoryProvider)
      .getCompletedChallenges();
  return response.data.challenges;
});

final reviewOverviewProvider = FutureProvider<ReviewPage>(
  (ref) => ref.watch(learningRepositoryProvider).getReviews(dueOnly: true),
);

class LearningRepository {
  LearningRepository(this._dio);
  final Dio _dio;

  Future<LearningFootprint> getFootprint() async {
    final response =
        await _dio.get<Map<String, dynamic>>('/api/v3/learning/me/footprint');
    return LearningFootprint.fromJson(
        response.data!['data'] as Map<String, dynamic>);
  }

  Future<FootprintBookPage> getFootprintBooks(
      {int? cursor, List<int>? bookIds}) async {
    final response = await _dio.get<Map<String, dynamic>>(
        '/api/v3/learning/me/footprint/books',
        queryParameters: {
          'size': 30,
          if (cursor != null) 'cursor': cursor,
          if (bookIds != null) 'bookIds': bookIds
        },
        options: Options(listFormat: ListFormat.multi));
    return FootprintBookPage.fromJson(
        response.data!['data'] as Map<String, dynamic>);
  }

  Future<ChallengeDetailResponse> getChapters(int challengeId) async {
    final response = await _dio.get<Map<String, dynamic>>(
        '/api/v3/learning/challenges/$challengeId/chapters');
    return ChallengeDetailResponse.fromJson(
        response.data!['data'] as Map<String, dynamic>);
  }

  Future<ChallengeDetailChapterDetail> getQuiz(int chapterId) async {
    final response = await _dio
        .get<Map<String, dynamic>>('/api/v3/learning/chapters/$chapterId/quiz');
    final data = response.data!['data'] as Map<String, dynamic>;
    final chapters = data['chapters'] as List<dynamic>;
    if (chapters.isEmpty) throw StateError('Quiz not available');
    return ChallengeDetailChapterDetail.fromJson(
        chapters.first as Map<String, dynamic>);
  }

  Future<LearningQuizResult> submitFirstAnswer(
      int quizId, int choiceId, int challengeId) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v3/learning/quizzes/$quizId/submit',
      data: {'choiceId': choiceId, 'challengeId': challengeId},
    );
    return LearningQuizResult.fromJson(
        response.data!['data'] as Map<String, dynamic>);
  }

  Future<LearningBookPage> searchBooks(String query, {int? cursor}) async {
    final response = await _dio
        .get<Map<String, dynamic>>('/api/v3/learning/books', queryParameters: {
      'query': query,
      'size': 20,
      if (cursor != null) 'cursor': cursor
    });
    return LearningBookPage.fromJson(
        response.data!['data'] as Map<String, dynamic>);
  }

  Future<ReviewPage> getReviews({int? cursor, bool dueOnly = false}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v3/quiz-reviews',
      queryParameters: {
        'size': 30,
        'dueOnly': dueOnly,
        if (cursor != null) 'cursor': cursor
      },
    );
    return ReviewPage.fromJson(response.data!['data'] as Map<String, dynamic>);
  }

  Future<LearningQuizResult> submitReview(
      int quizId, int choiceId, String requestId) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v3/quiz-reviews/$quizId',
      data: {'choiceId': choiceId, 'requestId': requestId},
    );
    return LearningQuizResult.fromJson(
        response.data!['data'] as Map<String, dynamic>);
  }

  Future<bool> hasAnswered(int quizId) async {
    final response = await _dio
        .get<Map<String, dynamic>>('/api/v3/quiz-reviews/$quizId/status');
    return (response.data!['data'] as Map<String, dynamic>)['answered'] == true;
  }

  static String newRequestId() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((e) => e.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }
}

class LearningBookPage {
  const LearningBookPage(this.items, this.hasNext, this.nextCursor);
  final List<LearningBook> items;
  final bool hasNext;
  final int? nextCursor;

  factory LearningBookPage.fromJson(Map<String, dynamic> json) =>
      LearningBookPage(
        (json['items'] as List<dynamic>)
            .map((e) => LearningBook.fromJson(e as Map<String, dynamic>))
            .toList(),
        json['hasNext'] == true,
        (json['nextCursor'] as num?)?.toInt(),
      );
}

class LearningBook {
  const LearningBook(
      this.bookId, this.title, this.author, this.bookCover, this.chapterCount);
  final int bookId;
  final String title;
  final String author;
  final String bookCover;
  final int chapterCount;

  factory LearningBook.fromJson(Map<String, dynamic> json) => LearningBook(
        (json['bookId'] as num).toInt(),
        json['title'] as String,
        json['author'] as String? ?? '',
        json['bookCover'] as String? ?? '',
        (json['chapterCount'] as num).toInt(),
      );
}

class ReviewPage {
  const ReviewPage({
    required this.items,
    required this.totalCount,
    required this.dueCount,
    required this.reviewedTodayCount,
    required this.hasNext,
    this.unavailableCount = 0,
    this.nextCursor,
  });

  final List<ReviewItem> items;
  final int totalCount;
  final int dueCount;
  final int reviewedTodayCount;
  final int unavailableCount;
  final bool hasNext;
  final int? nextCursor;

  factory ReviewPage.fromJson(Map<String, dynamic> json) => ReviewPage(
        items: (json['items'] as List<dynamic>)
            .map((e) => ReviewItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        totalCount: (json['totalCount'] as num).toInt(),
        dueCount: (json['dueCount'] as num).toInt(),
        reviewedTodayCount: (json['reviewedTodayCount'] as num).toInt(),
        unavailableCount: (json['unavailableCount'] as num?)?.toInt() ?? 0,
        hasNext: json['hasNext'] == true,
        nextCursor: (json['nextCursor'] as num?)?.toInt(),
      );
}

class ReviewItem {
  const ReviewItem({
    this.bookId,
    required this.quizId,
    required this.chapterId,
    required this.chapterTitle,
    required this.bookTitle,
    required this.bookCover,
    required this.question,
    required this.reviewCount,
    required this.due,
    required this.nextReviewAt,
  });

  final int quizId;
  final int? bookId;
  final int chapterId;
  final String chapterTitle;
  final String bookTitle;
  final String bookCover;
  final String question;
  final int reviewCount;
  final bool due;
  final DateTime nextReviewAt;

  factory ReviewItem.fromJson(Map<String, dynamic> json) => ReviewItem(
        bookId: (json['bookId'] as num?)?.toInt(),
        quizId: (json['quizId'] as num).toInt(),
        chapterId: (json['chapterId'] as num).toInt(),
        chapterTitle: json['chapterTitle'] as String,
        bookTitle: json['bookTitle'] as String,
        bookCover: json['bookCover'] as String? ?? '',
        question: json['question'] as String,
        reviewCount: (json['reviewCount'] as num).toInt(),
        due: json['due'] == true,
        nextReviewAt: DateTime.parse(json['nextReviewAt'] as String),
      );
}

class LearningQuizResult {
  const LearningQuizResult({
    required this.isCorrect,
    required this.choiceResults,
    this.nextReviewAt,
    this.reviewCount = 0,
  });

  final bool isCorrect;
  final List<ChoiceResult> choiceResults;
  final DateTime? nextReviewAt;
  final int reviewCount;

  factory LearningQuizResult.fromJson(Map<String, dynamic> json) =>
      LearningQuizResult(
        isCorrect: json['isCorrect'] == true,
        choiceResults: (json['choiceResults'] as List<dynamic>)
            .map((e) => ChoiceResult.fromJson(e as Map<String, dynamic>))
            .toList(),
        nextReviewAt: json['nextReviewAt'] == null
            ? null
            : DateTime.parse(json['nextReviewAt'] as String),
        reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      );
}

class LearningQuizData {
  const LearningQuizData(this.chapter, this.isReview);
  final ChallengeDetailChapterDetail chapter;
  final bool isReview;
}

String learningErrorMessage(Object error,
    {bool answerIsRetained = false, bool quizContext = false}) {
  if (error is DioException) {
    if (error.response?.statusCode == 401) return '로그인이 만료됐어요. 다시 로그인해 주세요.';
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return answerIsRetained
          ? '연결이 원활하지 않아요. 선택한 답은 그대로 있으니 다시 시도해 주세요.'
          : '연결이 원활하지 않아요. 잠시 후 다시 시도해 주세요.';
    }
    if (error.response?.statusCode == 404) {
      return quizContext
          ? '아직 준비되지 않은 퀴즈예요. 다른 목차를 선택해 주세요.'
          : '요청한 정보를 찾을 수 없어요. 화면을 다시 열어 확인해 주세요.';
    }
    if (error.response?.statusCode == 422) {
      return '이 문항은 확인이 필요해 잠시 제공하지 않아요. 다른 목차를 선택해 주세요.';
    }
    if (error.response?.statusCode == 409) {
      return quizContext
          ? '이미 저장된 답이 있어요. 목차로 돌아가 다시 열어 주세요.'
          : '이미 저장된 요청과 내용이 달라요. 화면을 다시 열어 확인해 주세요.';
    }
    if (error.response?.statusCode == 429) {
      return '요청이 잠시 많아졌어요. 조금 기다린 뒤 다시 시도해 주세요.';
    }
    if (error.type == DioExceptionType.cancel) {
      return '요청이 취소됐어요. 현재 계정에서 화면을 다시 열어 주세요.';
    }
  }
  return '요청을 완료하지 못했어요. 잠시 후 다시 시도해 주세요.';
}
