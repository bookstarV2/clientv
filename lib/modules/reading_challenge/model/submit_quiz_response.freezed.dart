// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'submit_quiz_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SubmitQuizResponse {
  int get quizId;
  int get attemptId;
  bool get isCorrect;
  int get selectedChoiceId;
  int get correctChoiceId;
  List<ChoiceResult> get choiceResults;
  int get totalAttempts;
  double get correctRate;
  bool get isChallengeCompleted;

  /// Create a copy of SubmitQuizResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SubmitQuizResponseCopyWith<SubmitQuizResponse> get copyWith =>
      _$SubmitQuizResponseCopyWithImpl<SubmitQuizResponse>(
          this as SubmitQuizResponse, _$identity);

  /// Serializes this SubmitQuizResponse to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SubmitQuizResponse &&
            (identical(other.quizId, quizId) || other.quizId == quizId) &&
            (identical(other.attemptId, attemptId) ||
                other.attemptId == attemptId) &&
            (identical(other.isCorrect, isCorrect) ||
                other.isCorrect == isCorrect) &&
            (identical(other.selectedChoiceId, selectedChoiceId) ||
                other.selectedChoiceId == selectedChoiceId) &&
            (identical(other.correctChoiceId, correctChoiceId) ||
                other.correctChoiceId == correctChoiceId) &&
            const DeepCollectionEquality()
                .equals(other.choiceResults, choiceResults) &&
            (identical(other.totalAttempts, totalAttempts) ||
                other.totalAttempts == totalAttempts) &&
            (identical(other.correctRate, correctRate) ||
                other.correctRate == correctRate) &&
            (identical(other.isChallengeCompleted, isChallengeCompleted) ||
                other.isChallengeCompleted == isChallengeCompleted));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      quizId,
      attemptId,
      isCorrect,
      selectedChoiceId,
      correctChoiceId,
      const DeepCollectionEquality().hash(choiceResults),
      totalAttempts,
      correctRate,
      isChallengeCompleted);

  @override
  String toString() {
    return 'SubmitQuizResponse(quizId: $quizId, attemptId: $attemptId, isCorrect: $isCorrect, selectedChoiceId: $selectedChoiceId, correctChoiceId: $correctChoiceId, choiceResults: $choiceResults, totalAttempts: $totalAttempts, correctRate: $correctRate, isChallengeCompleted: $isChallengeCompleted)';
  }
}

/// @nodoc
abstract mixin class $SubmitQuizResponseCopyWith<$Res> {
  factory $SubmitQuizResponseCopyWith(
          SubmitQuizResponse value, $Res Function(SubmitQuizResponse) _then) =
      _$SubmitQuizResponseCopyWithImpl;
  @useResult
  $Res call(
      {int quizId,
      int attemptId,
      bool isCorrect,
      int selectedChoiceId,
      int correctChoiceId,
      List<ChoiceResult> choiceResults,
      int totalAttempts,
      double correctRate,
      bool isChallengeCompleted});
}

