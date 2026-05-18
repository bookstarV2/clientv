// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fcm_token_create_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FCMTokenCreateRequest {
  int get userId;
  String get fcmToken;
  String get deviceType;

  /// Create a copy of FCMTokenCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $FCMTokenCreateRequestCopyWith<FCMTokenCreateRequest> get copyWith =>
      _$FCMTokenCreateRequestCopyWithImpl<FCMTokenCreateRequest>(
          this as FCMTokenCreateRequest, _$identity);

  /// Serializes this FCMTokenCreateRequest to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is FCMTokenCreateRequest &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.fcmToken, fcmToken) ||
                other.fcmToken == fcmToken) &&
            (identical(other.deviceType, deviceType) ||
                other.deviceType == deviceType));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, userId, fcmToken, deviceType);

  @override
  String toString() {
    return 'FCMTokenCreateRequest(userId: $userId, fcmToken: $fcmToken, deviceType: $deviceType)';
  }
}

/// @nodoc
abstract mixin class $FCMTokenCreateRequestCopyWith<$Res> {
  factory $FCMTokenCreateRequestCopyWith(FCMTokenCreateRequest value,
          $Res Function(FCMTokenCreateRequest) _then) =
      _$FCMTokenCreateRequestCopyWithImpl;
  @useResult
  $Res call({int userId, String fcmToken, String deviceType});
}

/// @nodoc
class _$FCMTokenCreateRequestCopyWithImpl<$Res>
    implements $FCMTokenCreateRequestCopyWith<$Res> {
  _$FCMTokenCreateRequestCopyWithImpl(this._self, this._then);

  final FCMTokenCreateRequest _self;
  final $Res Function(FCMTokenCreateRequest) _then;

  /// Create a copy of FCMTokenCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? fcmToken = null,
    Object? deviceType = null,
  }) {
    return _then(_self.copyWith(
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      fcmToken: null == fcmToken
          ? _self.fcmToken
          : fcmToken // ignore: cast_nullable_to_non_nullable
              as String,
      deviceType: null == deviceType
          ? _self.deviceType
          : deviceType // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [FCMTokenCreateRequest].
extension FCMTokenCreateRequestPatterns on FCMTokenCreateRequest {
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
    TResult Function(_FCMTokenCreateRequest value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _FCMTokenCreateRequest() when $default != null:
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
    TResult Function(_FCMTokenCreateRequest value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _FCMTokenCreateRequest():
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
    TResult? Function(_FCMTokenCreateRequest value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _FCMTokenCreateRequest() when $default != null:
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
    TResult Function(int userId, String fcmToken, String deviceType)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _FCMTokenCreateRequest() when $default != null:
        return $default(_that.userId, _that.fcmToken, _that.deviceType);
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
    TResult Function(int userId, String fcmToken, String deviceType) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _FCMTokenCreateRequest():
        return $default(_that.userId, _that.fcmToken, _that.deviceType);
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
    TResult? Function(int userId, String fcmToken, String deviceType)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _FCMTokenCreateRequest() when $default != null:
        return $default(_that.userId, _that.fcmToken, _that.deviceType);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _FCMTokenCreateRequest implements FCMTokenCreateRequest {
  const _FCMTokenCreateRequest(
      {required this.userId, required this.fcmToken, required this.deviceType});
  factory _FCMTokenCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$FCMTokenCreateRequestFromJson(json);

  @override
  final int userId;
  @override
  final String fcmToken;
  @override
  final String deviceType;

  /// Create a copy of FCMTokenCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$FCMTokenCreateRequestCopyWith<_FCMTokenCreateRequest> get copyWith =>
      __$FCMTokenCreateRequestCopyWithImpl<_FCMTokenCreateRequest>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$FCMTokenCreateRequestToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _FCMTokenCreateRequest &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.fcmToken, fcmToken) ||
                other.fcmToken == fcmToken) &&
            (identical(other.deviceType, deviceType) ||
                other.deviceType == deviceType));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, userId, fcmToken, deviceType);

  @override
  String toString() {
    return 'FCMTokenCreateRequest(userId: $userId, fcmToken: $fcmToken, deviceType: $deviceType)';
  }
}

/// @nodoc
abstract mixin class _$FCMTokenCreateRequestCopyWith<$Res>
    implements $FCMTokenCreateRequestCopyWith<$Res> {
  factory _$FCMTokenCreateRequestCopyWith(_FCMTokenCreateRequest value,
          $Res Function(_FCMTokenCreateRequest) _then) =
      __$FCMTokenCreateRequestCopyWithImpl;
  @override
  @useResult
  $Res call({int userId, String fcmToken, String deviceType});
}

/// @nodoc
class __$FCMTokenCreateRequestCopyWithImpl<$Res>
    implements _$FCMTokenCreateRequestCopyWith<$Res> {
  __$FCMTokenCreateRequestCopyWithImpl(this._self, this._then);

  final _FCMTokenCreateRequest _self;
  final $Res Function(_FCMTokenCreateRequest) _then;

  /// Create a copy of FCMTokenCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? userId = null,
    Object? fcmToken = null,
    Object? deviceType = null,
  }) {
    return _then(_FCMTokenCreateRequest(
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      fcmToken: null == fcmToken
          ? _self.fcmToken
          : fcmToken // ignore: cast_nullable_to_non_nullable
              as String,
      deviceType: null == deviceType
          ? _self.deviceType
          : deviceType // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
