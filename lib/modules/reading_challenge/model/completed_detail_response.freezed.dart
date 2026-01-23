// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'completed_detail_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CompletedDetailResponse {
  int get completedCount;
  List<ChallengeResponse> get challenges;

  /// Create a copy of CompletedDetailResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CompletedDetailResponseCopyWith<CompletedDetailResponse> get copyWith =>
      _$CompletedDetailResponseCopyWithImpl<CompletedDetailResponse>(
          this as CompletedDetailResponse, _$identity);

  /// Serializes this CompletedDetailResponse to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CompletedDetailResponse &&
            (identical(other.completedCount, completedCount) ||
                other.completedCount == completedCount) &&
            const DeepCollectionEquality()
                .equals(other.challenges, challenges));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, completedCount,
      const DeepCollectionEquality().hash(challenges));

  @override
  String toString() {
    return 'CompletedDetailResponse(completedCount: $completedCount, challenges: $challenges)';
  }
}

/// @nodoc
abstract mixin class $CompletedDetailResponseCopyWith<$Res> {
  factory $CompletedDetailResponseCopyWith(CompletedDetailResponse value,
          $Res Function(CompletedDetailResponse) _then) =
      _$CompletedDetailResponseCopyWithImpl;
  @useResult
  $Res call({int completedCount, List<ChallengeResponse> challenges});
}

/// @nodoc
class _$CompletedDetailResponseCopyWithImpl<$Res>
    implements $CompletedDetailResponseCopyWith<$Res> {
  _$CompletedDetailResponseCopyWithImpl(this._self, this._then);

  final CompletedDetailResponse _self;
  final $Res Function(CompletedDetailResponse) _then;

  /// Create a copy of CompletedDetailResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? completedCount = null,
    Object? challenges = null,
  }) {
    return _then(_self.copyWith(
      completedCount: null == completedCount
          ? _self.completedCount
          : completedCount // ignore: cast_nullable_to_non_nullable
              as int,
      challenges: null == challenges
          ? _self.challenges
          : challenges // ignore: cast_nullable_to_non_nullable
              as List<ChallengeResponse>,
    ));
  }
}

/// Adds pattern-matching-related methods to [CompletedDetailResponse].
extension CompletedDetailResponsePatterns on CompletedDetailResponse {
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
    TResult Function(_CompletedDetailResponse value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CompletedDetailResponse() when $default != null:
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
    TResult Function(_CompletedDetailResponse value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CompletedDetailResponse():
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
    TResult? Function(_CompletedDetailResponse value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CompletedDetailResponse() when $default != null:
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
    TResult Function(int completedCount, List<ChallengeResponse> challenges)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CompletedDetailResponse() when $default != null:
        return $default(_that.completedCount, _that.challenges);
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
    TResult Function(int completedCount, List<ChallengeResponse> challenges)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CompletedDetailResponse():
        return $default(_that.completedCount, _that.challenges);
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
    TResult? Function(int completedCount, List<ChallengeResponse> challenges)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CompletedDetailResponse() when $default != null:
        return $default(_that.completedCount, _that.challenges);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _CompletedDetailResponse implements CompletedDetailResponse {
  const _CompletedDetailResponse(
      {this.completedCount = -1,
      final List<ChallengeResponse> challenges = const []})
      : _challenges = challenges;
  factory _CompletedDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$CompletedDetailResponseFromJson(json);

  @override
  @JsonKey()
  final int completedCount;
  final List<ChallengeResponse> _challenges;
  @override
  @JsonKey()
  List<ChallengeResponse> get challenges {
    if (_challenges is EqualUnmodifiableListView) return _challenges;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_challenges);
  }

  /// Create a copy of CompletedDetailResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CompletedDetailResponseCopyWith<_CompletedDetailResponse> get copyWith =>
      __$CompletedDetailResponseCopyWithImpl<_CompletedDetailResponse>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$CompletedDetailResponseToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CompletedDetailResponse &&
            (identical(other.completedCount, completedCount) ||
                other.completedCount == completedCount) &&
            const DeepCollectionEquality()
                .equals(other._challenges, _challenges));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, completedCount,
      const DeepCollectionEquality().hash(_challenges));

  @override
  String toString() {
    return 'CompletedDetailResponse(completedCount: $completedCount, challenges: $challenges)';
  }
}

/// @nodoc
abstract mixin class _$CompletedDetailResponseCopyWith<$Res>
    implements $CompletedDetailResponseCopyWith<$Res> {
  factory _$CompletedDetailResponseCopyWith(_CompletedDetailResponse value,
          $Res Function(_CompletedDetailResponse) _then) =
      __$CompletedDetailResponseCopyWithImpl;
  @override
  @useResult
  $Res call({int completedCount, List<ChallengeResponse> challenges});
}

/// @nodoc
class __$CompletedDetailResponseCopyWithImpl<$Res>
    implements _$CompletedDetailResponseCopyWith<$Res> {
  __$CompletedDetailResponseCopyWithImpl(this._self, this._then);

  final _CompletedDetailResponse _self;
  final $Res Function(_CompletedDetailResponse) _then;

  /// Create a copy of CompletedDetailResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? completedCount = null,
    Object? challenges = null,
  }) {
    return _then(_CompletedDetailResponse(
      completedCount: null == completedCount
          ? _self.completedCount
          : completedCount // ignore: cast_nullable_to_non_nullable
              as int,
      challenges: null == challenges
          ? _self._challenges
          : challenges // ignore: cast_nullable_to_non_nullable
              as List<ChallengeResponse>,
    ));
  }
}

// dart format on
