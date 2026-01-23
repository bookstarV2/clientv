// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'completed_challenge_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CompletedChallengeScreenState {
  List<ChallengeResponse> get challenges;
  int get completedCount;
  bool get isSelectionMode;
  Set<int> get selectedChallengeIds;

  /// Create a copy of CompletedChallengeScreenState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CompletedChallengeScreenStateCopyWith<CompletedChallengeScreenState>
      get copyWith => _$CompletedChallengeScreenStateCopyWithImpl<
              CompletedChallengeScreenState>(
          this as CompletedChallengeScreenState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CompletedChallengeScreenState &&
            const DeepCollectionEquality()
                .equals(other.challenges, challenges) &&
            (identical(other.completedCount, completedCount) ||
                other.completedCount == completedCount) &&
            (identical(other.isSelectionMode, isSelectionMode) ||
                other.isSelectionMode == isSelectionMode) &&
            const DeepCollectionEquality()
                .equals(other.selectedChallengeIds, selectedChallengeIds));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(challenges),
      completedCount,
      isSelectionMode,
      const DeepCollectionEquality().hash(selectedChallengeIds));

  @override
  String toString() {
    return 'CompletedChallengeScreenState(challenges: $challenges, completedCount: $completedCount, isSelectionMode: $isSelectionMode, selectedChallengeIds: $selectedChallengeIds)';
  }
}

/// @nodoc
abstract mixin class $CompletedChallengeScreenStateCopyWith<$Res> {
  factory $CompletedChallengeScreenStateCopyWith(
          CompletedChallengeScreenState value,
          $Res Function(CompletedChallengeScreenState) _then) =
      _$CompletedChallengeScreenStateCopyWithImpl;
  @useResult
  $Res call(
      {List<ChallengeResponse> challenges,
      int completedCount,
      bool isSelectionMode,
      Set<int> selectedChallengeIds});
}

/// @nodoc
class _$CompletedChallengeScreenStateCopyWithImpl<$Res>
    implements $CompletedChallengeScreenStateCopyWith<$Res> {
  _$CompletedChallengeScreenStateCopyWithImpl(this._self, this._then);

  final CompletedChallengeScreenState _self;
  final $Res Function(CompletedChallengeScreenState) _then;

  /// Create a copy of CompletedChallengeScreenState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? challenges = null,
    Object? completedCount = null,
    Object? isSelectionMode = null,
    Object? selectedChallengeIds = null,
  }) {
    return _then(_self.copyWith(
      challenges: null == challenges
          ? _self.challenges
          : challenges // ignore: cast_nullable_to_non_nullable
              as List<ChallengeResponse>,
      completedCount: null == completedCount
          ? _self.completedCount
          : completedCount // ignore: cast_nullable_to_non_nullable
              as int,
      isSelectionMode: null == isSelectionMode
          ? _self.isSelectionMode
          : isSelectionMode // ignore: cast_nullable_to_non_nullable
              as bool,
      selectedChallengeIds: null == selectedChallengeIds
          ? _self.selectedChallengeIds
          : selectedChallengeIds // ignore: cast_nullable_to_non_nullable
              as Set<int>,
    ));
  }
}

