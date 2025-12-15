// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'generate_all_quizzes_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GenerateAllQuizzesResponse {
  GenerateAllQuizzesStatus get status;
  int get bookId;
  int get chapterCount;

  /// Create a copy of GenerateAllQuizzesResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $GenerateAllQuizzesResponseCopyWith<GenerateAllQuizzesResponse>
      get copyWith =>
          _$GenerateAllQuizzesResponseCopyWithImpl<GenerateAllQuizzesResponse>(
              this as GenerateAllQuizzesResponse, _$identity);

  /// Serializes this GenerateAllQuizzesResponse to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is GenerateAllQuizzesResponse &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.bookId, bookId) || other.bookId == bookId) &&
            (identical(other.chapterCount, chapterCount) ||
                other.chapterCount == chapterCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, status, bookId, chapterCount);

  @override
  String toString() {
    return 'GenerateAllQuizzesResponse(status: $status, bookId: $bookId, chapterCount: $chapterCount)';
  }
}

/// @nodoc
abstract mixin class $GenerateAllQuizzesResponseCopyWith<$Res> {
  factory $GenerateAllQuizzesResponseCopyWith(GenerateAllQuizzesResponse value,
          $Res Function(GenerateAllQuizzesResponse) _then) =
      _$GenerateAllQuizzesResponseCopyWithImpl;
  @useResult
  $Res call({GenerateAllQuizzesStatus status, int bookId, int chapterCount});
}

/// @nodoc
class _$GenerateAllQuizzesResponseCopyWithImpl<$Res>
    implements $GenerateAllQuizzesResponseCopyWith<$Res> {
  _$GenerateAllQuizzesResponseCopyWithImpl(this._self, this._then);

  final GenerateAllQuizzesResponse _self;
  final $Res Function(GenerateAllQuizzesResponse) _then;

  /// Create a copy of GenerateAllQuizzesResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? bookId = null,
    Object? chapterCount = null,
  }) {
    return _then(_self.copyWith(
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as GenerateAllQuizzesStatus,
      bookId: null == bookId
          ? _self.bookId
          : bookId // ignore: cast_nullable_to_non_nullable
              as int,
      chapterCount: null == chapterCount
          ? _self.chapterCount
          : chapterCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [GenerateAllQuizzesResponse].
extension GenerateAllQuizzesResponsePatterns on GenerateAllQuizzesResponse {
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
    TResult Function(_GenerateAllQuizzesResponse value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GenerateAllQuizzesResponse() when $default != null:
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
    TResult Function(_GenerateAllQuizzesResponse value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GenerateAllQuizzesResponse():
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
    TResult? Function(_GenerateAllQuizzesResponse value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GenerateAllQuizzesResponse() when $default != null:
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
            GenerateAllQuizzesStatus status, int bookId, int chapterCount)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GenerateAllQuizzesResponse() when $default != null:
        return $default(_that.status, _that.bookId, _that.chapterCount);
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
            GenerateAllQuizzesStatus status, int bookId, int chapterCount)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GenerateAllQuizzesResponse():
        return $default(_that.status, _that.bookId, _that.chapterCount);
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
            GenerateAllQuizzesStatus status, int bookId, int chapterCount)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GenerateAllQuizzesResponse() when $default != null:
        return $default(_that.status, _that.bookId, _that.chapterCount);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _GenerateAllQuizzesResponse implements GenerateAllQuizzesResponse {
  const _GenerateAllQuizzesResponse(
      {this.status = GenerateAllQuizzesStatus.PROCESSING,
      this.bookId = 0,
      this.chapterCount = 0});
  factory _GenerateAllQuizzesResponse.fromJson(Map<String, dynamic> json) =>
      _$GenerateAllQuizzesResponseFromJson(json);

  @override
  @JsonKey()
  final GenerateAllQuizzesStatus status;
  @override
  @JsonKey()
  final int bookId;
  @override
  @JsonKey()
  final int chapterCount;

  /// Create a copy of GenerateAllQuizzesResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$GenerateAllQuizzesResponseCopyWith<_GenerateAllQuizzesResponse>
      get copyWith => __$GenerateAllQuizzesResponseCopyWithImpl<
          _GenerateAllQuizzesResponse>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$GenerateAllQuizzesResponseToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _GenerateAllQuizzesResponse &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.bookId, bookId) || other.bookId == bookId) &&
            (identical(other.chapterCount, chapterCount) ||
                other.chapterCount == chapterCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, status, bookId, chapterCount);

  @override
  String toString() {
    return 'GenerateAllQuizzesResponse(status: $status, bookId: $bookId, chapterCount: $chapterCount)';
  }
}

/// @nodoc
abstract mixin class _$GenerateAllQuizzesResponseCopyWith<$Res>
    implements $GenerateAllQuizzesResponseCopyWith<$Res> {
  factory _$GenerateAllQuizzesResponseCopyWith(
          _GenerateAllQuizzesResponse value,
          $Res Function(_GenerateAllQuizzesResponse) _then) =
      __$GenerateAllQuizzesResponseCopyWithImpl;
  @override
  @useResult
  $Res call({GenerateAllQuizzesStatus status, int bookId, int chapterCount});
}

/// @nodoc
class __$GenerateAllQuizzesResponseCopyWithImpl<$Res>
    implements _$GenerateAllQuizzesResponseCopyWith<$Res> {
  __$GenerateAllQuizzesResponseCopyWithImpl(this._self, this._then);

  final _GenerateAllQuizzesResponse _self;
  final $Res Function(_GenerateAllQuizzesResponse) _then;

  /// Create a copy of GenerateAllQuizzesResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? status = null,
    Object? bookId = null,
    Object? chapterCount = null,
  }) {
    return _then(_GenerateAllQuizzesResponse(
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as GenerateAllQuizzesStatus,
      bookId: null == bookId
          ? _self.bookId
          : bookId // ignore: cast_nullable_to_non_nullable
              as int,
      chapterCount: null == chapterCount
          ? _self.chapterCount
          : chapterCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on
