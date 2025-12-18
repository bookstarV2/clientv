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
  RankingWeeklyResponse? get top1;
  RankingWeeklyResponse? get top2;
  RankingWeeklyResponse? get top3;
  List<RankingWeeklyResponse> get list;
  RankingWeeklyResponse get my;

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
            (identical(other.top3, top3) || other.top3 == top3) &&
            const DeepCollectionEquality().equals(other.list, list) &&
            (identical(other.my, my) || other.my == my));
  }

  @override
  int get hashCode => Object.hash(runtimeType, top1, top2, top3,
      const DeepCollectionEquality().hash(list), my);

  @override
  String toString() {
    return 'ReadingDataState(top1: $top1, top2: $top2, top3: $top3, list: $list, my: $my)';
  }
}

/// @nodoc
abstract mixin class $ReadingDataStateCopyWith<$Res> {
  factory $ReadingDataStateCopyWith(
          ReadingDataState value, $Res Function(ReadingDataState) _then) =
      _$ReadingDataStateCopyWithImpl;
  @useResult
  $Res call(
      {RankingWeeklyResponse? top1,
      RankingWeeklyResponse? top2,
      RankingWeeklyResponse? top3,
      List<RankingWeeklyResponse> list,
      RankingWeeklyResponse my});

  $RankingWeeklyResponseCopyWith<$Res>? get top1;
  $RankingWeeklyResponseCopyWith<$Res>? get top2;
  $RankingWeeklyResponseCopyWith<$Res>? get top3;
  $RankingWeeklyResponseCopyWith<$Res> get my;
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
    Object? list = null,
    Object? my = null,
  }) {
    return _then(_self.copyWith(
      top1: freezed == top1
          ? _self.top1
          : top1 // ignore: cast_nullable_to_non_nullable
              as RankingWeeklyResponse?,
      top2: freezed == top2
          ? _self.top2
          : top2 // ignore: cast_nullable_to_non_nullable
              as RankingWeeklyResponse?,
      top3: freezed == top3
          ? _self.top3
          : top3 // ignore: cast_nullable_to_non_nullable
              as RankingWeeklyResponse?,
      list: null == list
          ? _self.list
          : list // ignore: cast_nullable_to_non_nullable
              as List<RankingWeeklyResponse>,
      my: null == my
          ? _self.my
          : my // ignore: cast_nullable_to_non_nullable
              as RankingWeeklyResponse,
    ));
  }

  /// Create a copy of ReadingDataState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RankingWeeklyResponseCopyWith<$Res>? get top1 {
    if (_self.top1 == null) {
      return null;
    }

    return $RankingWeeklyResponseCopyWith<$Res>(_self.top1!, (value) {
      return _then(_self.copyWith(top1: value));
    });
  }

  /// Create a copy of ReadingDataState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RankingWeeklyResponseCopyWith<$Res>? get top2 {
    if (_self.top2 == null) {
      return null;
    }

    return $RankingWeeklyResponseCopyWith<$Res>(_self.top2!, (value) {
      return _then(_self.copyWith(top2: value));
    });
  }

  /// Create a copy of ReadingDataState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RankingWeeklyResponseCopyWith<$Res>? get top3 {
    if (_self.top3 == null) {
      return null;
    }

    return $RankingWeeklyResponseCopyWith<$Res>(_self.top3!, (value) {
      return _then(_self.copyWith(top3: value));
    });
  }

  /// Create a copy of ReadingDataState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RankingWeeklyResponseCopyWith<$Res> get my {
    return $RankingWeeklyResponseCopyWith<$Res>(_self.my, (value) {
      return _then(_self.copyWith(my: value));
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
    TResult Function(
            RankingWeeklyResponse? top1,
            RankingWeeklyResponse? top2,
            RankingWeeklyResponse? top3,
            List<RankingWeeklyResponse> list,
            RankingWeeklyResponse my)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ReadingDataState() when $default != null:
        return $default(
            _that.top1, _that.top2, _that.top3, _that.list, _that.my);
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
            RankingWeeklyResponse? top1,
            RankingWeeklyResponse? top2,
            RankingWeeklyResponse? top3,
            List<RankingWeeklyResponse> list,
            RankingWeeklyResponse my)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ReadingDataState():
        return $default(
            _that.top1, _that.top2, _that.top3, _that.list, _that.my);
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
            RankingWeeklyResponse? top1,
            RankingWeeklyResponse? top2,
            RankingWeeklyResponse? top3,
            List<RankingWeeklyResponse> list,
            RankingWeeklyResponse my)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ReadingDataState() when $default != null:
        return $default(
            _that.top1, _that.top2, _that.top3, _that.list, _that.my);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _ReadingDataState implements ReadingDataState {
  const _ReadingDataState(
      {this.top1 = null,
      this.top2 = null,
      this.top3 = null,
      final List<RankingWeeklyResponse> list = const [],
      this.my = const RankingWeeklyResponse()})
      : _list = list;

  @override
  @JsonKey()
  final RankingWeeklyResponse? top1;
  @override
  @JsonKey()
  final RankingWeeklyResponse? top2;
  @override
  @JsonKey()
  final RankingWeeklyResponse? top3;
  final List<RankingWeeklyResponse> _list;
  @override
  @JsonKey()
  List<RankingWeeklyResponse> get list {
    if (_list is EqualUnmodifiableListView) return _list;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_list);
  }

  @override
  @JsonKey()
  final RankingWeeklyResponse my;

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
            (identical(other.top3, top3) || other.top3 == top3) &&
            const DeepCollectionEquality().equals(other._list, _list) &&
            (identical(other.my, my) || other.my == my));
  }

  @override
  int get hashCode => Object.hash(runtimeType, top1, top2, top3,
      const DeepCollectionEquality().hash(_list), my);

  @override
  String toString() {
    return 'ReadingDataState(top1: $top1, top2: $top2, top3: $top3, list: $list, my: $my)';
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
      {RankingWeeklyResponse? top1,
      RankingWeeklyResponse? top2,
      RankingWeeklyResponse? top3,
      List<RankingWeeklyResponse> list,
      RankingWeeklyResponse my});

  @override
  $RankingWeeklyResponseCopyWith<$Res>? get top1;
  @override
  $RankingWeeklyResponseCopyWith<$Res>? get top2;
  @override
  $RankingWeeklyResponseCopyWith<$Res>? get top3;
  @override
  $RankingWeeklyResponseCopyWith<$Res> get my;
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
    Object? list = null,
    Object? my = null,
  }) {
    return _then(_ReadingDataState(
      top1: freezed == top1
          ? _self.top1
          : top1 // ignore: cast_nullable_to_non_nullable
              as RankingWeeklyResponse?,
      top2: freezed == top2
          ? _self.top2
          : top2 // ignore: cast_nullable_to_non_nullable
              as RankingWeeklyResponse?,
      top3: freezed == top3
          ? _self.top3
          : top3 // ignore: cast_nullable_to_non_nullable
              as RankingWeeklyResponse?,
      list: null == list
          ? _self._list
          : list // ignore: cast_nullable_to_non_nullable
              as List<RankingWeeklyResponse>,
      my: null == my
          ? _self.my
          : my // ignore: cast_nullable_to_non_nullable
              as RankingWeeklyResponse,
    ));
  }

  /// Create a copy of ReadingDataState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RankingWeeklyResponseCopyWith<$Res>? get top1 {
    if (_self.top1 == null) {
      return null;
    }

    return $RankingWeeklyResponseCopyWith<$Res>(_self.top1!, (value) {
      return _then(_self.copyWith(top1: value));
    });
  }

  /// Create a copy of ReadingDataState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RankingWeeklyResponseCopyWith<$Res>? get top2 {
    if (_self.top2 == null) {
      return null;
    }

    return $RankingWeeklyResponseCopyWith<$Res>(_self.top2!, (value) {
      return _then(_self.copyWith(top2: value));
    });
  }

  /// Create a copy of ReadingDataState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RankingWeeklyResponseCopyWith<$Res>? get top3 {
    if (_self.top3 == null) {
      return null;
    }

    return $RankingWeeklyResponseCopyWith<$Res>(_self.top3!, (value) {
      return _then(_self.copyWith(top3: value));
    });
  }

  /// Create a copy of ReadingDataState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RankingWeeklyResponseCopyWith<$Res> get my {
    return $RankingWeeklyResponseCopyWith<$Res>(_self.my, (value) {
      return _then(_self.copyWith(my: value));
    });
  }
}

// dart format on
