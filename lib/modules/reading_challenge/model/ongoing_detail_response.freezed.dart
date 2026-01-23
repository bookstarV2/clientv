// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ongoing_detail_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OngoingDetailResponse {
  int get ongoingCount;
  int get completedCount;
  List<ChallengeResponse> get challenges;

  /// Create a copy of OngoingDetailResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $OngoingDetailResponseCopyWith<OngoingDetailResponse> get copyWith =>
      _$OngoingDetailResponseCopyWithImpl<OngoingDetailResponse>(
          this as OngoingDetailResponse, _$identity);

  /// Serializes this OngoingDetailResponse to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is OngoingDetailResponse &&
            (identical(other.ongoingCount, ongoingCount) ||
                other.ongoingCount == ongoingCount) &&
            (identical(other.completedCount, completedCount) ||
                other.completedCount == completedCount) &&
            const DeepCollectionEquality()
                .equals(other.challenges, challenges));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, ongoingCount, completedCount,
      const DeepCollectionEquality().hash(challenges));

  @override
  String toString() {
    return 'OngoingDetailResponse(ongoingCount: $ongoingCount, completedCount: $completedCount, challenges: $challenges)';
  }
}

/// @nodoc
abstract mixin class $OngoingDetailResponseCopyWith<$Res> {
  factory $OngoingDetailResponseCopyWith(OngoingDetailResponse value,
          $Res Function(OngoingDetailResponse) _then) =
      _$OngoingDetailResponseCopyWithImpl;
  @useResult
  $Res call(
      {int ongoingCount,
      int completedCount,
      List<ChallengeResponse> challenges});
}

/// @nodoc
class _$OngoingDetailResponseCopyWithImpl<$Res>
    implements $OngoingDetailResponseCopyWith<$Res> {
  _$OngoingDetailResponseCopyWithImpl(this._self, this._then);

  final OngoingDetailResponse _self;
  final $Res Function(OngoingDetailResponse) _then;

  /// Create a copy of OngoingDetailResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ongoingCount = null,
    Object? completedCount = null,
    Object? challenges = null,
  }) {
    return _then(_self.copyWith(
      ongoingCount: null == ongoingCount
          ? _self.ongoingCount
          : ongoingCount // ignore: cast_nullable_to_non_nullable
              as int,
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

/// Adds pattern-matching-related methods to [OngoingDetailResponse].
extension OngoingDetailResponsePatterns on OngoingDetailResponse {
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
    TResult Function(_OngoingDetailResponse value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _OngoingDetailResponse() when $default != null:
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
    TResult Function(_OngoingDetailResponse value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OngoingDetailResponse():
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
    TResult? Function(_OngoingDetailResponse value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OngoingDetailResponse() when $default != null:
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
    TResult Function(int ongoingCount, int completedCount,
            List<ChallengeResponse> challenges)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _OngoingDetailResponse() when $default != null:
        return $default(
            _that.ongoingCount, _that.completedCount, _that.challenges);
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
    TResult Function(int ongoingCount, int completedCount,
            List<ChallengeResponse> challenges)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OngoingDetailResponse():
        return $default(
            _that.ongoingCount, _that.completedCount, _that.challenges);
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
    TResult? Function(int ongoingCount, int completedCount,
            List<ChallengeResponse> challenges)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OngoingDetailResponse() when $default != null:
        return $default(
            _that.ongoingCount, _that.completedCount, _that.challenges);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _OngoingDetailResponse implements OngoingDetailResponse {
  const _OngoingDetailResponse(
      {this.ongoingCount = -1,
      this.completedCount = -1,
      final List<ChallengeResponse> challenges = const []})
      : _challenges = challenges;
  factory _OngoingDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$OngoingDetailResponseFromJson(json);

  @override
  @JsonKey()
  final int ongoingCount;
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

  /// Create a copy of OngoingDetailResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$OngoingDetailResponseCopyWith<_OngoingDetailResponse> get copyWith =>
      __$OngoingDetailResponseCopyWithImpl<_OngoingDetailResponse>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$OngoingDetailResponseToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _OngoingDetailResponse &&
            (identical(other.ongoingCount, ongoingCount) ||
                other.ongoingCount == ongoingCount) &&
            (identical(other.completedCount, completedCount) ||
                other.completedCount == completedCount) &&
            const DeepCollectionEquality()
                .equals(other._challenges, _challenges));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, ongoingCount, completedCount,
      const DeepCollectionEquality().hash(_challenges));

  @override
  String toString() {
    return 'OngoingDetailResponse(ongoingCount: $ongoingCount, completedCount: $completedCount, challenges: $challenges)';
  }
}

/// @nodoc
abstract mixin class _$OngoingDetailResponseCopyWith<$Res>
    implements $OngoingDetailResponseCopyWith<$Res> {
  factory _$OngoingDetailResponseCopyWith(_OngoingDetailResponse value,
          $Res Function(_OngoingDetailResponse) _then) =
      __$OngoingDetailResponseCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int ongoingCount,
      int completedCount,
      List<ChallengeResponse> challenges});
}

/// @nodoc
class __$OngoingDetailResponseCopyWithImpl<$Res>
    implements _$OngoingDetailResponseCopyWith<$Res> {
  __$OngoingDetailResponseCopyWithImpl(this._self, this._then);

  final _OngoingDetailResponse _self;
  final $Res Function(_OngoingDetailResponse) _then;

  /// Create a copy of OngoingDetailResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? ongoingCount = null,
    Object? completedCount = null,
    Object? challenges = null,
  }) {
    return _then(_OngoingDetailResponse(
      ongoingCount: null == ongoingCount
          ? _self.ongoingCount
          : ongoingCount // ignore: cast_nullable_to_non_nullable
              as int,
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
