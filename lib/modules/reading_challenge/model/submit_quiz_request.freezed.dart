// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'submit_quiz_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SubmitQuizRequest {
  int get choiceId;

  /// Create a copy of SubmitQuizRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SubmitQuizRequestCopyWith<SubmitQuizRequest> get copyWith =>
      _$SubmitQuizRequestCopyWithImpl<SubmitQuizRequest>(
          this as SubmitQuizRequest, _$identity);

  /// Serializes this SubmitQuizRequest to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SubmitQuizRequest &&
            (identical(other.choiceId, choiceId) ||
                other.choiceId == choiceId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, choiceId);

  @override
  String toString() {
    return 'SubmitQuizRequest(choiceId: $choiceId)';
  }
}

/// @nodoc
abstract mixin class $SubmitQuizRequestCopyWith<$Res> {
  factory $SubmitQuizRequestCopyWith(
          SubmitQuizRequest value, $Res Function(SubmitQuizRequest) _then) =
      _$SubmitQuizRequestCopyWithImpl;
  @useResult
  $Res call({int choiceId});
}

/// @nodoc
class _$SubmitQuizRequestCopyWithImpl<$Res>
    implements $SubmitQuizRequestCopyWith<$Res> {
  _$SubmitQuizRequestCopyWithImpl(this._self, this._then);

  final SubmitQuizRequest _self;
  final $Res Function(SubmitQuizRequest) _then;

  /// Create a copy of SubmitQuizRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? choiceId = null,
  }) {
    return _then(_self.copyWith(
      choiceId: null == choiceId
          ? _self.choiceId
          : choiceId // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [SubmitQuizRequest].
extension SubmitQuizRequestPatterns on SubmitQuizRequest {
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
    TResult Function(_SubmitQuizRequest value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SubmitQuizRequest() when $default != null:
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
    TResult Function(_SubmitQuizRequest value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SubmitQuizRequest():
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
    TResult? Function(_SubmitQuizRequest value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SubmitQuizRequest() when $default != null:
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
    TResult Function(int choiceId)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SubmitQuizRequest() when $default != null:
        return $default(_that.choiceId);
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
    TResult Function(int choiceId) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SubmitQuizRequest():
        return $default(_that.choiceId);
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
    TResult? Function(int choiceId)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SubmitQuizRequest() when $default != null:
        return $default(_that.choiceId);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _SubmitQuizRequest implements SubmitQuizRequest {
  const _SubmitQuizRequest({this.choiceId = -1});
  factory _SubmitQuizRequest.fromJson(Map<String, dynamic> json) =>
      _$SubmitQuizRequestFromJson(json);

  @override
  @JsonKey()
  final int choiceId;

  /// Create a copy of SubmitQuizRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SubmitQuizRequestCopyWith<_SubmitQuizRequest> get copyWith =>
      __$SubmitQuizRequestCopyWithImpl<_SubmitQuizRequest>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SubmitQuizRequestToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SubmitQuizRequest &&
            (identical(other.choiceId, choiceId) ||
                other.choiceId == choiceId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, choiceId);

  @override
  String toString() {
    return 'SubmitQuizRequest(choiceId: $choiceId)';
  }
}

/// @nodoc
abstract mixin class _$SubmitQuizRequestCopyWith<$Res>
    implements $SubmitQuizRequestCopyWith<$Res> {
  factory _$SubmitQuizRequestCopyWith(
          _SubmitQuizRequest value, $Res Function(_SubmitQuizRequest) _then) =
      __$SubmitQuizRequestCopyWithImpl;
  @override
  @useResult
  $Res call({int choiceId});
}

/// @nodoc
class __$SubmitQuizRequestCopyWithImpl<$Res>
    implements _$SubmitQuizRequestCopyWith<$Res> {
  __$SubmitQuizRequestCopyWithImpl(this._self, this._then);

  final _SubmitQuizRequest _self;
  final $Res Function(_SubmitQuizRequest) _then;

  /// Create a copy of SubmitQuizRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? choiceId = null,
  }) {
    return _then(_SubmitQuizRequest(
      choiceId: null == choiceId
          ? _self.choiceId
          : choiceId // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on
