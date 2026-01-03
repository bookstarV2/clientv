// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'report_quiz_error_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReportQuizErrorRequest {
  ReportQuizErrorType get errorType;
  String get content;

  /// Create a copy of ReportQuizErrorRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ReportQuizErrorRequestCopyWith<ReportQuizErrorRequest> get copyWith =>
      _$ReportQuizErrorRequestCopyWithImpl<ReportQuizErrorRequest>(
          this as ReportQuizErrorRequest, _$identity);

  /// Serializes this ReportQuizErrorRequest to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ReportQuizErrorRequest &&
            (identical(other.errorType, errorType) ||
                other.errorType == errorType) &&
            (identical(other.content, content) || other.content == content));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, errorType, content);

  @override
  String toString() {
    return 'ReportQuizErrorRequest(errorType: $errorType, content: $content)';
  }
}

/// @nodoc
abstract mixin class $ReportQuizErrorRequestCopyWith<$Res> {
  factory $ReportQuizErrorRequestCopyWith(ReportQuizErrorRequest value,
          $Res Function(ReportQuizErrorRequest) _then) =
      _$ReportQuizErrorRequestCopyWithImpl;
  @useResult
  $Res call({ReportQuizErrorType errorType, String content});
}

/// @nodoc
class _$ReportQuizErrorRequestCopyWithImpl<$Res>
    implements $ReportQuizErrorRequestCopyWith<$Res> {
  _$ReportQuizErrorRequestCopyWithImpl(this._self, this._then);

  final ReportQuizErrorRequest _self;
  final $Res Function(ReportQuizErrorRequest) _then;

  /// Create a copy of ReportQuizErrorRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? errorType = null,
    Object? content = null,
  }) {
    return _then(_self.copyWith(
      errorType: null == errorType
          ? _self.errorType
          : errorType // ignore: cast_nullable_to_non_nullable
              as ReportQuizErrorType,
      content: null == content
          ? _self.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [ReportQuizErrorRequest].
extension ReportQuizErrorRequestPatterns on ReportQuizErrorRequest {
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
    TResult Function(_ReportQuizErrorRequest value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ReportQuizErrorRequest() when $default != null:
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
    TResult Function(_ReportQuizErrorRequest value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ReportQuizErrorRequest():
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
    TResult? Function(_ReportQuizErrorRequest value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ReportQuizErrorRequest() when $default != null:
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
    TResult Function(ReportQuizErrorType errorType, String content)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ReportQuizErrorRequest() when $default != null:
        return $default(_that.errorType, _that.content);
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
    TResult Function(ReportQuizErrorType errorType, String content) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ReportQuizErrorRequest():
        return $default(_that.errorType, _that.content);
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
    TResult? Function(ReportQuizErrorType errorType, String content)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ReportQuizErrorRequest() when $default != null:
        return $default(_that.errorType, _that.content);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _ReportQuizErrorRequest implements ReportQuizErrorRequest {
  const _ReportQuizErrorRequest(
      {this.errorType = ReportQuizErrorType.OTHER, this.content = ''});
  factory _ReportQuizErrorRequest.fromJson(Map<String, dynamic> json) =>
      _$ReportQuizErrorRequestFromJson(json);

  @override
  @JsonKey()
  final ReportQuizErrorType errorType;
  @override
  @JsonKey()
  final String content;

  /// Create a copy of ReportQuizErrorRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ReportQuizErrorRequestCopyWith<_ReportQuizErrorRequest> get copyWith =>
      __$ReportQuizErrorRequestCopyWithImpl<_ReportQuizErrorRequest>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ReportQuizErrorRequestToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ReportQuizErrorRequest &&
            (identical(other.errorType, errorType) ||
                other.errorType == errorType) &&
            (identical(other.content, content) || other.content == content));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, errorType, content);

  @override
  String toString() {
    return 'ReportQuizErrorRequest(errorType: $errorType, content: $content)';
  }
}

/// @nodoc
abstract mixin class _$ReportQuizErrorRequestCopyWith<$Res>
    implements $ReportQuizErrorRequestCopyWith<$Res> {
  factory _$ReportQuizErrorRequestCopyWith(_ReportQuizErrorRequest value,
          $Res Function(_ReportQuizErrorRequest) _then) =
      __$ReportQuizErrorRequestCopyWithImpl;
  @override
  @useResult
  $Res call({ReportQuizErrorType errorType, String content});
}

/// @nodoc
class __$ReportQuizErrorRequestCopyWithImpl<$Res>
    implements _$ReportQuizErrorRequestCopyWith<$Res> {
  __$ReportQuizErrorRequestCopyWithImpl(this._self, this._then);

  final _ReportQuizErrorRequest _self;
  final $Res Function(_ReportQuizErrorRequest) _then;

  /// Create a copy of ReportQuizErrorRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? errorType = null,
    Object? content = null,
  }) {
    return _then(_ReportQuizErrorRequest(
      errorType: null == errorType
          ? _self.errorType
          : errorType // ignore: cast_nullable_to_non_nullable
              as ReportQuizErrorType,
      content: null == content
          ? _self.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
