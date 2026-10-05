import 'package:bookstar/infra/network/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'learning_access.dart';

final readingMapRemoteProvider = Provider<ReadingMapRemote>(
  (ref) => ReadingMapRemote(ref.watch(dioClientProvider)),
);

final readingMapStateProvider =
    FutureProvider.autoDispose<ReadingMapState>((ref) {
  if (ref.watch(learningAccountProvider) == null) {
    throw StateError('Sign in required');
  }
  return ref.watch(readingMapRemoteProvider).get();
});

class ReadingMapRemote {
  const ReadingMapRemote(this._dio);
  final Dio _dio;

  Future<ReadingMapState> get() async {
    final response =
        await _dio.get<Map<String, dynamic>>('/api/v3/learning/me/reading-map');
    return ReadingMapState.fromJson(
        response.data!['data'] as Map<String, dynamic>);
  }

  Future<ReadingMapJobResult> request(String requestId, String mode) async {
    final response = await _dio.post<Map<String, dynamic>>(
        '/api/v3/learning/me/reading-map/jobs',
        data: {'requestId': requestId, 'mode': mode});
    return ReadingMapJobResult.fromJson(
        response.data!['data'] as Map<String, dynamic>);
  }
}

class ReadingMapState {
  const ReadingMapState({
    required this.balance,
    required this.createCost,
    required this.refreshCost,
    required this.answeredQuizCount,
    required this.analyzedQuizCount,
    required this.hasNewQuizzes,
    required this.status,
    required this.jobId,
    required this.version,
    required this.links,
  });

  final int balance;
  final int createCost;
  final int refreshCost;
  final int answeredQuizCount;
  final int analyzedQuizCount;
  final bool hasNewQuizzes;
  final String? status;
  final int? jobId;
  final int version;
  final List<ReadingMapLink> links;

  bool get isWorking => status == 'QUEUED' || status == 'RUNNING';

  factory ReadingMapState.fromJson(Map<String, dynamic> json) =>
      ReadingMapState(
        balance: (json['balance'] as num).toInt(),
        createCost: (json['createCost'] as num).toInt(),
        refreshCost: (json['refreshCost'] as num).toInt(),
        answeredQuizCount: (json['answeredQuizCount'] as num).toInt(),
        analyzedQuizCount: (json['analyzedQuizCount'] as num).toInt(),
        hasNewQuizzes: json['hasNewQuizzes'] == true,
        status: json['status'] as String?,
        jobId: (json['jobId'] as num?)?.toInt(),
        version: (json['version'] as num).toInt(),
        links: (json['links'] as List<dynamic>)
            .map(
                (item) => ReadingMapLink.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
}

class ReadingMapLink {
  const ReadingMapLink({
    required this.quizAId,
    required this.quizBId,
    required this.type,
    required this.reason,
    required this.supportA,
    required this.supportB,
    this.fromQuizId,
  });

  final int quizAId;
  final int quizBId;
  final int? fromQuizId;
  final String type;
  final String reason;
  final String supportA;
  final String supportB;

  factory ReadingMapLink.fromJson(Map<String, dynamic> json) => ReadingMapLink(
        quizAId: (json['quizAId'] as num).toInt(),
        quizBId: (json['quizBId'] as num).toInt(),
        fromQuizId: (json['fromQuizId'] as num?)?.toInt(),
        type: json['type'] as String,
        reason: json['reason'] as String,
        supportA: json['supportA'] as String,
        supportB: json['supportB'] as String,
      );
}

class ReadingMapJobResult {
  const ReadingMapJobResult(this.jobId, this.status, this.balance);
  final int jobId;
  final String status;
  final int balance;

  factory ReadingMapJobResult.fromJson(Map<String, dynamic> json) =>
      ReadingMapJobResult(
        (json['jobId'] as num).toInt(),
        json['status'] as String,
        (json['balance'] as num).toInt(),
      );
}
