// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'challenge_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChallengeResponse {
  int get challengeId;
  int get bookId;
  String get bookTitle;
  String get bookAuthor;
  String get bookImageUrl;
  int get totalPages;
  int get totalChapters;
  bool get completed;
  bool get abandoned;
  String get completedAt;
  String get createdAt;
  bool get hasQuiz;
  double get progressRate;

  /// Create a copy of ChallengeResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ChallengeResponseCopyWith<ChallengeResponse> get copyWith =>
      _$ChallengeResponseCopyWithImpl<ChallengeResponse>(
          this as ChallengeResponse, _$identity);

  /// Serializes this ChallengeResponse to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ChallengeResponse &&
            (identical(other.challengeId, challengeId) ||
                other.challengeId == challengeId) &&
            (identical(other.bookId, bookId) || other.bookId == bookId) &&
            (identical(other.bookTitle, bookTitle) ||
                other.bookTitle == bookTitle) &&
            (identical(other.bookAuthor, bookAuthor) ||
                other.bookAuthor == bookAuthor) &&
            (identical(other.bookImageUrl, bookImageUrl) ||
                other.bookImageUrl == bookImageUrl) &&
            (identical(other.totalPages, totalPages) ||
                other.totalPages == totalPages) &&
            (identical(other.totalChapters, totalChapters) ||
                other.totalChapters == totalChapters) &&
            (identical(other.completed, completed) ||
                other.completed == completed) &&
            (identical(other.abandoned, abandoned) ||
                other.abandoned == abandoned) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.hasQuiz, hasQuiz) || other.hasQuiz == hasQuiz) &&
            (identical(other.progressRate, progressRate) ||
                other.progressRate == progressRate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      challengeId,
      bookId,
      bookTitle,
      bookAuthor,
      bookImageUrl,
      totalPages,
      totalChapters,
      completed,
      abandoned,
      completedAt,
      createdAt,
      hasQuiz,
      progressRate);

  @override
  String toString() {
    return 'ChallengeResponse(challengeId: $challengeId, bookId: $bookId, bookTitle: $bookTitle, bookAuthor: $bookAuthor, bookImageUrl: $bookImageUrl, totalPages: $totalPages, totalChapters: $totalChapters, completed: $completed, abandoned: $abandoned, completedAt: $completedAt, createdAt: $createdAt, hasQuiz: $hasQuiz, progressRate: $progressRate)';
  }
}

/// @nodoc
abstract mixin class $ChallengeResponseCopyWith<$Res> {
  factory $ChallengeResponseCopyWith(
          ChallengeResponse value, $Res Function(ChallengeResponse) _then) =
      _$ChallengeResponseCopyWithImpl;
  @useResult
  $Res call(
      {int challengeId,
      int bookId,
      String bookTitle,
      String bookAuthor,
      String bookImageUrl,
      int totalPages,
      int totalChapters,
      bool completed,
      bool abandoned,
      String completedAt,
      String createdAt,
      bool hasQuiz,
      double progressRate});
}