/// Adds pattern-matching-related methods to [CompletedChallengeScreenState].
extension CompletedChallengeScreenStatePatterns
    on CompletedChallengeScreenState {
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
    TResult Function(_CompletedChallengeScreenState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CompletedChallengeScreenState() when $default != null:
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
    TResult Function(_CompletedChallengeScreenState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CompletedChallengeScreenState():
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
    TResult? Function(_CompletedChallengeScreenState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CompletedChallengeScreenState() when $default != null:
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
    TResult Function(List<ChallengeResponse> challenges, int completedCount,
            bool isSelectionMode, Set<int> selectedChallengeIds)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CompletedChallengeScreenState() when $default != null:
        return $default(_that.challenges, _that.completedCount,
            _that.isSelectionMode, _that.selectedChallengeIds);
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
    TResult Function(List<ChallengeResponse> challenges, int completedCount,
            bool isSelectionMode, Set<int> selectedChallengeIds)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CompletedChallengeScreenState():
        return $default(_that.challenges, _that.completedCount,
            _that.isSelectionMode, _that.selectedChallengeIds);
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
    TResult? Function(List<ChallengeResponse> challenges, int completedCount,
            bool isSelectionMode, Set<int> selectedChallengeIds)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CompletedChallengeScreenState() when $default != null:
        return $default(_that.challenges, _that.completedCount,
            _that.isSelectionMode, _that.selectedChallengeIds);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _CompletedChallengeScreenState implements CompletedChallengeScreenState {
  const _CompletedChallengeScreenState(
      {final List<ChallengeResponse> challenges = const [],
      this.completedCount = -1,
      this.isSelectionMode = false,
      final Set<int> selectedChallengeIds = const {}})
      : _challenges = challenges,
        _selectedChallengeIds = selectedChallengeIds;

  final List<ChallengeResponse> _challenges;
  @override
  @JsonKey()
  List<ChallengeResponse> get challenges {
    if (_challenges is EqualUnmodifiableListView) return _challenges;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_challenges);
  }

  @override
  @JsonKey()
  final int completedCount;
  @override
  @JsonKey()
  final bool isSelectionMode;
  final Set<int> _selectedChallengeIds;
  @override
  @JsonKey()
  Set<int> get selectedChallengeIds {
    if (_selectedChallengeIds is EqualUnmodifiableSetView)
      return _selectedChallengeIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_selectedChallengeIds);
  }

  /// Create a copy of CompletedChallengeScreenState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CompletedChallengeScreenStateCopyWith<_CompletedChallengeScreenState>
      get copyWith => __$CompletedChallengeScreenStateCopyWithImpl<
          _CompletedChallengeScreenState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CompletedChallengeScreenState &&
            const DeepCollectionEquality()
                .equals(other._challenges, _challenges) &&
            (identical(other.completedCount, completedCount) ||
                other.completedCount == completedCount) &&
            (identical(other.isSelectionMode, isSelectionMode) ||
                other.isSelectionMode == isSelectionMode) &&
            const DeepCollectionEquality()
                .equals(other._selectedChallengeIds, _selectedChallengeIds));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_challenges),
      completedCount,
      isSelectionMode,
      const DeepCollectionEquality().hash(_selectedChallengeIds));

  @override
  String toString() {
    return 'CompletedChallengeScreenState(challenges: $challenges, completedCount: $completedCount, isSelectionMode: $isSelectionMode, selectedChallengeIds: $selectedChallengeIds)';
  }
}

/// @nodoc
abstract mixin class _$CompletedChallengeScreenStateCopyWith<$Res>
    implements $CompletedChallengeScreenStateCopyWith<$Res> {
  factory _$CompletedChallengeScreenStateCopyWith(
          _CompletedChallengeScreenState value,
          $Res Function(_CompletedChallengeScreenState) _then) =
      __$CompletedChallengeScreenStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {List<ChallengeResponse> challenges,
      int completedCount,
      bool isSelectionMode,
      Set<int> selectedChallengeIds});
}

/// @nodoc
class __$CompletedChallengeScreenStateCopyWithImpl<$Res>
    implements _$CompletedChallengeScreenStateCopyWith<$Res> {
  __$CompletedChallengeScreenStateCopyWithImpl(this._self, this._then);

  final _CompletedChallengeScreenState _self;
  final $Res Function(_CompletedChallengeScreenState) _then;

  /// Create a copy of CompletedChallengeScreenState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? challenges = null,
    Object? completedCount = null,
    Object? isSelectionMode = null,
    Object? selectedChallengeIds = null,
  }) {
    return _then(_CompletedChallengeScreenState(
      challenges: null == challenges
          ? _self._challenges
          : challenges // ignore: cast_nullable_to_non_nullable
              as List<ChallengeResponse>,
      completedCount: null == completedCount
          ? _self.completedCount
          : completedCount // ignore: cast_nullable_to_non_nullable
              as int,
      isSelectionMode: null == isSelectionMode
          ? _self.isSelectionMode
          : isSelectionMode // ignore: cast_nullable_to_non_nullable
              as bool,
      selectedChallengeIds: null == selectedChallengeIds
          ? _self._selectedChallengeIds
          : selectedChallengeIds // ignore: cast_nullable_to_non_nullable
              as Set<int>,
    ));
  }
}

// dart format on
