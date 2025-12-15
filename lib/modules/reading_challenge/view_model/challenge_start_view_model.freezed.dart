// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'challenge_start_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChallengeStartState {
  ChallengeDetailResponse get detail;

  /// Create a copy of ChallengeStartState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ChallengeStartStateCopyWith<ChallengeStartState> get copyWith =>
      _$ChallengeStartStateCopyWithImpl<ChallengeStartState>(
          this as ChallengeStartState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ChallengeStartState &&
            (identical(other.detail, detail) || other.detail == detail));
  }

  @override
  int get hashCode => Object.hash(runtimeType, detail);

  @override
  String toString() {
    return 'ChallengeStartState(detail: $detail)';
  }
}

/// @nodoc
abstract mixin class $ChallengeStartStateCopyWith<$Res> {
  factory $ChallengeStartStateCopyWith(
          ChallengeStartState value, $Res Function(ChallengeStartState) _then) =
      _$ChallengeStartStateCopyWithImpl;
  @useResult
  $Res call({ChallengeDetailResponse detail});

  $ChallengeDetailResponseCopyWith<$Res> get detail;
}

/// @nodoc
class _$ChallengeStartStateCopyWithImpl<$Res>
    implements $ChallengeStartStateCopyWith<$Res> {
  _$ChallengeStartStateCopyWithImpl(this._self, this._then);

  final ChallengeStartState _self;
  final $Res Function(ChallengeStartState) _then;

  /// Create a copy of ChallengeStartState
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
              as ChallengeDetailResponse,
    ));
  }

  /// Create a copy of ChallengeStartState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ChallengeDetailResponseCopyWith<$Res> get detail {
    return $ChallengeDetailResponseCopyWith<$Res>(_self.detail, (value) {
      return _then(_self.copyWith(detail: value));
    });
  }
}

/// Adds pattern-matching-related methods to [ChallengeStartState].
extension ChallengeStartStatePatterns on ChallengeStartState {
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
    TResult Function(_ChallengeStartState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ChallengeStartState() when $default != null:
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
    TResult Function(_ChallengeStartState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChallengeStartState():
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
    TResult? Function(_ChallengeStartState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChallengeStartState() when $default != null:
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
    TResult Function(ChallengeDetailResponse detail)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ChallengeStartState() when $default != null:
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
    TResult Function(ChallengeDetailResponse detail) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChallengeStartState():
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
    TResult? Function(ChallengeDetailResponse detail)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChallengeStartState() when $default != null:
        return $default(_that.detail);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _ChallengeStartState implements ChallengeStartState {
  const _ChallengeStartState({this.detail = const ChallengeDetailResponse()});

  @override
  @JsonKey()
  final ChallengeDetailResponse detail;

  /// Create a copy of ChallengeStartState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ChallengeStartStateCopyWith<_ChallengeStartState> get copyWith =>
      __$ChallengeStartStateCopyWithImpl<_ChallengeStartState>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ChallengeStartState &&
            (identical(other.detail, detail) || other.detail == detail));
  }

  @override
  int get hashCode => Object.hash(runtimeType, detail);

  @override
  String toString() {
    return 'ChallengeStartState(detail: $detail)';
  }
}

/// @nodoc
abstract mixin class _$ChallengeStartStateCopyWith<$Res>
    implements $ChallengeStartStateCopyWith<$Res> {
  factory _$ChallengeStartStateCopyWith(_ChallengeStartState value,
          $Res Function(_ChallengeStartState) _then) =
      __$ChallengeStartStateCopyWithImpl;
  @override
  @useResult
  $Res call({ChallengeDetailResponse detail});

  @override
  $ChallengeDetailResponseCopyWith<$Res> get detail;
}

/// @nodoc
class __$ChallengeStartStateCopyWithImpl<$Res>
    implements _$ChallengeStartStateCopyWith<$Res> {
  __$ChallengeStartStateCopyWithImpl(this._self, this._then);

  final _ChallengeStartState _self;
  final $Res Function(_ChallengeStartState) _then;

  /// Create a copy of ChallengeStartState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? detail = null,
  }) {
    return _then(_ChallengeStartState(
      detail: null == detail
          ? _self.detail
          : detail // ignore: cast_nullable_to_non_nullable
              as ChallengeDetailResponse,
    ));
  }

  /// Create a copy of ChallengeStartState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ChallengeDetailResponseCopyWith<$Res> get detail {
    return $ChallengeDetailResponseCopyWith<$Res>(_self.detail, (value) {
      return _then(_self.copyWith(detail: value));
    });
  }
}

// dart format on