/// @nodoc
class _$ChallengeResponseCopyWithImpl<$Res>
    implements $ChallengeResponseCopyWith<$Res> {
  _$ChallengeResponseCopyWithImpl(this._self, this._then);

  final ChallengeResponse _self;
  final $Res Function(ChallengeResponse) _then;

  /// Create a copy of ChallengeResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? challengeId = null,
    Object? bookId = null,
    Object? bookTitle = null,
    Object? bookAuthor = null,
    Object? bookImageUrl = null,
    Object? totalPages = null,
    Object? totalChapters = null,
    Object? completed = null,
    Object? abandoned = null,
    Object? completedAt = null,
    Object? createdAt = null,
    Object? hasQuiz = null,
    Object? progressRate = null,
  }) {
    return _then(_self.copyWith(
      challengeId: null == challengeId
          ? _self.challengeId
          : challengeId // ignore: cast_nullable_to_non_nullable
              as int,
      bookId: null == bookId
          ? _self.bookId
          : bookId // ignore: cast_nullable_to_non_nullable
              as int,
      bookTitle: null == bookTitle
          ? _self.bookTitle
          : bookTitle // ignore: cast_nullable_to_non_nullable
              as String,
      bookAuthor: null == bookAuthor
          ? _self.bookAuthor
          : bookAuthor // ignore: cast_nullable_to_non_nullable
              as String,
      bookImageUrl: null == bookImageUrl
          ? _self.bookImageUrl
          : bookImageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      totalPages: null == totalPages
          ? _self.totalPages
          : totalPages // ignore: cast_nullable_to_non_nullable
              as int,
      totalChapters: null == totalChapters
          ? _self.totalChapters
          : totalChapters // ignore: cast_nullable_to_non_nullable
              as int,
      completed: null == completed
          ? _self.completed
          : completed // ignore: cast_nullable_to_non_nullable
              as bool,
      abandoned: null == abandoned
          ? _self.abandoned
          : abandoned // ignore: cast_nullable_to_non_nullable
              as bool,
      completedAt: null == completedAt
          ? _self.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      hasQuiz: null == hasQuiz
          ? _self.hasQuiz
          : hasQuiz // ignore: cast_nullable_to_non_nullable
              as bool,
      progressRate: null == progressRate
          ? _self.progressRate
          : progressRate // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// Adds pattern-matching-related methods to [ChallengeResponse].
extension ChallengeResponsePatterns on ChallengeResponse {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ChallengeResponse value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ChallengeResponse() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ChallengeResponse value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChallengeResponse():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ChallengeResponse value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChallengeResponse() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            int challengeId,
            int bookId,
            String bookTitle,
            String bookAuthor,
            String bookImageUrl,
            int totalPages,
            int totalChapters,
            bool completed,
            bool abandoned,
            String completedAt,
            String createdAt,
            bool hasQuiz,
            double progressRate)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ChallengeResponse() when $default != null:
        return $default(
            _that.challengeId,
            _that.bookId,
            _that.bookTitle,
            _that.bookAuthor,
            _that.bookImageUrl,
            _that.totalPages,
            _that.totalChapters,
            _that.completed,
            _that.abandoned,
            _that.completedAt,
            _that.createdAt,
            _that.hasQuiz,
            _that.progressRate);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            int challengeId,
            int bookId,
            String bookTitle,
            String bookAuthor,
            String bookImageUrl,
            int totalPages,
            int totalChapters,
            bool completed,
            bool abandoned,
            String completedAt,
            String createdAt,
            bool hasQuiz,
            double progressRate)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChallengeResponse():
        return $default(
            _that.challengeId,
            _that.bookId,
            _that.bookTitle,
            _that.bookAuthor,
            _that.bookImageUrl,
            _that.totalPages,
            _that.totalChapters,
            _that.completed,
            _that.abandoned,
            _that.completedAt,
            _that.createdAt,
            _that.hasQuiz,
            _that.progressRate);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            int challengeId,
            int bookId,
            String bookTitle,
            String bookAuthor,
            String bookImageUrl,
            int totalPages,
            int totalChapters,
            bool completed,
            bool abandoned,
            String completedAt,
            String createdAt,
            bool hasQuiz,
            double progressRate)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChallengeResponse() when $default != null:
        return $default(
            _that.challengeId,
            _that.bookId,
            _that.bookTitle,
            _that.bookAuthor,
            _that.bookImageUrl,
            _that.totalPages,
            _that.totalChapters,
            _that.completed,
            _that.abandoned,
            _that.completedAt,
            _that.createdAt,
            _that.hasQuiz,
            _that.progressRate);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _ChallengeResponse implements ChallengeResponse {
  const _ChallengeResponse(
      {this.challengeId = -1,
      this.bookId = -1,
      this.bookTitle = '',
      this.bookAuthor = '',
      this.bookImageUrl = '',
      this.totalPages = -1,
      this.totalChapters = -1,
      this.completed = false,
      this.abandoned = false,
      this.completedAt = '',
      this.createdAt = '',
      this.hasQuiz = false,
      this.progressRate = 0.0});
  factory _ChallengeResponse.fromJson(Map<String, dynamic> json) =>
      _$ChallengeResponseFromJson(json);

  @override
  @JsonKey()
  final int challengeId;
  @override
  @JsonKey()
  final int bookId;
  @override
  @JsonKey()
  final String bookTitle;
  @override
  @JsonKey()
  final String bookAuthor;
  @override
  @JsonKey()
  final String bookImageUrl;
  @override
  @JsonKey()
  final int totalPages;
  @override
  @JsonKey()
  final int totalChapters;
  @override
  @JsonKey()
  final bool completed;
  @override
  @JsonKey()
  final bool abandoned;
  @override
  @JsonKey()
  final String completedAt;
  @override
  @JsonKey()
  final String createdAt;
  @override
  @JsonKey()
  final bool hasQuiz;
  @override
  @JsonKey()
  final double progressRate;

  /// Create a copy of ChallengeResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ChallengeResponseCopyWith<_ChallengeResponse> get copyWith =>
      __$ChallengeResponseCopyWithImpl<_ChallengeResponse>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ChallengeResponseToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ChallengeResponse &&
            (identical(other.challengeId, challengeId) ||
                other.challengeId == challengeId) &&
            (identical(other.bookId, bookId) || other.bookId == bookId) &&
            (identical(other.bookTitle, bookTitle) ||
                other.bookTitle == bookTitle) &&
            (identical(other.bookAuthor, bookAuthor) ||
                other.bookAuthor == bookAuthor) &&
            (identical(other.bookImageUrl, bookImageUrl) ||
                other.bookImageUrl == bookImageUrl) &&
            (identical(other.totalPages, totalPages) ||
                other.totalPages == totalPages) &&
            (identical(other.totalChapters, totalChapters) ||
                other.totalChapters == totalChapters) &&
            (identical(other.completed, completed) ||
                other.completed == completed) &&
            (identical(other.abandoned, abandoned) ||
                other.abandoned == abandoned) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.hasQuiz, hasQuiz) || other.hasQuiz == hasQuiz) &&
            (identical(other.progressRate, progressRate) ||
                other.progressRate == progressRate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      challengeId,
      bookId,
      bookTitle,
      bookAuthor,
      bookImageUrl,
      totalPages,
      totalChapters,
      completed,
      abandoned,
      completedAt,
      createdAt,
      hasQuiz,
      progressRate);

  @override
  String toString() {
    return 'ChallengeResponse(challengeId: $challengeId, bookId: $bookId, bookTitle: $bookTitle, bookAuthor: $bookAuthor, bookImageUrl: $bookImageUrl, totalPages: $totalPages, totalChapters: $totalChapters, completed: $completed, abandoned: $abandoned, completedAt: $completedAt, createdAt: $createdAt, hasQuiz: $hasQuiz, progressRate: $progressRate)';
  }
}

