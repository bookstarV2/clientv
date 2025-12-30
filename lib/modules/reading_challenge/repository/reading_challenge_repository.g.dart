// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_challenge_repository.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers,unused_element,unnecessary_string_interpolations,unused_element_parameter

class _ReadingChallengeRepository implements ReadingChallengeRepository {
  _ReadingChallengeRepository(this._dio, {this.baseUrl, this.errorLogger});

  final Dio _dio;

  String? baseUrl;

  final ParseErrorLogger? errorLogger;

  @override
  Future<ResponseForm<List<ChallengeResponse>>> getOngoingChallenges() async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<ResponseForm<List<ChallengeResponse>>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/api/v3/challenges/ongoing',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ResponseForm<List<ChallengeResponse>> _value;
    try {
      _value = ResponseForm<List<ChallengeResponse>>.fromJson(
        _result.data!,
        (json) => json is List<dynamic>
            ? json
                .map<ChallengeResponse>(
                  (i) => ChallengeResponse.fromJson(i as Map<String, dynamic>),
                )
                .toList()
            : List.empty(),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ResponseForm<List<ChallengeResponse>>> getAbandonedChallenges() async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<ResponseForm<List<ChallengeResponse>>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/api/v3/challenges/abandoned',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ResponseForm<List<ChallengeResponse>> _value;
    try {
      _value = ResponseForm<List<ChallengeResponse>>.fromJson(
        _result.data!,
        (json) => json is List<dynamic>
            ? json
                .map<ChallengeResponse>(
                  (i) => ChallengeResponse.fromJson(i as Map<String, dynamic>),
                )
                .toList()
            : List.empty(),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ResponseForm<dynamic>> deleteChallenge(int challengeId) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<ResponseForm<dynamic>>(
      Options(method: 'DELETE', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/api/v3/challenges/${challengeId}',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ResponseForm<dynamic> _value;
    try {
      _value = ResponseForm<dynamic>.fromJson(
        _result.data!,
        (json) => json as dynamic,
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ResponseForm<ChallengeDetailResponse>> getChallenge(
    int challengeId,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<ResponseForm<ChallengeDetailResponse>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/api/v3/challenges/${challengeId}',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ResponseForm<ChallengeDetailResponse> _value;
    try {
      _value = ResponseForm<ChallengeDetailResponse>.fromJson(
        _result.data!,
        (json) =>
            ChallengeDetailResponse.fromJson(json as Map<String, dynamic>),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ResponseForm<ChallengeDetailChapterDetailResponse>> getQuizzes(
    List<int> chapterIds,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = chapterIds;
    final _options =
        _setStreamType<ResponseForm<ChallengeDetailChapterDetailResponse>>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/api/v3/chapters/quizzes',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(
            baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl),
          ),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ResponseForm<ChallengeDetailChapterDetailResponse> _value;
    try {
      _value = ResponseForm<ChallengeDetailChapterDetailResponse>.fromJson(
        _result.data!,
        (json) => ChallengeDetailChapterDetailResponse.fromJson(
          json as Map<String, dynamic>,
        ),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ResponseForm<SubmitQuizResponse>> submitQuiz(
    int quizId,
    int choiceId,
    int challengeId,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'quizId': quizId,
      r'choiceId': choiceId,
      r'challengeId': challengeId,
    };
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<ResponseForm<SubmitQuizResponse>>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/api/v3/quizzes/challenge-submit',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ResponseForm<SubmitQuizResponse> _value;
    try {
      _value = ResponseForm<SubmitQuizResponse>.fromJson(
        _result.data!,
        (json) => SubmitQuizResponse.fromJson(json as Map<String, dynamic>),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ResponseForm<void>> postReadingTimers(
    PostReadingTimerRequest request,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = request;
    final _options = _setStreamType<ResponseForm<void>>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/api/v1/reading-timers',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ResponseForm<void> _value;
    try {
      _value = ResponseForm<void>.fromJson(_result.data!, (json) => () {}());
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ResponseForm<void>> postProgress(
    int challengeId,
    PostProgressRequest request,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = request;
    final _options = _setStreamType<ResponseForm<void>>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/api/v3/challenges/${challengeId}/progress',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ResponseForm<void> _value;
    try {
      _value = ResponseForm<void>.fromJson(_result.data!, (json) => () {}());
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ResponseForm<ChallengeCreationResponse>> createChallenge(
    ReadingChallengeRequest request,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = request;
    final _options = _setStreamType<ResponseForm<ChallengeCreationResponse>>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/api/v2/reading-challenges',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ResponseForm<ChallengeCreationResponse> _value;
    try {
      _value = ResponseForm<ChallengeCreationResponse>.fromJson(
        _result.data!,
        (json) =>
            ChallengeCreationResponse.fromJson(json as Map<String, dynamic>),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ResponseForm<ChallengeProgressResponse>> updateChallengeProgress(
    int challengeId,
    ChallengeProgressRequest request,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = request;
    final _options = _setStreamType<ResponseForm<ChallengeProgressResponse>>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/api/v2/reading-challenges/${challengeId}/progress',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ResponseForm<ChallengeProgressResponse> _value;
    try {
      _value = ResponseForm<ChallengeProgressResponse>.fromJson(
        _result.data!,
        (json) =>
            ChallengeProgressResponse.fromJson(json as Map<String, dynamic>),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ResponseForm<List<ChallengeResponse>>> getCompletedChallenges() async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<ResponseForm<List<ChallengeResponse>>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/api/v2/reading-challenges/completed',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ResponseForm<List<ChallengeResponse>> _value;
    try {
      _value = ResponseForm<List<ChallengeResponse>>.fromJson(
        _result.data!,
        (json) => json is List<dynamic>
            ? json
                .map<ChallengeResponse>(
                  (i) => ChallengeResponse.fromJson(i as Map<String, dynamic>),
                )
                .toList()
            : List.empty(),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ResponseForm<List<ChallengeResponse>>> getChallengesByMember(
    int memberId,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<ResponseForm<List<ChallengeResponse>>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/api/v2/reading-challenges/members/${memberId}',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ResponseForm<List<ChallengeResponse>> _value;
    try {
      _value = ResponseForm<List<ChallengeResponse>>.fromJson(
        _result.data!,
        (json) => json is List<dynamic>
            ? json
                .map<ChallengeResponse>(
                  (i) => ChallengeResponse.fromJson(i as Map<String, dynamic>),
                )
                .toList()
            : List.empty(),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ResponseForm<dynamic>> createBookRating(
    String bookId,
    BookRatingRequest request,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = request;
    final _options = _setStreamType<ResponseForm<dynamic>>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/api/v2/books/${bookId}/ratings',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ResponseForm<dynamic> _value;
    try {
      _value = ResponseForm<dynamic>.fromJson(
        _result.data!,
        (json) => json as dynamic,
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ResponseForm<dynamic>> deleteBookRating(String bookId) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<ResponseForm<dynamic>>(
      Options(method: 'DELETE', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/api/v2/books/${bookId}/ratings',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ResponseForm<dynamic> _value;
    try {
      _value = ResponseForm<dynamic>.fromJson(
        _result.data!,
        (json) => json as dynamic,
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ResponseForm<ChallengeResponse>> restartChallenge(
    int challengeId,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<ResponseForm<ChallengeResponse>>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/api/v2/reading-challenges/${challengeId}/restart',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ResponseForm<ChallengeResponse> _value;
    try {
      _value = ResponseForm<ChallengeResponse>.fromJson(
        _result.data!,
        (json) => ChallengeResponse.fromJson(json as Map<String, dynamic>),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ResponseForm<dynamic>> abandonChallenge(int challengeId) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<ResponseForm<dynamic>>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/api/v2/reading-challenges/${challengeId}/abandon',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ResponseForm<dynamic> _value;
    try {
      _value = ResponseForm<dynamic>.fromJson(
        _result.data!,
        (json) => json as dynamic,
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ResponseForm<ChallengeDetailResponse>> getChallengeByBookId(
    String bookId,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<ResponseForm<ChallengeDetailResponse>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/api/v2/reading-challenges/books/${bookId}',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ResponseForm<ChallengeDetailResponse> _value;
    try {
      _value = ResponseForm<ChallengeDetailResponse>.fromJson(
        _result.data!,
        (json) =>
            ChallengeDetailResponse.fromJson(json as Map<String, dynamic>),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ResponseForm<bool>> checkChallengeExists(String bookId) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<ResponseForm<bool>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/api/v2/reading-challenges/exists/books/${bookId}',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ResponseForm<bool> _value;
    try {
      _value = ResponseForm<bool>.fromJson(
        _result.data!,
        (json) => json as bool,
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ResponseForm<CursorPageResponse<DiaryThumbnail>>> getMemberDiaries(
    int memberId, {
    int? cursorId,
    int? size,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'cursorId': cursorId,
      r'size': size,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options =
        _setStreamType<ResponseForm<CursorPageResponse<DiaryThumbnail>>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/reading-diaries/members/${memberId}/thumbnail',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(
            baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl),
          ),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ResponseForm<CursorPageResponse<DiaryThumbnail>> _value;
    try {
      _value = ResponseForm<CursorPageResponse<DiaryThumbnail>>.fromJson(
        _result.data!,
        (json) => CursorPageResponse<DiaryThumbnail>.fromJson(
          json as Map<String, dynamic>,
          (json) => DiaryThumbnail.fromJson(json as Map<String, dynamic>),
        ),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ResponseForm<CursorPageResponse<DiaryResponse>>>
      getLatestDiariesFeedByMember(int memberId,
          {int? cursor, int? size}) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'cursor': cursor, r'size': size};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options =
        _setStreamType<ResponseForm<CursorPageResponse<DiaryResponse>>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/reading-diaries/members/${memberId}/feed',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(
            baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl),
          ),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ResponseForm<CursorPageResponse<DiaryResponse>> _value;
    try {
      _value = ResponseForm<CursorPageResponse<DiaryResponse>>.fromJson(
        _result.data!,
        (json) => CursorPageResponse<DiaryResponse>.fromJson(
          json as Map<String, dynamic>,
          (json) => DiaryResponse.fromJson(json as Map<String, dynamic>),
        ),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ResponseForm<CursorPageResponse<DiaryThumbnail>>>
      getLatestDiaryThumbnailsByChallenge(
    int challengeId, {
    int? cursorId,
    int? size,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'cursorId': cursorId,
      r'size': size,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options =
        _setStreamType<ResponseForm<CursorPageResponse<DiaryThumbnail>>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/challenges/${challengeId}/reading-diaries/thumbnail',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(
            baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl),
          ),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ResponseForm<CursorPageResponse<DiaryThumbnail>> _value;
    try {
      _value = ResponseForm<CursorPageResponse<DiaryThumbnail>>.fromJson(
        _result.data!,
        (json) => CursorPageResponse<DiaryThumbnail>.fromJson(
          json as Map<String, dynamic>,
          (json) => DiaryThumbnail.fromJson(json as Map<String, dynamic>),
        ),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ResponseForm<DualCursorPageResponse<DiaryThumbnail>>>
      getPopularDiaryThumbnailsByChallenge(
    int challengeId, {
    int? page,
    int? size,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'page': page, r'size': size};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options =
        _setStreamType<ResponseForm<DualCursorPageResponse<DiaryThumbnail>>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/challenges/${challengeId}/reading-diaries/thumbnail/popular',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(
            baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl),
          ),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ResponseForm<DualCursorPageResponse<DiaryThumbnail>> _value;
    try {
      _value = ResponseForm<DualCursorPageResponse<DiaryThumbnail>>.fromJson(
        _result.data!,
        (json) => DualCursorPageResponse<DiaryThumbnail>.fromJson(
          json as Map<String, dynamic>,
          (json) => DiaryThumbnail.fromJson(json as Map<String, dynamic>),
        ),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ResponseForm<CursorPageResponse<DiaryResponse>>>
      getLatestDiaryFeedsByChallenge(
    int challengeId, {
    int? cursorId,
    int? size,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'cursorId': cursorId,
      r'size': size,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options =
        _setStreamType<ResponseForm<CursorPageResponse<DiaryResponse>>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/challenges/${challengeId}/reading-diaries/feed',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(
            baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl),
          ),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ResponseForm<CursorPageResponse<DiaryResponse>> _value;
    try {
      _value = ResponseForm<CursorPageResponse<DiaryResponse>>.fromJson(
        _result.data!,
        (json) => CursorPageResponse<DiaryResponse>.fromJson(
          json as Map<String, dynamic>,
          (json) => DiaryResponse.fromJson(json as Map<String, dynamic>),
        ),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ResponseForm<DualCursorPageResponse<DiaryResponse>>>
      getPopularDiaryFeedsByChallenge(
    int challengeId, {
    int? page,
    int? size,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'page': page, r'size': size};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options =
        _setStreamType<ResponseForm<DualCursorPageResponse<DiaryResponse>>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/challenges/${challengeId}/reading-diaries/feed/popular',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(
            baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl),
          ),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ResponseForm<DualCursorPageResponse<DiaryResponse>> _value;
    try {
      _value = ResponseForm<DualCursorPageResponse<DiaryResponse>>.fromJson(
        _result.data!,
        (json) => DualCursorPageResponse<DiaryResponse>.fromJson(
          json as Map<String, dynamic>,
          (json) => DiaryResponse.fromJson(json as Map<String, dynamic>),
        ),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }

  String _combineBaseUrls(String dioBaseUrl, String? baseUrl) {
    if (baseUrl == null || baseUrl.trim().isEmpty) {
      return dioBaseUrl;
    }

    final url = Uri.parse(baseUrl);

    if (url.isAbsolute) {
      return url.toString();
    }

    return Uri.parse(dioBaseUrl).resolveUri(url).toString();
  }
}

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$readingChallengeRepositoryHash() =>
    r'54e22d918af1b444c259c53038ec0900c26bdc45';

/// See also [readingChallengeRepository].
@ProviderFor(readingChallengeRepository)
final readingChallengeRepositoryProvider =
    Provider<ReadingChallengeRepository>.internal(
  readingChallengeRepository,
  name: r'readingChallengeRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$readingChallengeRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ReadingChallengeRepositoryRef = ProviderRef<ReadingChallengeRepository>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