/// @nodoc
class _$SubmitQuizResponseCopyWithImpl<$Res>
    implements $SubmitQuizResponseCopyWith<$Res> {
  _$SubmitQuizResponseCopyWithImpl(this._self, this._then);

  final SubmitQuizResponse _self;
  final $Res Function(SubmitQuizResponse) _then;

  /// Create a copy of SubmitQuizResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? quizId = null,
    Object? attemptId = null,
    Object? isCorrect = null,
    Object? selectedChoiceId = null,
    Object? correctChoiceId = null,
    Object? choiceResults = null,
    Object? totalAttempts = null,
    Object? correctRate = null,
    Object? isChallengeCompleted = null,
  }) {
    return _then(_self.copyWith(
      quizId: null == quizId
          ? _self.quizId
          : quizId // ignore: cast_nullable_to_non_nullable
              as int,
      attemptId: null == attemptId
          ? _self.attemptId
          : attemptId // ignore: cast_nullable_to_non_nullable
              as int,
      isCorrect: null == isCorrect
          ? _self.isCorrect
          : isCorrect // ignore: cast_nullable_to_non_nullable
              as bool,
      selectedChoiceId: null == selectedChoiceId
          ? _self.selectedChoiceId
          : selectedChoiceId // ignore: cast_nullable_to_non_nullable
              as int,
      correctChoiceId: null == correctChoiceId
          ? _self.correctChoiceId
          : correctChoiceId // ignore: cast_nullable_to_non_nullable
              as int,
      choiceResults: null == choiceResults
          ? _self.choiceResults
          : choiceResults // ignore: cast_nullable_to_non_nullable
              as List<ChoiceResult>,
      totalAttempts: null == totalAttempts
          ? _self.totalAttempts
          : totalAttempts // ignore: cast_nullable_to_non_nullable
              as int,
      correctRate: null == correctRate
          ? _self.correctRate
          : correctRate // ignore: cast_nullable_to_non_nullable
              as double,
      isChallengeCompleted: null == isChallengeCompleted
          ? _self.isChallengeCompleted
          : isChallengeCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [SubmitQuizResponse].
extension SubmitQuizResponsePatterns on SubmitQuizResponse {
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
    TResult Function(_SubmitQuizResponse value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SubmitQuizResponse() when $default != null:
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
    TResult Function(_SubmitQuizResponse value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SubmitQuizResponse():
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
    TResult? Function(_SubmitQuizResponse value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SubmitQuizResponse() when $default != null:
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
            int quizId,
            int attemptId,
            bool isCorrect,
            int selectedChoiceId,
            int correctChoiceId,
            List<ChoiceResult> choiceResults,
            int totalAttempts,
            double correctRate,
            bool isChallengeCompleted)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SubmitQuizResponse() when $default != null:
        return $default(
            _that.quizId,
            _that.attemptId,
            _that.isCorrect,
            _that.selectedChoiceId,
            _that.correctChoiceId,
            _that.choiceResults,
            _that.totalAttempts,
            _that.correctRate,
            _that.isChallengeCompleted);
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
            int quizId,
            int attemptId,
            bool isCorrect,
            int selectedChoiceId,
            int correctChoiceId,
            List<ChoiceResult> choiceResults,
            int totalAttempts,
            double correctRate,
            bool isChallengeCompleted)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SubmitQuizResponse():
        return $default(
            _that.quizId,
            _that.attemptId,
            _that.isCorrect,
            _that.selectedChoiceId,
            _that.correctChoiceId,
            _that.choiceResults,
            _that.totalAttempts,
            _that.correctRate,
            _that.isChallengeCompleted);
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
            int quizId,
            int attemptId,
            bool isCorrect,
            int selectedChoiceId,
            int correctChoiceId,
            List<ChoiceResult> choiceResults,
            int totalAttempts,
            double correctRate,
            bool isChallengeCompleted)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SubmitQuizResponse() when $default != null:
        return $default(
            _that.quizId,
            _that.attemptId,
            _that.isCorrect,
            _that.selectedChoiceId,
            _that.correctChoiceId,
            _that.choiceResults,
            _that.totalAttempts,
            _that.correctRate,
            _that.isChallengeCompleted);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _SubmitQuizResponse implements SubmitQuizResponse {
  const _SubmitQuizResponse(
      {this.quizId = -1,
      this.attemptId = -1,
      this.isCorrect = false,
      this.selectedChoiceId = -1,
      this.correctChoiceId = -1,
      final List<ChoiceResult> choiceResults = const [],
      this.totalAttempts = -1,
      this.correctRate = 0.0,
      this.isChallengeCompleted = false})
      : _choiceResults = choiceResults;
  factory _SubmitQuizResponse.fromJson(Map<String, dynamic> json) =>
      _$SubmitQuizResponseFromJson(json);

  @override
  @JsonKey()
  final int quizId;
  @override
  @JsonKey()
  final int attemptId;
  @override
  @JsonKey()
  final bool isCorrect;
  @override
  @JsonKey()
  final int selectedChoiceId;
  @override
  @JsonKey()
  final int correctChoiceId;
  final List<ChoiceResult> _choiceResults;
  @override
  @JsonKey()
  List<ChoiceResult> get choiceResults {
    if (_choiceResults is EqualUnmodifiableListView) return _choiceResults;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_choiceResults);
  }

  @override
  @JsonKey()
  final int totalAttempts;
  @override
  @JsonKey()
  final double correctRate;
  @override
  @JsonKey()
  final bool isChallengeCompleted;

  /// Create a copy of SubmitQuizResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SubmitQuizResponseCopyWith<_SubmitQuizResponse> get copyWith =>
      __$SubmitQuizResponseCopyWithImpl<_SubmitQuizResponse>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SubmitQuizResponseToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SubmitQuizResponse &&
            (identical(other.quizId, quizId) || other.quizId == quizId) &&
            (identical(other.attemptId, attemptId) ||
                other.attemptId == attemptId) &&
            (identical(other.isCorrect, isCorrect) ||
                other.isCorrect == isCorrect) &&
            (identical(other.selectedChoiceId, selectedChoiceId) ||
                other.selectedChoiceId == selectedChoiceId) &&
            (identical(other.correctChoiceId, correctChoiceId) ||
                other.correctChoiceId == correctChoiceId) &&
            const DeepCollectionEquality()
                .equals(other._choiceResults, _choiceResults) &&
            (identical(other.totalAttempts, totalAttempts) ||
                other.totalAttempts == totalAttempts) &&
            (identical(other.correctRate, correctRate) ||
                other.correctRate == correctRate) &&
            (identical(other.isChallengeCompleted, isChallengeCompleted) ||
                other.isChallengeCompleted == isChallengeCompleted));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      quizId,
      attemptId,
      isCorrect,
      selectedChoiceId,
      correctChoiceId,
      const DeepCollectionEquality().hash(_choiceResults),
      totalAttempts,
      correctRate,
      isChallengeCompleted);

  @override
  String toString() {
    return 'SubmitQuizResponse(quizId: $quizId, attemptId: $attemptId, isCorrect: $isCorrect, selectedChoiceId: $selectedChoiceId, correctChoiceId: $correctChoiceId, choiceResults: $choiceResults, totalAttempts: $totalAttempts, correctRate: $correctRate, isChallengeCompleted: $isChallengeCompleted)';
  }
}

/// @nodoc
abstract mixin class _$SubmitQuizResponseCopyWith<$Res>
    implements $SubmitQuizResponseCopyWith<$Res> {
  factory _$SubmitQuizResponseCopyWith(
          _SubmitQuizResponse value, $Res Function(_SubmitQuizResponse) _then) =
      __$SubmitQuizResponseCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int quizId,
      int attemptId,
      bool isCorrect,
      int selectedChoiceId,
      int correctChoiceId,
      List<ChoiceResult> choiceResults,
      int totalAttempts,
      double correctRate,
      bool isChallengeCompleted});
}

