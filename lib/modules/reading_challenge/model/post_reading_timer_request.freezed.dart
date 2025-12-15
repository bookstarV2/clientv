// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_reading_timer_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PostReadingTimerRequest {
  int get challengeId;
  int get seconds;

  /// Create a copy of PostReadingTimerRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PostReadingTimerRequestCopyWith<PostReadingTimerRequest> get copyWith =>
      _$PostReadingTimerRequestCopyWithImpl<PostReadingTimerRequest>(
          this as PostReadingTimerRequest, _$identity);

  /// Serializes this PostReadingTimerRequest to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PostReadingTimerRequest &&
            (identical(other.challengeId, challengeId) ||
                other.challengeId == challengeId) &&
            (identical(other.seconds, seconds) || other.seconds == seconds));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, challengeId, seconds);

  @override
  String toString() {
    return 'PostReadingTimerRequest(challengeId: $challengeId, seconds: $seconds)';
  }
}

/// @nodoc
abstract mixin class $PostReadingTimerRequestCopyWith<$Res> {
  factory $PostReadingTimerRequestCopyWith(PostReadingTimerRequest value,
          $Res Function(PostReadingTimerRequest) _then) =
      _$PostReadingTimerRequestCopyWithImpl;
  @useResult
  $Res call({int challengeId, int seconds});
}

/// @nodoc
class _$PostReadingTimerRequestCopyWithImpl<$Res>
    implements $PostReadingTimerRequestCopyWith<$Res> {
  _$PostReadingTimerRequestCopyWithImpl(this._self, this._then);

  final PostReadingTimerRequest _self;
  final $Res Function(PostReadingTimerRequest) _then;

  /// Create a copy of PostReadingTimerRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? challengeId = null,
    Object? seconds = null,
  }) {
    return _then(_self.copyWith(
      challengeId: null == challengeId
          ? _self.challengeId
          : challengeId // ignore: cast_nullable_to_non_nullable
              as int,
      seconds: null == seconds
          ? _self.seconds
          : seconds // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [PostReadingTimerRequest].
extension PostReadingTimerRequestPatterns on PostReadingTimerRequest {
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
    TResult Function(_PostReadingTimerRequest value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PostReadingTimerRequest() when $default != null:
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
    TResult Function(_PostReadingTimerRequest value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PostReadingTimerRequest():
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
    TResult? Function(_PostReadingTimerRequest value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PostReadingTimerRequest() when $default != null:
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
    TResult Function(int challengeId, int seconds)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PostReadingTimerRequest() when $default != null:
        return $default(_that.challengeId, _that.seconds);
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
    TResult Function(int challengeId, int seconds) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PostReadingTimerRequest():
        return $default(_that.challengeId, _that.seconds);
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
    TResult? Function(int challengeId, int seconds)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PostReadingTimerRequest() when $default != null:
        return $default(_that.challengeId, _that.seconds);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _PostReadingTimerRequest implements PostReadingTimerRequest {
  const _PostReadingTimerRequest({this.challengeId = -1, this.seconds = -1});
  factory _PostReadingTimerRequest.fromJson(Map<String, dynamic> json) =>
      _$PostReadingTimerRequestFromJson(json);

  @override
  @JsonKey()
  final int challengeId;
  @override
  @JsonKey()
  final int seconds;

  /// Create a copy of PostReadingTimerRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PostReadingTimerRequestCopyWith<_PostReadingTimerRequest> get copyWith =>
      __$PostReadingTimerRequestCopyWithImpl<_PostReadingTimerRequest>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$PostReadingTimerRequestToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PostReadingTimerRequest &&
            (identical(other.challengeId, challengeId) ||
                other.challengeId == challengeId) &&
            (identical(other.seconds, seconds) || other.seconds == seconds));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, challengeId, seconds);

  @override
  String toString() {
    return 'PostReadingTimerRequest(challengeId: $challengeId, seconds: $seconds)';
  }
}

/// @nodoc
abstract mixin class _$PostReadingTimerRequestCopyWith<$Res>
    implements $PostReadingTimerRequestCopyWith<$Res> {
  factory _$PostReadingTimerRequestCopyWith(_PostReadingTimerRequest value,
          $Res Function(_PostReadingTimerRequest) _then) =
      __$PostReadingTimerRequestCopyWithImpl;
  @override
  @useResult
  $Res call({int challengeId, int seconds});
}

/// @nodoc
class __$PostReadingTimerRequestCopyWithImpl<$Res>
    implements _$PostReadingTimerRequestCopyWith<$Res> {
  __$PostReadingTimerRequestCopyWithImpl(this._self, this._then);

  final _PostReadingTimerRequest _self;
  final $Res Function(_PostReadingTimerRequest) _then;

  /// Create a copy of PostReadingTimerRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? challengeId = null,
    Object? seconds = null,
  }) {
    return _then(_PostReadingTimerRequest(
      challengeId: null == challengeId
          ? _self.challengeId
          : challengeId // ignore: cast_nullable_to_non_nullable
              as int,
      seconds: null == seconds
          ? _self.seconds
          : seconds // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on
