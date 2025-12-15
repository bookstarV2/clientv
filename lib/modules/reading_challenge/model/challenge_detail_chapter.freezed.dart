// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'challenge_detail_chapter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChallengeDetailChapter {
  int get chapterId;
  String get title;
  int get chapterNumber;
  ChapterStatus get status;

  /// Create a copy of ChallengeDetailChapter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ChallengeDetailChapterCopyWith<ChallengeDetailChapter> get copyWith =>
      _$ChallengeDetailChapterCopyWithImpl<ChallengeDetailChapter>(
          this as ChallengeDetailChapter, _$identity);

  /// Serializes this ChallengeDetailChapter to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ChallengeDetailChapter &&
            (identical(other.chapterId, chapterId) ||
                other.chapterId == chapterId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.chapterNumber, chapterNumber) ||
                other.chapterNumber == chapterNumber) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, chapterId, title, chapterNumber, status);

  @override
  String toString() {
    return 'ChallengeDetailChapter(chapterId: $chapterId, title: $title, chapterNumber: $chapterNumber, status: $status)';
  }
}

/// @nodoc
abstract mixin class $ChallengeDetailChapterCopyWith<$Res> {
  factory $ChallengeDetailChapterCopyWith(ChallengeDetailChapter value,
          $Res Function(ChallengeDetailChapter) _then) =
      _$ChallengeDetailChapterCopyWithImpl;
  @useResult
  $Res call(
      {int chapterId, String title, int chapterNumber, ChapterStatus status});
}

/// @nodoc
class _$ChallengeDetailChapterCopyWithImpl<$Res>
    implements $ChallengeDetailChapterCopyWith<$Res> {
  _$ChallengeDetailChapterCopyWithImpl(this._self, this._then);

  final ChallengeDetailChapter _self;
  final $Res Function(ChallengeDetailChapter) _then;

  /// Create a copy of ChallengeDetailChapter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? chapterId = null,
    Object? title = null,
    Object? chapterNumber = null,
    Object? status = null,
  }) {
    return _then(_self.copyWith(
      chapterId: null == chapterId
          ? _self.chapterId
          : chapterId // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      chapterNumber: null == chapterNumber
          ? _self.chapterNumber
          : chapterNumber // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as ChapterStatus,
    ));
  }
}

/// Adds pattern-matching-related methods to [ChallengeDetailChapter].
extension ChallengeDetailChapterPatterns on ChallengeDetailChapter {
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
    TResult Function(_ChallengeDetailChapter value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ChallengeDetailChapter() when $default != null:
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
    TResult Function(_ChallengeDetailChapter value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChallengeDetailChapter():
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
    TResult? Function(_ChallengeDetailChapter value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChallengeDetailChapter() when $default != null:
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
    TResult Function(int chapterId, String title, int chapterNumber,
            ChapterStatus status)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ChallengeDetailChapter() when $default != null:
        return $default(
            _that.chapterId, _that.title, _that.chapterNumber, _that.status);
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
    TResult Function(int chapterId, String title, int chapterNumber,
            ChapterStatus status)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChallengeDetailChapter():
        return $default(
            _that.chapterId, _that.title, _that.chapterNumber, _that.status);
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
    TResult? Function(int chapterId, String title, int chapterNumber,
            ChapterStatus status)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChallengeDetailChapter() when $default != null:
        return $default(
            _that.chapterId, _that.title, _that.chapterNumber, _that.status);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _ChallengeDetailChapter implements ChallengeDetailChapter {
  const _ChallengeDetailChapter(
      {this.chapterId = 0,
      this.title = '',
      this.chapterNumber = 0,
      this.status = ChapterStatus.LOCKED});
  factory _ChallengeDetailChapter.fromJson(Map<String, dynamic> json) =>
      _$ChallengeDetailChapterFromJson(json);

  @override
  @JsonKey()
  final int chapterId;
  @override
  @JsonKey()
  final String title;
  @override
  @JsonKey()
  final int chapterNumber;
  @override
  @JsonKey()
  final ChapterStatus status;

  /// Create a copy of ChallengeDetailChapter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ChallengeDetailChapterCopyWith<_ChallengeDetailChapter> get copyWith =>
      __$ChallengeDetailChapterCopyWithImpl<_ChallengeDetailChapter>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ChallengeDetailChapterToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ChallengeDetailChapter &&
            (identical(other.chapterId, chapterId) ||
                other.chapterId == chapterId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.chapterNumber, chapterNumber) ||
                other.chapterNumber == chapterNumber) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, chapterId, title, chapterNumber, status);

  @override
  String toString() {
    return 'ChallengeDetailChapter(chapterId: $chapterId, title: $title, chapterNumber: $chapterNumber, status: $status)';
  }
}

/// @nodoc
abstract mixin class _$ChallengeDetailChapterCopyWith<$Res>
    implements $ChallengeDetailChapterCopyWith<$Res> {
  factory _$ChallengeDetailChapterCopyWith(_ChallengeDetailChapter value,
          $Res Function(_ChallengeDetailChapter) _then) =
      __$ChallengeDetailChapterCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int chapterId, String title, int chapterNumber, ChapterStatus status});
}

/// @nodoc
class __$ChallengeDetailChapterCopyWithImpl<$Res>
    implements _$ChallengeDetailChapterCopyWith<$Res> {
  __$ChallengeDetailChapterCopyWithImpl(this._self, this._then);

  final _ChallengeDetailChapter _self;
  final $Res Function(_ChallengeDetailChapter) _then;

  /// Create a copy of ChallengeDetailChapter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? chapterId = null,
    Object? title = null,
    Object? chapterNumber = null,
    Object? status = null,
  }) {
    return _then(_ChallengeDetailChapter(
      chapterId: null == chapterId
          ? _self.chapterId
          : chapterId // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      chapterNumber: null == chapterNumber
          ? _self.chapterNumber
          : chapterNumber // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as ChapterStatus,
    ));
  }
}

// dart format on
