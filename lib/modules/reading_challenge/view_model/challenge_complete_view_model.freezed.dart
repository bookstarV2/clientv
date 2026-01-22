// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'challenge_complete_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChallengeCompleteState {
  ChallengeSuccessDetailResponse get detail;

  /// Create a copy of ChallengeCompleteState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ChallengeCompleteStateCopyWith<ChallengeCompleteState> get copyWith =>
      _$ChallengeCompleteStateCopyWithImpl<ChallengeCompleteState>(
          this as ChallengeCompleteState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ChallengeCompleteState &&
            (identical(other.detail, detail) || other.detail == detail));
  }

  @override
  int get hashCode => Object.hash(runtimeType, detail);

  @override
  String toString() {
    return 'ChallengeCompleteState(detail: $detail)';
  }
}

/// @nodoc
abstract mixin class $ChallengeCompleteStateCopyWith<$Res> {
  factory $ChallengeCompleteStateCopyWith(ChallengeCompleteState value,
          $Res Function(ChallengeCompleteState) _then) =
      _$ChallengeCompleteStateCopyWithImpl;
  @useResult
  $Res call({ChallengeSuccessDetailResponse detail});

  $ChallengeSuccessDetailResponseCopyWith<$Res> get detail;
}

/// @nodoc
class _$ChallengeCompleteStateCopyWithImpl<$Res>
    implements $ChallengeCompleteStateCopyWith<$Res> {
  _$ChallengeCompleteStateCopyWithImpl(this._self, this._then);

  final ChallengeCompleteState _self;
  final $Res Function(ChallengeCompleteState) _then;

  /// Create a copy of ChallengeCompleteState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? detail = null,
  }) {
    return _then(_self.copyWith(
      detail: null == detail
          ? _self.detail
          : detail // ignore: cast_nullable_to_non_nullable
              as ChallengeSuccessDetailResponse,
    ));
  }

  /// Create a copy of ChallengeCompleteState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ChallengeSuccessDetailResponseCopyWith<$Res> get detail {
    return $ChallengeSuccessDetailResponseCopyWith<$Res>(_self.detail, (value) {
      return _then(_self.copyWith(detail: value));
    });
  }
}

/// Adds pattern-matching-related methods to [ChallengeCompleteState].
extension ChallengeCompleteStatePatterns on ChallengeCompleteState {
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
    TResult Function(_ChallengeCompleteState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ChallengeCompleteState() when $default != null:
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
    TResult Function(_ChallengeCompleteState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChallengeCompleteState():
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
    TResult? Function(_ChallengeCompleteState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChallengeCompleteState() when $default != null:
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
    TResult Function(ChallengeSuccessDetailResponse detail)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ChallengeCompleteState() when $default != null:
        return $default(_that.detail);
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
    TResult Function(ChallengeSuccessDetailResponse detail) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChallengeCompleteState():
        return $default(_that.detail);
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
    TResult? Function(ChallengeSuccessDetailResponse detail)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChallengeCompleteState() when $default != null:
        return $default(_that.detail);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _ChallengeCompleteState implements ChallengeCompleteState {
  const _ChallengeCompleteState(
      {this.detail = const ChallengeSuccessDetailResponse()});

  @override
  @JsonKey()
  final ChallengeSuccessDetailResponse detail;

  /// Create a copy of ChallengeCompleteState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ChallengeCompleteStateCopyWith<_ChallengeCompleteState> get copyWith =>
      __$ChallengeCompleteStateCopyWithImpl<_ChallengeCompleteState>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ChallengeCompleteState &&
            (identical(other.detail, detail) || other.detail == detail));
  }

  @override
  int get hashCode => Object.hash(runtimeType, detail);

  @override
  String toString() {
    return 'ChallengeCompleteState(detail: $detail)';
  }
}

/// @nodoc
abstract mixin class _$ChallengeCompleteStateCopyWith<$Res>
    implements $ChallengeCompleteStateCopyWith<$Res> {
  factory _$ChallengeCompleteStateCopyWith(_ChallengeCompleteState value,
          $Res Function(_ChallengeCompleteState) _then) =
      __$ChallengeCompleteStateCopyWithImpl;
  @override
  @useResult
  $Res call({ChallengeSuccessDetailResponse detail});

  @override
  $ChallengeSuccessDetailResponseCopyWith<$Res> get detail;
}

/// @nodoc
class __$ChallengeCompleteStateCopyWithImpl<$Res>
    implements _$ChallengeCompleteStateCopyWith<$Res> {
  __$ChallengeCompleteStateCopyWithImpl(this._self, this._then);

  final _ChallengeCompleteState _self;
  final $Res Function(_ChallengeCompleteState) _then;

  /// Create a copy of ChallengeCompleteState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? detail = null,
  }) {
    return _then(_ChallengeCompleteState(
      detail: null == detail
          ? _self.detail
          : detail // ignore: cast_nullable_to_non_nullable
              as ChallengeSuccessDetailResponse,
    ));
  }

  /// Create a copy of ChallengeCompleteState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ChallengeSuccessDetailResponseCopyWith<$Res> get detail {
    return $ChallengeSuccessDetailResponseCopyWith<$Res>(_self.detail, (value) {
      return _then(_self.copyWith(detail: value));
    });
  }
}

// dart format on
