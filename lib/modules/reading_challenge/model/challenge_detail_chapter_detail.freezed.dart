// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'challenge_detail_chapter_detail.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChallengeDetailChapterDetail {
  int get chapterId;
  int get chapterNumber;
  String get chapterTitle;
  int get quizId;
  String get question;
  List<QuizChoice> get choices;
  int get totalAttempts;
  String get createdAt;

  /// Create a copy of ChallengeDetailChapterDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ChallengeDetailChapterDetailCopyWith<ChallengeDetailChapterDetail>
      get copyWith => _$ChallengeDetailChapterDetailCopyWithImpl<
              ChallengeDetailChapterDetail>(
          this as ChallengeDetailChapterDetail, _$identity);

  /// Serializes this ChallengeDetailChapterDetail to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ChallengeDetailChapterDetail &&
            (identical(other.chapterId, chapterId) ||
                other.chapterId == chapterId) &&
            (identical(other.chapterNumber, chapterNumber) ||
                other.chapterNumber == chapterNumber) &&
            (identical(other.chapterTitle, chapterTitle) ||
                other.chapterTitle == chapterTitle) &&
            (identical(other.quizId, quizId) || other.quizId == quizId) &&
            (identical(other.question, question) ||
                other.question == question) &&
            const DeepCollectionEquality().equals(other.choices, choices) &&
            (identical(other.totalAttempts, totalAttempts) ||
                other.totalAttempts == totalAttempts) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      chapterId,
      chapterNumber,
      chapterTitle,
      quizId,
      question,
      const DeepCollectionEquality().hash(choices),
      totalAttempts,
      createdAt);

  @override
  String toString() {
    return 'ChallengeDetailChapterDetail(chapterId: $chapterId, chapterNumber: $chapterNumber, chapterTitle: $chapterTitle, quizId: $quizId, question: $question, choices: $choices, totalAttempts: $totalAttempts, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class $ChallengeDetailChapterDetailCopyWith<$Res> {
  factory $ChallengeDetailChapterDetailCopyWith(
          ChallengeDetailChapterDetail value,
          $Res Function(ChallengeDetailChapterDetail) _then) =
      _$ChallengeDetailChapterDetailCopyWithImpl;
  @useResult
  $Res call(
      {int chapterId,
      int chapterNumber,
      String chapterTitle,
      int quizId,
      String question,
      List<QuizChoice> choices,
      int totalAttempts,
      String createdAt});
}

