// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'challenge_success_detail_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChallengeSuccessDetailResponse {
  int get totalTime;
  int get totalCollect;
  int get readingSpeedPerMinute;
  String get bookTitle;
  String get bookAuthor;
  String get bookCover;
  String get bookPublisher;

  /// Create a copy of ChallengeSuccessDetailResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ChallengeSuccessDetailResponseCopyWith<ChallengeSuccessDetailResponse>
      get copyWith => _$ChallengeSuccessDetailResponseCopyWithImpl<
              ChallengeSuccessDetailResponse>(
          this as ChallengeSuccessDetailResponse, _$identity);

  /// Serializes this ChallengeSuccessDetailResponse to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ChallengeSuccessDetailResponse &&
            (identical(other.totalTime, totalTime) ||
                other.totalTime == totalTime) &&
            (identical(other.totalCollect, totalCollect) ||
                other.totalCollect == totalCollect) &&
            (identical(other.readingSpeedPerMinute, readingSpeedPerMinute) ||
                other.readingSpeedPerMinute == readingSpeedPerMinute) &&
            (identical(other.bookTitle, bookTitle) ||
                other.bookTitle == bookTitle) &&
            (identical(other.bookAuthor, bookAuthor) ||
                other.bookAuthor == bookAuthor) &&
            (identical(other.bookCover, bookCover) ||
                other.bookCover == bookCover) &&
            (identical(other.bookPublisher, bookPublisher) ||
                other.bookPublisher == bookPublisher));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, totalTime, totalCollect,
      readingSpeedPerMinute, bookTitle, bookAuthor, bookCover, bookPublisher);

  @override
  String toString() {
    return 'ChallengeSuccessDetailResponse(totalTime: $totalTime, totalCollect: $totalCollect, readingSpeedPerMinute: $readingSpeedPerMinute, bookTitle: $bookTitle, bookAuthor: $bookAuthor, bookCover: $bookCover, bookPublisher: $bookPublisher)';
  }
}

/// @nodoc
abstract mixin class $ChallengeSuccessDetailResponseCopyWith<$Res> {
  factory $ChallengeSuccessDetailResponseCopyWith(
          ChallengeSuccessDetailResponse value,
          $Res Function(ChallengeSuccessDetailResponse) _then) =
      _$ChallengeSuccessDetailResponseCopyWithImpl;
  @useResult
  $Res call(
      {int totalTime,
      int totalCollect,
      int readingSpeedPerMinute,
      String bookTitle,
      String bookAuthor,
      String bookCover,
      String bookPublisher});
}

