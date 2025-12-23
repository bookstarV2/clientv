// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_challenge_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreateChallengeResponse {
  int get challengeId;
  QuizGenerationStatus get quizGenerationStatus;
  bool get alreadyExists;
  bool get hasChapter;

  /// Create a copy of CreateChallengeResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CreateChallengeResponseCopyWith<CreateChallengeResponse> get copyWith =>
      _$CreateChallengeResponseCopyWithImpl<CreateChallengeResponse>(
          this as CreateChallengeResponse, _$identity);

  /// Serializes this CreateChallengeResponse to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CreateChallengeResponse &&
            (identical(other.challengeId, challengeId) ||
                other.challengeId == challengeId) &&
            (identical(other.quizGenerationStatus, quizGenerationStatus) ||
                other.quizGenerationStatus == quizGenerationStatus) &&
            (identical(other.alreadyExists, alreadyExists) ||
                other.alreadyExists == alreadyExists) &&
            (identical(other.hasChapter, hasChapter) ||
                other.hasChapter == hasChapter));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, challengeId,
      quizGenerationStatus, alreadyExists, hasChapter);

  @override
  String toString() {
    return 'CreateChallengeResponse(challengeId: $challengeId, quizGenerationStatus: $quizGenerationStatus, alreadyExists: $alreadyExists, hasChapter: $hasChapter)';
  }
}

/// @nodoc
abstract mixin class $CreateChallengeResponseCopyWith<$Res> {
  factory $CreateChallengeResponseCopyWith(CreateChallengeResponse value,
          $Res Function(CreateChallengeResponse) _then) =
      _$CreateChallengeResponseCopyWithImpl;
  @useResult
  $Res call(
      {int challengeId,
      QuizGenerationStatus quizGenerationStatus,
      bool alreadyExists,
      bool hasChapter});
}

/// @nodoc
class _$CreateChallengeResponseCopyWithImpl<$Res>
    implements $CreateChallengeResponseCopyWith<$Res> {
  _$CreateChallengeResponseCopyWithImpl(this._self, this._then);

  final CreateChallengeResponse _self;
  final $Res Function(CreateChallengeResponse) _then;

  /// Create a copy of CreateChallengeResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? challengeId = null,
    Object? quizGenerationStatus = null,
    Object? alreadyExists = null,
    Object? hasChapter = null,
  }) {
    return _then(_self.copyWith(
      challengeId: null == challengeId
          ? _self.challengeId
          : challengeId // ignore: cast_nullable_to_non_nullable
              as int,
      quizGenerationStatus: null == quizGenerationStatus
          ? _self.quizGenerationStatus
          : quizGenerationStatus // ignore: cast_nullable_to_non_nullable
              as QuizGenerationStatus,
      alreadyExists: null == alreadyExists
          ? _self.alreadyExists
          : alreadyExists // ignore: cast_nullable_to_non_nullable
              as bool,
      hasChapter: null == hasChapter
          ? _self.hasChapter
          : hasChapter // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [CreateChallengeResponse].
extension CreateChallengeResponsePatterns on CreateChallengeResponse {
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
    TResult Function(_CreateChallengeResponse value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CreateChallengeResponse() when $default != null:
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
    TResult Function(_CreateChallengeResponse value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CreateChallengeResponse():
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
    TResult? Function(_CreateChallengeResponse value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CreateChallengeResponse() when $default != null:
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
    TResult Function(int challengeId, QuizGenerationStatus quizGenerationStatus,
            bool alreadyExists, bool hasChapter)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CreateChallengeResponse() when $default != null:
        return $default(_that.challengeId, _that.quizGenerationStatus,
            _that.alreadyExists, _that.hasChapter);
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
    TResult Function(int challengeId, QuizGenerationStatus quizGenerationStatus,
            bool alreadyExists, bool hasChapter)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CreateChallengeResponse():
        return $default(_that.challengeId, _that.quizGenerationStatus,
            _that.alreadyExists, _that.hasChapter);
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
            QuizGenerationStatus quizGenerationStatus,
            bool alreadyExists,
            bool hasChapter)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CreateChallengeResponse() when $default != null:
        return $default(_that.challengeId, _that.quizGenerationStatus,
            _that.alreadyExists, _that.hasChapter);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _CreateChallengeResponse implements CreateChallengeResponse {
  const _CreateChallengeResponse(
      {this.challengeId = -1,
      this.quizGenerationStatus = QuizGenerationStatus.PENDING,
      this.alreadyExists = false,
      this.hasChapter = false});
  factory _CreateChallengeResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateChallengeResponseFromJson(json);

  @override
  @JsonKey()
  final int challengeId;
  @override
  @JsonKey()
  final QuizGenerationStatus quizGenerationStatus;
  @override
  @JsonKey()
  final bool alreadyExists;
  @override
  @JsonKey()
  final bool hasChapter;

  /// Create a copy of CreateChallengeResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CreateChallengeResponseCopyWith<_CreateChallengeResponse> get copyWith =>
      __$CreateChallengeResponseCopyWithImpl<_CreateChallengeResponse>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$CreateChallengeResponseToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CreateChallengeResponse &&
            (identical(other.challengeId, challengeId) ||
                other.challengeId == challengeId) &&
            (identical(other.quizGenerationStatus, quizGenerationStatus) ||
                other.quizGenerationStatus == quizGenerationStatus) &&
            (identical(other.alreadyExists, alreadyExists) ||
                other.alreadyExists == alreadyExists) &&
            (identical(other.hasChapter, hasChapter) ||
                other.hasChapter == hasChapter));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, challengeId,
      quizGenerationStatus, alreadyExists, hasChapter);

  @override
  String toString() {
    return 'CreateChallengeResponse(challengeId: $challengeId, quizGenerationStatus: $quizGenerationStatus, alreadyExists: $alreadyExists, hasChapter: $hasChapter)';
  }
}

/// @nodoc
abstract mixin class _$CreateChallengeResponseCopyWith<$Res>
    implements $CreateChallengeResponseCopyWith<$Res> {
  factory _$CreateChallengeResponseCopyWith(_CreateChallengeResponse value,
          $Res Function(_CreateChallengeResponse) _then) =
      __$CreateChallengeResponseCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int challengeId,
      QuizGenerationStatus quizGenerationStatus,
      bool alreadyExists,
      bool hasChapter});
}

/// @nodoc
class __$CreateChallengeResponseCopyWithImpl<$Res>
    implements _$CreateChallengeResponseCopyWith<$Res> {
  __$CreateChallengeResponseCopyWithImpl(this._self, this._then);

  final _CreateChallengeResponse _self;
  final $Res Function(_CreateChallengeResponse) _then;

  /// Create a copy of CreateChallengeResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? challengeId = null,
    Object? quizGenerationStatus = null,
    Object? alreadyExists = null,
    Object? hasChapter = null,
  }) {
    return _then(_CreateChallengeResponse(
      challengeId: null == challengeId
          ? _self.challengeId
          : challengeId // ignore: cast_nullable_to_non_nullable
              as int,
      quizGenerationStatus: null == quizGenerationStatus
          ? _self.quizGenerationStatus
          : quizGenerationStatus // ignore: cast_nullable_to_non_nullable
              as QuizGenerationStatus,
      alreadyExists: null == alreadyExists
          ? _self.alreadyExists
          : alreadyExists // ignore: cast_nullable_to_non_nullable
              as bool,
      hasChapter: null == hasChapter
          ? _self.hasChapter
          : hasChapter // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
