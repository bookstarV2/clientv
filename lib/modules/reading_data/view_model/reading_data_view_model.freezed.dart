// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reading_data_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReadingDataState {
  RankingWeeklyTop3Response? get top1;
  RankingWeeklyTop3Response? get top2;
  RankingWeeklyTop3Response? get top3;

  /// Create a copy of ReadingDataState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ReadingDataStateCopyWith<ReadingDataState> get copyWith =>
      _$ReadingDataStateCopyWithImpl<ReadingDataState>(
          this as ReadingDataState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ReadingDataState &&
            (identical(other.top1, top1) || other.top1 == top1) &&
            (identical(other.top2, top2) || other.top2 == top2) &&
            (identical(other.top3, top3) || other.top3 == top3));
  }

  @override
  int get hashCode => Object.hash(runtimeType, top1, top2, top3);

  @override
  String toString() {
    return 'ReadingDataState(top1: $top1, top2: $top2, top3: $top3)';
  }
}

/// @nodoc
abstract mixin class $ReadingDataStateCopyWith<$Res> {
  factory $ReadingDataStateCopyWith(
          ReadingDataState value, $Res Function(ReadingDataState) _then) =
      _$ReadingDataStateCopyWithImpl;
  @useResult
  $Res call(
      {RankingWeeklyTop3Response? top1,
      RankingWeeklyTop3Response? top2,
      RankingWeeklyTop3Response? top3});

  $RankingWeeklyTop3ResponseCopyWith<$Res>? get top1;
  $RankingWeeklyTop3ResponseCopyWith<$Res>? get top2;
  $RankingWeeklyTop3ResponseCopyWith<$Res>? get top3;
}

/// @nodoc
class _$ReadingDataStateCopyWithImpl<$Res>
    implements $ReadingDataStateCopyWith<$Res> {
  _$ReadingDataStateCopyWithImpl(this._self, this._then);

  final ReadingDataState _self;
  final $Res Function(ReadingDataState) _then;

  /// Create a copy of ReadingDataState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? top1 = freezed,
    Object? top2 = freezed,
    Object? top3 = freezed,
  }) {
    return _then(_self.copyWith(
      top1: freezed == top1
          ? _self.top1
          : top1 // ignore: cast_nullable_to_non_nullable
              as RankingWeeklyTop3Response?,
      top2: freezed == top2
          ? _self.top2
          : top2 // ignore: cast_nullable_to_non_nullable
              as RankingWeeklyTop3Response?,
      top3: freezed == top3
          ? _self.top3
          : top3 // ignore: cast_nullable_to_non_nullable
              as RankingWeeklyTop3Response?,
    ));
  }

  /// Create a copy of ReadingDataState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RankingWeeklyTop3ResponseCopyWith<$Res>? get top1 {
    if (_self.top1 == null) {
      return null;
    }

    return $RankingWeeklyTop3ResponseCopyWith<$Res>(_self.top1!, (value) {
      return _then(_self.copyWith(top1: value));
    });
  }

  /// Create a copy of ReadingDataState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RankingWeeklyTop3ResponseCopyWith<$Res>? get top2 {
    if (_self.top2 == null) {
      return null;
    }

    return $RankingWeeklyTop3ResponseCopyWith<$Res>(_self.top2!, (value) {
      return _then(_self.copyWith(top2: value));
    });
  }

  /// Create a copy of ReadingDataState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RankingWeeklyTop3ResponseCopyWith<$Res>? get top3 {
    if (_self.top3 == null) {
      return null;
    }

    return $RankingWeeklyTop3ResponseCopyWith<$Res>(_self.top3!, (value) {
      return _then(_self.copyWith(top3: value));
    });
  }
}