/// @nodoc
class __$SubmitQuizResponseCopyWithImpl<$Res>
    implements _$SubmitQuizResponseCopyWith<$Res> {
  __$SubmitQuizResponseCopyWithImpl(this._self, this._then);

  final _SubmitQuizResponse _self;
  final $Res Function(_SubmitQuizResponse) _then;

  /// Create a copy of SubmitQuizResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? quizId = null,
    Object? attemptId = null,
    Object? isCorrect = null,
    Object? selectedChoiceId = null,
    Object? correctChoiceId = null,
    Object? choiceResults = null,
    Object? totalAttempts = null,
    Object? correctRate = null,
    Object? isChallengeCompleted = null,
  }) {
    return _then(_SubmitQuizResponse(
      quizId: null == quizId
          ? _self.quizId
          : quizId // ignore: cast_nullable_to_non_nullable
              as int,
      attemptId: null == attemptId
          ? _self.attemptId
          : attemptId // ignore: cast_nullable_to_non_nullable
              as int,
      isCorrect: null == isCorrect
          ? _self.isCorrect
          : isCorrect // ignore: cast_nullable_to_non_nullable
              as bool,
      selectedChoiceId: null == selectedChoiceId
          ? _self.selectedChoiceId
          : selectedChoiceId // ignore: cast_nullable_to_non_nullable
              as int,
      correctChoiceId: null == correctChoiceId
          ? _self.correctChoiceId
          : correctChoiceId // ignore: cast_nullable_to_non_nullable
              as int,
      choiceResults: null == choiceResults
          ? _self._choiceResults
          : choiceResults // ignore: cast_nullable_to_non_nullable
              as List<ChoiceResult>,
      totalAttempts: null == totalAttempts
          ? _self.totalAttempts
          : totalAttempts // ignore: cast_nullable_to_non_nullable
              as int,
      correctRate: null == correctRate
          ? _self.correctRate
          : correctRate // ignore: cast_nullable_to_non_nullable
              as double,
      isChallengeCompleted: null == isChallengeCompleted
          ? _self.isChallengeCompleted
          : isChallengeCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
