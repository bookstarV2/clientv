// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'challenge_detail_chapter_detail_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChallengeDetailChapterDetailResponse {
  List<ChallengeDetailChapterDetail> get chapters;

  /// Create a copy of ChallengeDetailChapterDetailResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ChallengeDetailChapterDetailResponseCopyWith<
          ChallengeDetailChapterDetailResponse>
      get copyWith => _$ChallengeDetailChapterDetailResponseCopyWithImpl<
              ChallengeDetailChapterDetailResponse>(
          this as ChallengeDetailChapterDetailResponse, _$identity);

  /// Serializes this ChallengeDetailChapterDetailResponse to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ChallengeDetailChapterDetailResponse &&
            const DeepCollectionEquality().equals(other.chapters, chapters));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(chapters));

  @override
  String toString() {
    return 'ChallengeDetailChapterDetailResponse(chapters: $chapters)';
  }
}

/// @nodoc
abstract mixin class $ChallengeDetailChapterDetailResponseCopyWith<$Res> {
  factory $ChallengeDetailChapterDetailResponseCopyWith(
          ChallengeDetailChapterDetailResponse value,
          $Res Function(ChallengeDetailChapterDetailResponse) _then) =
      _$ChallengeDetailChapterDetailResponseCopyWithImpl;
  @useResult
  $Res call({List<ChallengeDetailChapterDetail> chapters});
}

/// @nodoc
class _$ChallengeDetailChapterDetailResponseCopyWithImpl<$Res>
    implements $ChallengeDetailChapterDetailResponseCopyWith<$Res> {
  _$ChallengeDetailChapterDetailResponseCopyWithImpl(this._self, this._then);

  final ChallengeDetailChapterDetailResponse _self;
  final $Res Function(ChallengeDetailChapterDetailResponse) _then;

  /// Create a copy of ChallengeDetailChapterDetailResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? chapters = null,
  }) {
    return _then(_self.copyWith(
      chapters: null == chapters
          ? _self.chapters
          : chapters // ignore: cast_nullable_to_non_nullable
              as List<ChallengeDetailChapterDetail>,
    ));
  }
}

/// Adds pattern-matching-related methods to [ChallengeDetailChapterDetailResponse].
extension ChallengeDetailChapterDetailResponsePatterns
    on ChallengeDetailChapterDetailResponse {
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
    TResult Function(_ChallengeDetailChapterDetailResponse value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ChallengeDetailChapterDetailResponse() when $default != null:
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
    TResult Function(_ChallengeDetailChapterDetailResponse value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChallengeDetailChapterDetailResponse():
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
    TResult? Function(_ChallengeDetailChapterDetailResponse value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChallengeDetailChapterDetailResponse() when $default != null:
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
    TResult Function(List<ChallengeDetailChapterDetail> chapters)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ChallengeDetailChapterDetailResponse() when $default != null:
        return $default(_that.chapters);
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
    TResult Function(List<ChallengeDetailChapterDetail> chapters) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChallengeDetailChapterDetailResponse():
        return $default(_that.chapters);
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
    TResult? Function(List<ChallengeDetailChapterDetail> chapters)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChallengeDetailChapterDetailResponse() when $default != null:
        return $default(_that.chapters);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _ChallengeDetailChapterDetailResponse
    implements ChallengeDetailChapterDetailResponse {
  const _ChallengeDetailChapterDetailResponse(
      {final List<ChallengeDetailChapterDetail> chapters = const []})
      : _chapters = chapters;
  factory _ChallengeDetailChapterDetailResponse.fromJson(
          Map<String, dynamic> json) =>
      _$ChallengeDetailChapterDetailResponseFromJson(json);

  final List<ChallengeDetailChapterDetail> _chapters;
  @override
  @JsonKey()
  List<ChallengeDetailChapterDetail> get chapters {
    if (_chapters is EqualUnmodifiableListView) return _chapters;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_chapters);
  }

  /// Create a copy of ChallengeDetailChapterDetailResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ChallengeDetailChapterDetailResponseCopyWith<
          _ChallengeDetailChapterDetailResponse>
      get copyWith => __$ChallengeDetailChapterDetailResponseCopyWithImpl<
          _ChallengeDetailChapterDetailResponse>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ChallengeDetailChapterDetailResponseToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ChallengeDetailChapterDetailResponse &&
            const DeepCollectionEquality().equals(other._chapters, _chapters));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_chapters));

  @override
  String toString() {
    return 'ChallengeDetailChapterDetailResponse(chapters: $chapters)';
  }
}

/// @nodoc
abstract mixin class _$ChallengeDetailChapterDetailResponseCopyWith<$Res>
    implements $ChallengeDetailChapterDetailResponseCopyWith<$Res> {
  factory _$ChallengeDetailChapterDetailResponseCopyWith(
          _ChallengeDetailChapterDetailResponse value,
          $Res Function(_ChallengeDetailChapterDetailResponse) _then) =
      __$ChallengeDetailChapterDetailResponseCopyWithImpl;
  @override
  @useResult
  $Res call({List<ChallengeDetailChapterDetail> chapters});
}

/// @nodoc
class __$ChallengeDetailChapterDetailResponseCopyWithImpl<$Res>
    implements _$ChallengeDetailChapterDetailResponseCopyWith<$Res> {
  __$ChallengeDetailChapterDetailResponseCopyWithImpl(this._self, this._then);

  final _ChallengeDetailChapterDetailResponse _self;
  final $Res Function(_ChallengeDetailChapterDetailResponse) _then;

  /// Create a copy of ChallengeDetailChapterDetailResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? chapters = null,
  }) {
    return _then(_ChallengeDetailChapterDetailResponse(
      chapters: null == chapters
          ? _self._chapters
          : chapters // ignore: cast_nullable_to_non_nullable
              as List<ChallengeDetailChapterDetail>,
    ));
  }
}

// dart format on
