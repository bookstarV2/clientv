// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'quiz_choice.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$QuizChoice {
  int get choiceId;
  int get choiceOrder;
  String get choiceText;

  /// Create a copy of QuizChoice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $QuizChoiceCopyWith<QuizChoice> get copyWith =>
      _$QuizChoiceCopyWithImpl<QuizChoice>(this as QuizChoice, _$identity);

  /// Serializes this QuizChoice to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is QuizChoice &&
            (identical(other.choiceId, choiceId) ||
                other.choiceId == choiceId) &&
            (identical(other.choiceOrder, choiceOrder) ||
                other.choiceOrder == choiceOrder) &&
            (identical(other.choiceText, choiceText) ||
                other.choiceText == choiceText));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, choiceId, choiceOrder, choiceText);

  @override
  String toString() {
    return 'QuizChoice(choiceId: $choiceId, choiceOrder: $choiceOrder, choiceText: $choiceText)';
  }
}

/// @nodoc
abstract mixin class $QuizChoiceCopyWith<$Res> {
  factory $QuizChoiceCopyWith(
          QuizChoice value, $Res Function(QuizChoice) _then) =
      _$QuizChoiceCopyWithImpl;
  @useResult
  $Res call({int choiceId, int choiceOrder, String choiceText});
}

/// @nodoc
class _$QuizChoiceCopyWithImpl<$Res> implements $QuizChoiceCopyWith<$Res> {
  _$QuizChoiceCopyWithImpl(this._self, this._then);

  final QuizChoice _self;
  final $Res Function(QuizChoice) _then;

  /// Create a copy of QuizChoice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? choiceId = null,
    Object? choiceOrder = null,
    Object? choiceText = null,
  }) {
    return _then(_self.copyWith(
      choiceId: null == choiceId
          ? _self.choiceId
          : choiceId // ignore: cast_nullable_to_non_nullable
              as int,
      choiceOrder: null == choiceOrder
          ? _self.choiceOrder
          : choiceOrder // ignore: cast_nullable_to_non_nullable
              as int,
      choiceText: null == choiceText
          ? _self.choiceText
          : choiceText // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [QuizChoice].
extension QuizChoicePatterns on QuizChoice {
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
    TResult Function(_QuizChoice value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _QuizChoice() when $default != null:
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
    TResult Function(_QuizChoice value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _QuizChoice():
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
    TResult? Function(_QuizChoice value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _QuizChoice() when $default != null:
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
    TResult Function(int choiceId, int choiceOrder, String choiceText)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _QuizChoice() when $default != null:
        return $default(_that.choiceId, _that.choiceOrder, _that.choiceText);
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
    TResult Function(int choiceId, int choiceOrder, String choiceText) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _QuizChoice():
        return $default(_that.choiceId, _that.choiceOrder, _that.choiceText);
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
    TResult? Function(int choiceId, int choiceOrder, String choiceText)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _QuizChoice() when $default != null:
        return $default(_that.choiceId, _that.choiceOrder, _that.choiceText);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _QuizChoice implements QuizChoice {
  const _QuizChoice(
      {this.choiceId = -1, this.choiceOrder = -1, this.choiceText = ''});
  factory _QuizChoice.fromJson(Map<String, dynamic> json) =>
      _$QuizChoiceFromJson(json);

  @override
  @JsonKey()
  final int choiceId;
  @override
  @JsonKey()
  final int choiceOrder;
  @override
  @JsonKey()
  final String choiceText;

  /// Create a copy of QuizChoice
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$QuizChoiceCopyWith<_QuizChoice> get copyWith =>
      __$QuizChoiceCopyWithImpl<_QuizChoice>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$QuizChoiceToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _QuizChoice &&
            (identical(other.choiceId, choiceId) ||
                other.choiceId == choiceId) &&
            (identical(other.choiceOrder, choiceOrder) ||
                other.choiceOrder == choiceOrder) &&
            (identical(other.choiceText, choiceText) ||
                other.choiceText == choiceText));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, choiceId, choiceOrder, choiceText);

  @override
  String toString() {
    return 'QuizChoice(choiceId: $choiceId, choiceOrder: $choiceOrder, choiceText: $choiceText)';
  }
}

/// @nodoc
abstract mixin class _$QuizChoiceCopyWith<$Res>
    implements $QuizChoiceCopyWith<$Res> {
  factory _$QuizChoiceCopyWith(
          _QuizChoice value, $Res Function(_QuizChoice) _then) =
      __$QuizChoiceCopyWithImpl;
  @override
  @useResult
  $Res call({int choiceId, int choiceOrder, String choiceText});
}

/// @nodoc
class __$QuizChoiceCopyWithImpl<$Res> implements _$QuizChoiceCopyWith<$Res> {
  __$QuizChoiceCopyWithImpl(this._self, this._then);

  final _QuizChoice _self;
  final $Res Function(_QuizChoice) _then;

  /// Create a copy of QuizChoice
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? choiceId = null,
    Object? choiceOrder = null,
    Object? choiceText = null,
  }) {
    return _then(_QuizChoice(
      choiceId: null == choiceId
          ? _self.choiceId
          : choiceId // ignore: cast_nullable_to_non_nullable
              as int,
      choiceOrder: null == choiceOrder
          ? _self.choiceOrder
          : choiceOrder // ignore: cast_nullable_to_non_nullable
              as int,
      choiceText: null == choiceText
          ? _self.choiceText
          : choiceText // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