/// Adds pattern-matching-related methods to [ReadingDataState].
extension ReadingDataStatePatterns on ReadingDataState {
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
    TResult Function(_ReadingDataState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ReadingDataState() when $default != null:
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
    TResult Function(_ReadingDataState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ReadingDataState():
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
    TResult? Function(_ReadingDataState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ReadingDataState() when $default != null:
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
    TResult Function(RankingWeeklyTop3Response? top1,
            RankingWeeklyTop3Response? top2, RankingWeeklyTop3Response? top3)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ReadingDataState() when $default != null:
        return $default(_that.top1, _that.top2, _that.top3);
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
    TResult Function(RankingWeeklyTop3Response? top1,
            RankingWeeklyTop3Response? top2, RankingWeeklyTop3Response? top3)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ReadingDataState():
        return $default(_that.top1, _that.top2, _that.top3);
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
    TResult? Function(RankingWeeklyTop3Response? top1,
            RankingWeeklyTop3Response? top2, RankingWeeklyTop3Response? top3)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ReadingDataState() when $default != null:
        return $default(_that.top1, _that.top2, _that.top3);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _ReadingDataState implements ReadingDataState {
  const _ReadingDataState(
      {this.top1 = null, this.top2 = null, this.top3 = null});

  @override
  @JsonKey()
  final RankingWeeklyTop3Response? top1;
  @override
  @JsonKey()
  final RankingWeeklyTop3Response? top2;
  @override
  @JsonKey()
  final RankingWeeklyTop3Response? top3;

  /// Create a copy of ReadingDataState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ReadingDataStateCopyWith<_ReadingDataState> get copyWith =>
      __$ReadingDataStateCopyWithImpl<_ReadingDataState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ReadingDataState &&
            (identical(other.top1, top1) || other.top1 == top1) &&
            (identical(other.top2, top2) || other.top2 == top2) &&
            (identical(other.top3, top3) || other.top3 == top3));
  }

  @override
  int get hashCode => Object.hash(runtimeType, top1, top2, top3);

  @override
  String toString() {
    return 'ReadingDataState(top1: $top1, top2: $top2, top3: $top3)';
  }
}

/// @nodoc
abstract mixin class _$ReadingDataStateCopyWith<$Res>
    implements $ReadingDataStateCopyWith<$Res> {
  factory _$ReadingDataStateCopyWith(
          _ReadingDataState value, $Res Function(_ReadingDataState) _then) =
      __$ReadingDataStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {RankingWeeklyTop3Response? top1,
      RankingWeeklyTop3Response? top2,
      RankingWeeklyTop3Response? top3});

  @override
  $RankingWeeklyTop3ResponseCopyWith<$Res>? get top1;
  @override
  $RankingWeeklyTop3ResponseCopyWith<$Res>? get top2;
  @override
  $RankingWeeklyTop3ResponseCopyWith<$Res>? get top3;
}

/// @nodoc
class __$ReadingDataStateCopyWithImpl<$Res>
    implements _$ReadingDataStateCopyWith<$Res> {
  __$ReadingDataStateCopyWithImpl(this._self, this._then);

  final _ReadingDataState _self;
  final $Res Function(_ReadingDataState) _then;

  /// Create a copy of ReadingDataState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? top1 = freezed,
    Object? top2 = freezed,
    Object? top3 = freezed,
  }) {
    return _then(_ReadingDataState(
      top1: freezed == top1
          ? _self.top1
          : top1 // ignore: cast_nullable_to_non_nullable
              as RankingWeeklyTop3Response?,
      top2: freezed == top2
          ? _self.top2
          : top2 // ignore: cast_nullable_to_non_nullable
              as RankingWeeklyTop3Response?,
      top3: freezed == top3
          ? _self.top3
          : top3 // ignore: cast_nullable_to_non_nullable
              as RankingWeeklyTop3Response?,
    ));
  }

  /// Create a copy of ReadingDataState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RankingWeeklyTop3ResponseCopyWith<$Res>? get top1 {
    if (_self.top1 == null) {
      return null;
    }

    return $RankingWeeklyTop3ResponseCopyWith<$Res>(_self.top1!, (value) {
      return _then(_self.copyWith(top1: value));
    });
  }

  /// Create a copy of ReadingDataState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RankingWeeklyTop3ResponseCopyWith<$Res>? get top2 {
    if (_self.top2 == null) {
      return null;
    }

    return $RankingWeeklyTop3ResponseCopyWith<$Res>(_self.top2!, (value) {
      return _then(_self.copyWith(top2: value));
    });
  }

  /// Create a copy of ReadingDataState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RankingWeeklyTop3ResponseCopyWith<$Res>? get top3 {
    if (_self.top3 == null) {
      return null;
    }

    return $RankingWeeklyTop3ResponseCopyWith<$Res>(_self.top3!, (value) {
      return _then(_self.copyWith(top3: value));
    });
  }
}

// dart format on
