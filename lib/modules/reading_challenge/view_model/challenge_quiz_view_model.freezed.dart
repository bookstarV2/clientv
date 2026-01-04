// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'challenge_quiz_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChallengeQuizState {
  int get quizId;
  ChallengeDetailChapterDetail get chapter;
  List<ChoiceResult>? get choiceResults;

  /// Create a copy of ChallengeQuizState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ChallengeQuizStateCopyWith<ChallengeQuizState> get copyWith =>
      _$ChallengeQuizStateCopyWithImpl<ChallengeQuizState>(
          this as ChallengeQuizState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ChallengeQuizState &&
            (identical(other.quizId, quizId) || other.quizId == quizId) &&
            (identical(other.chapter, chapter) || other.chapter == chapter) &&
            const DeepCollectionEquality()
                .equals(other.choiceResults, choiceResults));
  }

  @override
  int get hashCode => Object.hash(runtimeType, quizId, chapter,
      const DeepCollectionEquality().hash(choiceResults));

  @override
  String toString() {
    return 'ChallengeQuizState(quizId: $quizId, chapter: $chapter, choiceResults: $choiceResults)';
  }
}

/// @nodoc
abstract mixin class $ChallengeQuizStateCopyWith<$Res> {
  factory $ChallengeQuizStateCopyWith(
          ChallengeQuizState value, $Res Function(ChallengeQuizState) _then) =
      _$ChallengeQuizStateCopyWithImpl;
  @useResult
  $Res call(
      {int quizId,
      ChallengeDetailChapterDetail chapter,
      List<ChoiceResult>? choiceResults});

  $ChallengeDetailChapterDetailCopyWith<$Res> get chapter;
}

/// @nodoc
class _$ChallengeQuizStateCopyWithImpl<$Res>
    implements $ChallengeQuizStateCopyWith<$Res> {
  _$ChallengeQuizStateCopyWithImpl(this._self, this._then);

  final ChallengeQuizState _self;
  final $Res Function(ChallengeQuizState) _then;

  /// Create a copy of ChallengeQuizState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? quizId = null,
    Object? chapter = null,
    Object? choiceResults = freezed,
  }) {
    return _then(_self.copyWith(
      quizId: null == quizId
          ? _self.quizId
          : quizId // ignore: cast_nullable_to_non_nullable
              as int,
      chapter: null == chapter
          ? _self.chapter
          : chapter // ignore: cast_nullable_to_non_nullable
              as ChallengeDetailChapterDetail,
      choiceResults: freezed == choiceResults
          ? _self.choiceResults
          : choiceResults // ignore: cast_nullable_to_non_nullable
              as List<ChoiceResult>?,
    ));
  }

  /// Create a copy of ChallengeQuizState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ChallengeDetailChapterDetailCopyWith<$Res> get chapter {
    return $ChallengeDetailChapterDetailCopyWith<$Res>(_self.chapter, (value) {
      return _then(_self.copyWith(chapter: value));
    });
  }
}

/// Adds pattern-matching-related methods to [ChallengeQuizState].
extension ChallengeQuizStatePatterns on ChallengeQuizState {
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
    TResult Function(_ChallengeQuizState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ChallengeQuizState() when $default != null:
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
    TResult Function(_ChallengeQuizState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChallengeQuizState():
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
    TResult? Function(_ChallengeQuizState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChallengeQuizState() when $default != null:
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
    TResult Function(int quizId, ChallengeDetailChapterDetail chapter,
            List<ChoiceResult>? choiceResults)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ChallengeQuizState() when $default != null:
        return $default(_that.quizId, _that.chapter, _that.choiceResults);
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
    TResult Function(int quizId, ChallengeDetailChapterDetail chapter,
            List<ChoiceResult>? choiceResults)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChallengeQuizState():
        return $default(_that.quizId, _that.chapter, _that.choiceResults);
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
    TResult? Function(int quizId, ChallengeDetailChapterDetail chapter,
            List<ChoiceResult>? choiceResults)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChallengeQuizState() when $default != null:
        return $default(_that.quizId, _that.chapter, _that.choiceResults);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _ChallengeQuizState implements ChallengeQuizState {
  const _ChallengeQuizState(
      {this.quizId = -1,
      this.chapter = const ChallengeDetailChapterDetail(),
      final List<ChoiceResult>? choiceResults})
      : _choiceResults = choiceResults;

  @override
  @JsonKey()
  final int quizId;
  @override
  @JsonKey()
  final ChallengeDetailChapterDetail chapter;
  final List<ChoiceResult>? _choiceResults;
  @override
  List<ChoiceResult>? get choiceResults {
    final value = _choiceResults;
    if (value == null) return null;
    if (_choiceResults is EqualUnmodifiableListView) return _choiceResults;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  /// Create a copy of ChallengeQuizState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ChallengeQuizStateCopyWith<_ChallengeQuizState> get copyWith =>
      __$ChallengeQuizStateCopyWithImpl<_ChallengeQuizState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ChallengeQuizState &&
            (identical(other.quizId, quizId) || other.quizId == quizId) &&
            (identical(other.chapter, chapter) || other.chapter == chapter) &&
            const DeepCollectionEquality()
                .equals(other._choiceResults, _choiceResults));
  }

  @override
  int get hashCode => Object.hash(runtimeType, quizId, chapter,
      const DeepCollectionEquality().hash(_choiceResults));

  @override
  String toString() {
    return 'ChallengeQuizState(quizId: $quizId, chapter: $chapter, choiceResults: $choiceResults)';
  }
}

/// @nodoc
abstract mixin class _$ChallengeQuizStateCopyWith<$Res>
    implements $ChallengeQuizStateCopyWith<$Res> {
  factory _$ChallengeQuizStateCopyWith(
          _ChallengeQuizState value, $Res Function(_ChallengeQuizState) _then) =
      __$ChallengeQuizStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int quizId,
      ChallengeDetailChapterDetail chapter,
      List<ChoiceResult>? choiceResults});

  @override
  $ChallengeDetailChapterDetailCopyWith<$Res> get chapter;
}

/// @nodoc
class __$ChallengeQuizStateCopyWithImpl<$Res>
    implements _$ChallengeQuizStateCopyWith<$Res> {
  __$ChallengeQuizStateCopyWithImpl(this._self, this._then);

  final _ChallengeQuizState _self;
  final $Res Function(_ChallengeQuizState) _then;

  /// Create a copy of ChallengeQuizState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? quizId = null,
    Object? chapter = null,
    Object? choiceResults = freezed,
  }) {
    return _then(_ChallengeQuizState(
      quizId: null == quizId
          ? _self.quizId
          : quizId // ignore: cast_nullable_to_non_nullable
              as int,
      chapter: null == chapter
          ? _self.chapter
          : chapter // ignore: cast_nullable_to_non_nullable
              as ChallengeDetailChapterDetail,
      choiceResults: freezed == choiceResults
          ? _self._choiceResults
          : choiceResults // ignore: cast_nullable_to_non_nullable
              as List<ChoiceResult>?,
    ));
  }

  /// Create a copy of ChallengeQuizState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ChallengeDetailChapterDetailCopyWith<$Res> get chapter {
    return $ChallengeDetailChapterDetailCopyWith<$Res>(_self.chapter, (value) {
      return _then(_self.copyWith(chapter: value));
    });
  }
}

// dart format on
