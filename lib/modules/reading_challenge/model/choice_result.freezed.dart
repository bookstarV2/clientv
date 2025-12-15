// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'choice_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChoiceResult {
  int get choiceId;
  String get choiceText;
  bool get isCorrect;
  String get explanation;
  bool get isSelected;

  /// Create a copy of ChoiceResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ChoiceResultCopyWith<ChoiceResult> get copyWith =>
      _$ChoiceResultCopyWithImpl<ChoiceResult>(
          this as ChoiceResult, _$identity);

  /// Serializes this ChoiceResult to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ChoiceResult &&
            (identical(other.choiceId, choiceId) ||
                other.choiceId == choiceId) &&
            (identical(other.choiceText, choiceText) ||
                other.choiceText == choiceText) &&
            (identical(other.isCorrect, isCorrect) ||
                other.isCorrect == isCorrect) &&
            (identical(other.explanation, explanation) ||
                other.explanation == explanation) &&
            (identical(other.isSelected, isSelected) ||
                other.isSelected == isSelected));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, choiceId, choiceText, isCorrect, explanation, isSelected);

  @override
  String toString() {
    return 'ChoiceResult(choiceId: $choiceId, choiceText: $choiceText, isCorrect: $isCorrect, explanation: $explanation, isSelected: $isSelected)';
  }
}

/// @nodoc
abstract mixin class $ChoiceResultCopyWith<$Res> {
  factory $ChoiceResultCopyWith(
          ChoiceResult value, $Res Function(ChoiceResult) _then) =
      _$ChoiceResultCopyWithImpl;
  @useResult
  $Res call(
      {int choiceId,
      String choiceText,
      bool isCorrect,
      String explanation,
      bool isSelected});
}

/// @nodoc
class _$ChoiceResultCopyWithImpl<$Res> implements $ChoiceResultCopyWith<$Res> {
  _$ChoiceResultCopyWithImpl(this._self, this._then);

  final ChoiceResult _self;
  final $Res Function(ChoiceResult) _then;

  /// Create a copy of ChoiceResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? choiceId = null,
    Object? choiceText = null,
    Object? isCorrect = null,
    Object? explanation = null,
    Object? isSelected = null,
  }) {
    return _then(_self.copyWith(
      choiceId: null == choiceId
          ? _self.choiceId
          : choiceId // ignore: cast_nullable_to_non_nullable
              as int,
      choiceText: null == choiceText
          ? _self.choiceText
          : choiceText // ignore: cast_nullable_to_non_nullable
              as String,
      isCorrect: null == isCorrect
          ? _self.isCorrect
          : isCorrect // ignore: cast_nullable_to_non_nullable
              as bool,
      explanation: null == explanation
          ? _self.explanation
          : explanation // ignore: cast_nullable_to_non_nullable
              as String,
      isSelected: null == isSelected
          ? _self.isSelected
          : isSelected // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [ChoiceResult].
extension ChoiceResultPatterns on ChoiceResult {
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
    TResult Function(_ChoiceResult value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ChoiceResult() when $default != null:
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
    TResult Function(_ChoiceResult value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChoiceResult():
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
    TResult? Function(_ChoiceResult value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChoiceResult() when $default != null:
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
    TResult Function(int choiceId, String choiceText, bool isCorrect,
            String explanation, bool isSelected)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ChoiceResult() when $default != null:
        return $default(_that.choiceId, _that.choiceText, _that.isCorrect,
            _that.explanation, _that.isSelected);
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
    TResult Function(int choiceId, String choiceText, bool isCorrect,
            String explanation, bool isSelected)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChoiceResult():
        return $default(_that.choiceId, _that.choiceText, _that.isCorrect,
            _that.explanation, _that.isSelected);
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
    TResult? Function(int choiceId, String choiceText, bool isCorrect,
            String explanation, bool isSelected)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChoiceResult() when $default != null:
        return $default(_that.choiceId, _that.choiceText, _that.isCorrect,
            _that.explanation, _that.isSelected);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _ChoiceResult implements ChoiceResult {
  const _ChoiceResult(
      {this.choiceId = -1,
      this.choiceText = '',
      this.isCorrect = false,
      this.explanation = '',
      this.isSelected = false});
  factory _ChoiceResult.fromJson(Map<String, dynamic> json) =>
      _$ChoiceResultFromJson(json);

  @override
  @JsonKey()
  final int choiceId;
  @override
  @JsonKey()
  final String choiceText;
  @override
  @JsonKey()
  final bool isCorrect;
  @override
  @JsonKey()
  final String explanation;
  @override
  @JsonKey()
  final bool isSelected;

  /// Create a copy of ChoiceResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ChoiceResultCopyWith<_ChoiceResult> get copyWith =>
      __$ChoiceResultCopyWithImpl<_ChoiceResult>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ChoiceResultToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ChoiceResult &&
            (identical(other.choiceId, choiceId) ||
                other.choiceId == choiceId) &&
            (identical(other.choiceText, choiceText) ||
                other.choiceText == choiceText) &&
            (identical(other.isCorrect, isCorrect) ||
                other.isCorrect == isCorrect) &&
            (identical(other.explanation, explanation) ||
                other.explanation == explanation) &&
            (identical(other.isSelected, isSelected) ||
                other.isSelected == isSelected));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, choiceId, choiceText, isCorrect, explanation, isSelected);

  @override
  String toString() {
    return 'ChoiceResult(choiceId: $choiceId, choiceText: $choiceText, isCorrect: $isCorrect, explanation: $explanation, isSelected: $isSelected)';
  }
}

/// @nodoc
abstract mixin class _$ChoiceResultCopyWith<$Res>
    implements $ChoiceResultCopyWith<$Res> {
  factory _$ChoiceResultCopyWith(
          _ChoiceResult value, $Res Function(_ChoiceResult) _then) =
      __$ChoiceResultCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int choiceId,
      String choiceText,
      bool isCorrect,
      String explanation,
      bool isSelected});
}

/// @nodoc
class __$ChoiceResultCopyWithImpl<$Res>
    implements _$ChoiceResultCopyWith<$Res> {
  __$ChoiceResultCopyWithImpl(this._self, this._then);

  final _ChoiceResult _self;
  final $Res Function(_ChoiceResult) _then;

  /// Create a copy of ChoiceResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? choiceId = null,
    Object? choiceText = null,
    Object? isCorrect = null,
    Object? explanation = null,
    Object? isSelected = null,
  }) {
    return _then(_ChoiceResult(
      choiceId: null == choiceId
          ? _self.choiceId
          : choiceId // ignore: cast_nullable_to_non_nullable
              as int,
      choiceText: null == choiceText
          ? _self.choiceText
          : choiceText // ignore: cast_nullable_to_non_nullable
              as String,
      isCorrect: null == isCorrect
          ? _self.isCorrect
          : isCorrect // ignore: cast_nullable_to_non_nullable
              as bool,
      explanation: null == explanation
          ? _self.explanation
          : explanation // ignore: cast_nullable_to_non_nullable
              as String,
      isSelected: null == isSelected
          ? _self.isSelected
          : isSelected // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