/// @nodoc
abstract mixin class _$ChallengeResponseCopyWith<$Res>
    implements $ChallengeResponseCopyWith<$Res> {
  factory _$ChallengeResponseCopyWith(
          _ChallengeResponse value, $Res Function(_ChallengeResponse) _then) =
      __$ChallengeResponseCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int challengeId,
      int bookId,
      String bookTitle,
      String bookAuthor,
      String bookImageUrl,
      int totalPages,
      int totalChapters,
      bool completed,
      bool abandoned,
      String completedAt,
      String createdAt,
      bool hasQuiz,
      double progressRate});
}

/// @nodoc
class __$ChallengeResponseCopyWithImpl<$Res>
    implements _$ChallengeResponseCopyWith<$Res> {
  __$ChallengeResponseCopyWithImpl(this._self, this._then);

  final _ChallengeResponse _self;
  final $Res Function(_ChallengeResponse) _then;

  /// Create a copy of ChallengeResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? challengeId = null,
    Object? bookId = null,
    Object? bookTitle = null,
    Object? bookAuthor = null,
    Object? bookImageUrl = null,
    Object? totalPages = null,
    Object? totalChapters = null,
    Object? completed = null,
    Object? abandoned = null,
    Object? completedAt = null,
    Object? createdAt = null,
    Object? hasQuiz = null,
    Object? progressRate = null,
  }) {
    return _then(_ChallengeResponse(
      challengeId: null == challengeId
          ? _self.challengeId
          : challengeId // ignore: cast_nullable_to_non_nullable
              as int,
      bookId: null == bookId
          ? _self.bookId
          : bookId // ignore: cast_nullable_to_non_nullable
              as int,
      bookTitle: null == bookTitle
          ? _self.bookTitle
          : bookTitle // ignore: cast_nullable_to_non_nullable
              as String,
      bookAuthor: null == bookAuthor
          ? _self.bookAuthor
          : bookAuthor // ignore: cast_nullable_to_non_nullable
              as String,
      bookImageUrl: null == bookImageUrl
          ? _self.bookImageUrl
          : bookImageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      totalPages: null == totalPages
          ? _self.totalPages
          : totalPages // ignore: cast_nullable_to_non_nullable
              as int,
      totalChapters: null == totalChapters
          ? _self.totalChapters
          : totalChapters // ignore: cast_nullable_to_non_nullable
              as int,
      completed: null == completed
          ? _self.completed
          : completed // ignore: cast_nullable_to_non_nullable
              as bool,
      abandoned: null == abandoned
          ? _self.abandoned
          : abandoned // ignore: cast_nullable_to_non_nullable
              as bool,
      completedAt: null == completedAt
          ? _self.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      hasQuiz: null == hasQuiz
          ? _self.hasQuiz
          : hasQuiz // ignore: cast_nullable_to_non_nullable
              as bool,
      progressRate: null == progressRate
          ? _self.progressRate
          : progressRate // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

// dart format on