/// @nodoc
class _$ChallengeSuccessDetailResponseCopyWithImpl<$Res>
    implements $ChallengeSuccessDetailResponseCopyWith<$Res> {
  _$ChallengeSuccessDetailResponseCopyWithImpl(this._self, this._then);

  final ChallengeSuccessDetailResponse _self;
  final $Res Function(ChallengeSuccessDetailResponse) _then;

  /// Create a copy of ChallengeSuccessDetailResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalTime = null,
    Object? totalCollect = null,
    Object? readingSpeedPerMinute = null,
    Object? bookTitle = null,
    Object? bookAuthor = null,
    Object? bookCover = null,
    Object? bookPublisher = null,
  }) {
    return _then(_self.copyWith(
      totalTime: null == totalTime
          ? _self.totalTime
          : totalTime // ignore: cast_nullable_to_non_nullable
              as int,
      totalCollect: null == totalCollect
          ? _self.totalCollect
          : totalCollect // ignore: cast_nullable_to_non_nullable
              as int,
      readingSpeedPerMinute: null == readingSpeedPerMinute
          ? _self.readingSpeedPerMinute
          : readingSpeedPerMinute // ignore: cast_nullable_to_non_nullable
              as int,
      bookTitle: null == bookTitle
          ? _self.bookTitle
          : bookTitle // ignore: cast_nullable_to_non_nullable
              as String,
      bookAuthor: null == bookAuthor
          ? _self.bookAuthor
          : bookAuthor // ignore: cast_nullable_to_non_nullable
              as String,
      bookCover: null == bookCover
          ? _self.bookCover
          : bookCover // ignore: cast_nullable_to_non_nullable
              as String,
      bookPublisher: null == bookPublisher
          ? _self.bookPublisher
          : bookPublisher // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [ChallengeSuccessDetailResponse].
extension ChallengeSuccessDetailResponsePatterns
    on ChallengeSuccessDetailResponse {
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
    TResult Function(_ChallengeSuccessDetailResponse value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ChallengeSuccessDetailResponse() when $default != null:
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
    TResult Function(_ChallengeSuccessDetailResponse value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChallengeSuccessDetailResponse():
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
    TResult? Function(_ChallengeSuccessDetailResponse value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChallengeSuccessDetailResponse() when $default != null:
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
            int totalTime,
            int totalCollect,
            int readingSpeedPerMinute,
            String bookTitle,
            String bookAuthor,
            String bookCover,
            String bookPublisher)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ChallengeSuccessDetailResponse() when $default != null:
        return $default(
            _that.totalTime,
            _that.totalCollect,
            _that.readingSpeedPerMinute,
            _that.bookTitle,
            _that.bookAuthor,
            _that.bookCover,
            _that.bookPublisher);
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
            int totalTime,
            int totalCollect,
            int readingSpeedPerMinute,
            String bookTitle,
            String bookAuthor,
            String bookCover,
            String bookPublisher)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChallengeSuccessDetailResponse():
        return $default(
            _that.totalTime,
            _that.totalCollect,
            _that.readingSpeedPerMinute,
            _that.bookTitle,
            _that.bookAuthor,
            _that.bookCover,
            _that.bookPublisher);
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
            int totalTime,
            int totalCollect,
            int readingSpeedPerMinute,
            String bookTitle,
            String bookAuthor,
            String bookCover,
            String bookPublisher)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChallengeSuccessDetailResponse() when $default != null:
        return $default(
            _that.totalTime,
            _that.totalCollect,
            _that.readingSpeedPerMinute,
            _that.bookTitle,
            _that.bookAuthor,
            _that.bookCover,
            _that.bookPublisher);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _ChallengeSuccessDetailResponse
    implements ChallengeSuccessDetailResponse {
  const _ChallengeSuccessDetailResponse(
      {this.totalTime = -1,
      this.totalCollect = -1,
      this.readingSpeedPerMinute = -1,
      this.bookTitle = '',
      this.bookAuthor = '',
      this.bookCover = '',
      this.bookPublisher = ''});
  factory _ChallengeSuccessDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$ChallengeSuccessDetailResponseFromJson(json);

  @override
  @JsonKey()
  final int totalTime;
  @override
  @JsonKey()
  final int totalCollect;
  @override
  @JsonKey()
  final int readingSpeedPerMinute;
  @override
  @JsonKey()
  final String bookTitle;
  @override
  @JsonKey()
  final String bookAuthor;
  @override
  @JsonKey()
  final String bookCover;
  @override
  @JsonKey()
  final String bookPublisher;

  /// Create a copy of ChallengeSuccessDetailResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ChallengeSuccessDetailResponseCopyWith<_ChallengeSuccessDetailResponse>
      get copyWith => __$ChallengeSuccessDetailResponseCopyWithImpl<
          _ChallengeSuccessDetailResponse>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ChallengeSuccessDetailResponseToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ChallengeSuccessDetailResponse &&
            (identical(other.totalTime, totalTime) ||
                other.totalTime == totalTime) &&
            (identical(other.totalCollect, totalCollect) ||
                other.totalCollect == totalCollect) &&
            (identical(other.readingSpeedPerMinute, readingSpeedPerMinute) ||
                other.readingSpeedPerMinute == readingSpeedPerMinute) &&
            (identical(other.bookTitle, bookTitle) ||
                other.bookTitle == bookTitle) &&
            (identical(other.bookAuthor, bookAuthor) ||
                other.bookAuthor == bookAuthor) &&
            (identical(other.bookCover, bookCover) ||
                other.bookCover == bookCover) &&
            (identical(other.bookPublisher, bookPublisher) ||
                other.bookPublisher == bookPublisher));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, totalTime, totalCollect,
      readingSpeedPerMinute, bookTitle, bookAuthor, bookCover, bookPublisher);

  @override
  String toString() {
    return 'ChallengeSuccessDetailResponse(totalTime: $totalTime, totalCollect: $totalCollect, readingSpeedPerMinute: $readingSpeedPerMinute, bookTitle: $bookTitle, bookAuthor: $bookAuthor, bookCover: $bookCover, bookPublisher: $bookPublisher)';
  }
}

/// @nodoc
abstract mixin class _$ChallengeSuccessDetailResponseCopyWith<$Res>
    implements $ChallengeSuccessDetailResponseCopyWith<$Res> {
  factory _$ChallengeSuccessDetailResponseCopyWith(
          _ChallengeSuccessDetailResponse value,
          $Res Function(_ChallengeSuccessDetailResponse) _then) =
      __$ChallengeSuccessDetailResponseCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int totalTime,
      int totalCollect,
      int readingSpeedPerMinute,
      String bookTitle,
      String bookAuthor,
      String bookCover,
      String bookPublisher});
}

/// @nodoc
class __$ChallengeSuccessDetailResponseCopyWithImpl<$Res>
    implements _$ChallengeSuccessDetailResponseCopyWith<$Res> {
  __$ChallengeSuccessDetailResponseCopyWithImpl(this._self, this._then);

  final _ChallengeSuccessDetailResponse _self;
  final $Res Function(_ChallengeSuccessDetailResponse) _then;

  /// Create a copy of ChallengeSuccessDetailResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? totalTime = null,
    Object? totalCollect = null,
    Object? readingSpeedPerMinute = null,
    Object? bookTitle = null,
    Object? bookAuthor = null,
    Object? bookCover = null,
    Object? bookPublisher = null,
  }) {
    return _then(_ChallengeSuccessDetailResponse(
      totalTime: null == totalTime
          ? _self.totalTime
          : totalTime // ignore: cast_nullable_to_non_nullable
              as int,
      totalCollect: null == totalCollect
          ? _self.totalCollect
          : totalCollect // ignore: cast_nullable_to_non_nullable
              as int,
      readingSpeedPerMinute: null == readingSpeedPerMinute
          ? _self.readingSpeedPerMinute
          : readingSpeedPerMinute // ignore: cast_nullable_to_non_nullable
              as int,
      bookTitle: null == bookTitle
          ? _self.bookTitle
          : bookTitle // ignore: cast_nullable_to_non_nullable
              as String,
      bookAuthor: null == bookAuthor
          ? _self.bookAuthor
          : bookAuthor // ignore: cast_nullable_to_non_nullable
              as String,
      bookCover: null == bookCover
          ? _self.bookCover
          : bookCover // ignore: cast_nullable_to_non_nullable
              as String,
      bookPublisher: null == bookPublisher
          ? _self.bookPublisher
          : bookPublisher // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
