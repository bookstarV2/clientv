// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_progress_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PostProgressRequest {
  int get chapterId;

  /// Create a copy of PostProgressRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PostProgressRequestCopyWith<PostProgressRequest> get copyWith =>
      _$PostProgressRequestCopyWithImpl<PostProgressRequest>(
          this as PostProgressRequest, _$identity);

  /// Serializes this PostProgressRequest to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PostProgressRequest &&
            (identical(other.chapterId, chapterId) ||
                other.chapterId == chapterId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, chapterId);

  @override
  String toString() {
    return 'PostProgressRequest(chapterId: $chapterId)';
  }
}

/// @nodoc
abstract mixin class $PostProgressRequestCopyWith<$Res> {
  factory $PostProgressRequestCopyWith(
          PostProgressRequest value, $Res Function(PostProgressRequest) _then) =
      _$PostProgressRequestCopyWithImpl;
  @useResult
  $Res call({int chapterId});
}

/// @nodoc
class _$PostProgressRequestCopyWithImpl<$Res>
    implements $PostProgressRequestCopyWith<$Res> {
  _$PostProgressRequestCopyWithImpl(this._self, this._then);

  final PostProgressRequest _self;
  final $Res Function(PostProgressRequest) _then;

  /// Create a copy of PostProgressRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? chapterId = null,
  }) {
    return _then(_self.copyWith(
      chapterId: null == chapterId
          ? _self.chapterId
          : chapterId // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [PostProgressRequest].
extension PostProgressRequestPatterns on PostProgressRequest {
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
    TResult Function(_PostProgressRequest value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PostProgressRequest() when $default != null:
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
    TResult Function(_PostProgressRequest value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PostProgressRequest():
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
    TResult? Function(_PostProgressRequest value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PostProgressRequest() when $default != null:
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
    TResult Function(int chapterId)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PostProgressRequest() when $default != null:
        return $default(_that.chapterId);
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
    TResult Function(int chapterId) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PostProgressRequest():
        return $default(_that.chapterId);
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
    TResult? Function(int chapterId)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PostProgressRequest() when $default != null:
        return $default(_that.chapterId);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _PostProgressRequest implements PostProgressRequest {
  const _PostProgressRequest({this.chapterId = -1});
  factory _PostProgressRequest.fromJson(Map<String, dynamic> json) =>
      _$PostProgressRequestFromJson(json);

  @override
  @JsonKey()
  final int chapterId;

  /// Create a copy of PostProgressRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PostProgressRequestCopyWith<_PostProgressRequest> get copyWith =>
      __$PostProgressRequestCopyWithImpl<_PostProgressRequest>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$PostProgressRequestToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PostProgressRequest &&
            (identical(other.chapterId, chapterId) ||
                other.chapterId == chapterId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, chapterId);

  @override
  String toString() {
    return 'PostProgressRequest(chapterId: $chapterId)';
  }
}

/// @nodoc
abstract mixin class _$PostProgressRequestCopyWith<$Res>
    implements $PostProgressRequestCopyWith<$Res> {
  factory _$PostProgressRequestCopyWith(_PostProgressRequest value,
          $Res Function(_PostProgressRequest) _then) =
      __$PostProgressRequestCopyWithImpl;
  @override
  @useResult
  $Res call({int chapterId});
}

/// @nodoc
class __$PostProgressRequestCopyWithImpl<$Res>
    implements _$PostProgressRequestCopyWith<$Res> {
  __$PostProgressRequestCopyWithImpl(this._self, this._then);

  final _PostProgressRequest _self;
  final $Res Function(_PostProgressRequest) _then;

  /// Create a copy of PostProgressRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? chapterId = null,
  }) {
    return _then(_PostProgressRequest(
      chapterId: null == chapterId
          ? _self.chapterId
          : chapterId // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on