/// @nodoc
class _$ChallengeDetailChapterDetailCopyWithImpl<$Res>
    implements $ChallengeDetailChapterDetailCopyWith<$Res> {
  _$ChallengeDetailChapterDetailCopyWithImpl(this._self, this._then);

  final ChallengeDetailChapterDetail _self;
  final $Res Function(ChallengeDetailChapterDetail) _then;

  /// Create a copy of ChallengeDetailChapterDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? chapterId = null,
    Object? chapterNumber = null,
    Object? chapterTitle = null,
    Object? quizId = null,
    Object? question = null,
    Object? choices = null,
    Object? totalAttempts = null,
    Object? createdAt = null,
  }) {
    return _then(_self.copyWith(
      chapterId: null == chapterId
          ? _self.chapterId
          : chapterId // ignore: cast_nullable_to_non_nullable
              as int,
      chapterNumber: null == chapterNumber
          ? _self.chapterNumber
          : chapterNumber // ignore: cast_nullable_to_non_nullable
              as int,
      chapterTitle: null == chapterTitle
          ? _self.chapterTitle
          : chapterTitle // ignore: cast_nullable_to_non_nullable
              as String,
      quizId: null == quizId
          ? _self.quizId
          : quizId // ignore: cast_nullable_to_non_nullable
              as int,
      question: null == question
          ? _self.question
          : question // ignore: cast_nullable_to_non_nullable
              as String,
      choices: null == choices
          ? _self.choices
          : choices // ignore: cast_nullable_to_non_nullable
              as List<QuizChoice>,
      totalAttempts: null == totalAttempts
          ? _self.totalAttempts
          : totalAttempts // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [ChallengeDetailChapterDetail].
extension ChallengeDetailChapterDetailPatterns on ChallengeDetailChapterDetail {
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
    TResult Function(_ChallengeDetailChapterDetail value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ChallengeDetailChapterDetail() when $default != null:
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
    TResult Function(_ChallengeDetailChapterDetail value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChallengeDetailChapterDetail():
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
    TResult? Function(_ChallengeDetailChapterDetail value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChallengeDetailChapterDetail() when $default != null:
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
            int chapterId,
            int chapterNumber,
            String chapterTitle,
            int quizId,
            String question,
            List<QuizChoice> choices,
            int totalAttempts,
            String createdAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ChallengeDetailChapterDetail() when $default != null:
        return $default(
            _that.chapterId,
            _that.chapterNumber,
            _that.chapterTitle,
            _that.quizId,
            _that.question,
            _that.choices,
            _that.totalAttempts,
            _that.createdAt);
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
            int chapterId,
            int chapterNumber,
            String chapterTitle,
            int quizId,
            String question,
            List<QuizChoice> choices,
            int totalAttempts,
            String createdAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChallengeDetailChapterDetail():
        return $default(
            _that.chapterId,
            _that.chapterNumber,
            _that.chapterTitle,
            _that.quizId,
            _that.question,
            _that.choices,
            _that.totalAttempts,
            _that.createdAt);
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
            int chapterId,
            int chapterNumber,
            String chapterTitle,
            int quizId,
            String question,
            List<QuizChoice> choices,
            int totalAttempts,
            String createdAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChallengeDetailChapterDetail() when $default != null:
        return $default(
            _that.chapterId,
            _that.chapterNumber,
            _that.chapterTitle,
            _that.quizId,
            _that.question,
            _that.choices,
            _that.totalAttempts,
            _that.createdAt);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _ChallengeDetailChapterDetail implements ChallengeDetailChapterDetail {
  const _ChallengeDetailChapterDetail(
      {this.chapterId = -1,
      this.chapterNumber = -1,
      this.chapterTitle = '',
      this.quizId = -1,
      this.question = '',
      final List<QuizChoice> choices = const [],
      this.totalAttempts = -1,
      this.createdAt = ''})
      : _choices = choices;
  factory _ChallengeDetailChapterDetail.fromJson(Map<String, dynamic> json) =>
      _$ChallengeDetailChapterDetailFromJson(json);

  @override
  @JsonKey()
  final int chapterId;
  @override
  @JsonKey()
  final int chapterNumber;
  @override
  @JsonKey()
  final String chapterTitle;
  @override
  @JsonKey()
  final int quizId;
  @override
  @JsonKey()
  final String question;
  final List<QuizChoice> _choices;
  @override
  @JsonKey()
  List<QuizChoice> get choices {
    if (_choices is EqualUnmodifiableListView) return _choices;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_choices);
  }

  @override
  @JsonKey()
  final int totalAttempts;
  @override
  @JsonKey()
  final String createdAt;

  /// Create a copy of ChallengeDetailChapterDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ChallengeDetailChapterDetailCopyWith<_ChallengeDetailChapterDetail>
      get copyWith => __$ChallengeDetailChapterDetailCopyWithImpl<
          _ChallengeDetailChapterDetail>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ChallengeDetailChapterDetailToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ChallengeDetailChapterDetail &&
            (identical(other.chapterId, chapterId) ||
                other.chapterId == chapterId) &&
            (identical(other.chapterNumber, chapterNumber) ||
                other.chapterNumber == chapterNumber) &&
            (identical(other.chapterTitle, chapterTitle) ||
                other.chapterTitle == chapterTitle) &&
            (identical(other.quizId, quizId) || other.quizId == quizId) &&
            (identical(other.question, question) ||
                other.question == question) &&
            const DeepCollectionEquality().equals(other._choices, _choices) &&
            (identical(other.totalAttempts, totalAttempts) ||
                other.totalAttempts == totalAttempts) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      chapterId,
      chapterNumber,
      chapterTitle,
      quizId,
      question,
      const DeepCollectionEquality().hash(_choices),
      totalAttempts,
      createdAt);

  @override
  String toString() {
    return 'ChallengeDetailChapterDetail(chapterId: $chapterId, chapterNumber: $chapterNumber, chapterTitle: $chapterTitle, quizId: $quizId, question: $question, choices: $choices, totalAttempts: $totalAttempts, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class _$ChallengeDetailChapterDetailCopyWith<$Res>
    implements $ChallengeDetailChapterDetailCopyWith<$Res> {
  factory _$ChallengeDetailChapterDetailCopyWith(
          _ChallengeDetailChapterDetail value,
          $Res Function(_ChallengeDetailChapterDetail) _then) =
      __$ChallengeDetailChapterDetailCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int chapterId,
      int chapterNumber,
      String chapterTitle,
      int quizId,
      String question,
      List<QuizChoice> choices,
      int totalAttempts,
      String createdAt});
}

/// @nodoc
class __$ChallengeDetailChapterDetailCopyWithImpl<$Res>
    implements _$ChallengeDetailChapterDetailCopyWith<$Res> {
  __$ChallengeDetailChapterDetailCopyWithImpl(this._self, this._then);

  final _ChallengeDetailChapterDetail _self;
  final $Res Function(_ChallengeDetailChapterDetail) _then;

  /// Create a copy of ChallengeDetailChapterDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? chapterId = null,
    Object? chapterNumber = null,
    Object? chapterTitle = null,
    Object? quizId = null,
    Object? question = null,
    Object? choices = null,
    Object? totalAttempts = null,
    Object? createdAt = null,
  }) {
    return _then(_ChallengeDetailChapterDetail(
      chapterId: null == chapterId
          ? _self.chapterId
          : chapterId // ignore: cast_nullable_to_non_nullable
              as int,
      chapterNumber: null == chapterNumber
          ? _self.chapterNumber
          : chapterNumber // ignore: cast_nullable_to_non_nullable
              as int,
      chapterTitle: null == chapterTitle
          ? _self.chapterTitle
          : chapterTitle // ignore: cast_nullable_to_non_nullable
              as String,
      quizId: null == quizId
          ? _self.quizId
          : quizId // ignore: cast_nullable_to_non_nullable
              as int,
      question: null == question
          ? _self.question
          : question // ignore: cast_nullable_to_non_nullable
              as String,
      choices: null == choices
          ? _self._choices
          : choices // ignore: cast_nullable_to_non_nullable
              as List<QuizChoice>,
      totalAttempts: null == totalAttempts
          ? _self.totalAttempts
          : totalAttempts // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
