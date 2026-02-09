// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_book_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SearchBookResponse {
  int get bookId;
  String get title;
  String get bookCover;
  String get pubDate;
  String get author;
  String get publisher;
  bool get hasChallenge;
  bool get hasChapter;
  bool get hasQuiz;

  /// Create a copy of SearchBookResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SearchBookResponseCopyWith<SearchBookResponse> get copyWith =>
      _$SearchBookResponseCopyWithImpl<SearchBookResponse>(
          this as SearchBookResponse, _$identity);

  /// Serializes this SearchBookResponse to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SearchBookResponse &&
            (identical(other.bookId, bookId) || other.bookId == bookId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.bookCover, bookCover) ||
                other.bookCover == bookCover) &&
            (identical(other.pubDate, pubDate) || other.pubDate == pubDate) &&
            (identical(other.author, author) || other.author == author) &&
            (identical(other.publisher, publisher) ||
                other.publisher == publisher) &&
            (identical(other.hasChallenge, hasChallenge) ||
                other.hasChallenge == hasChallenge) &&
            (identical(other.hasChapter, hasChapter) ||
                other.hasChapter == hasChapter) &&
            (identical(other.hasQuiz, hasQuiz) || other.hasQuiz == hasQuiz));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, bookId, title, bookCover,
      pubDate, author, publisher, hasChallenge, hasChapter, hasQuiz);

  @override
  String toString() {
    return 'SearchBookResponse(bookId: $bookId, title: $title, bookCover: $bookCover, pubDate: $pubDate, author: $author, publisher: $publisher, hasChallenge: $hasChallenge, hasChapter: $hasChapter, hasQuiz: $hasQuiz)';
  }
}

/// @nodoc
abstract mixin class $SearchBookResponseCopyWith<$Res> {
  factory $SearchBookResponseCopyWith(
          SearchBookResponse value, $Res Function(SearchBookResponse) _then) =
      _$SearchBookResponseCopyWithImpl;
  @useResult
  $Res call(
      {int bookId,
      String title,
      String bookCover,
      String pubDate,
      String author,
      String publisher,
      bool hasChallenge,
      bool hasChapter,
      bool hasQuiz});
}

/// @nodoc
class _$SearchBookResponseCopyWithImpl<$Res>
    implements $SearchBookResponseCopyWith<$Res> {
  _$SearchBookResponseCopyWithImpl(this._self, this._then);

  final SearchBookResponse _self;
  final $Res Function(SearchBookResponse) _then;

  /// Create a copy of SearchBookResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bookId = null,
    Object? title = null,
    Object? bookCover = null,
    Object? pubDate = null,
    Object? author = null,
    Object? publisher = null,
    Object? hasChallenge = null,
    Object? hasChapter = null,
    Object? hasQuiz = null,
  }) {
    return _then(_self.copyWith(
      bookId: null == bookId
          ? _self.bookId
          : bookId // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      bookCover: null == bookCover
          ? _self.bookCover
          : bookCover // ignore: cast_nullable_to_non_nullable
              as String,
      pubDate: null == pubDate
          ? _self.pubDate
          : pubDate // ignore: cast_nullable_to_non_nullable
              as String,
      author: null == author
          ? _self.author
          : author // ignore: cast_nullable_to_non_nullable
              as String,
      publisher: null == publisher
          ? _self.publisher
          : publisher // ignore: cast_nullable_to_non_nullable
              as String,
      hasChallenge: null == hasChallenge
          ? _self.hasChallenge
          : hasChallenge // ignore: cast_nullable_to_non_nullable
              as bool,
      hasChapter: null == hasChapter
          ? _self.hasChapter
          : hasChapter // ignore: cast_nullable_to_non_nullable
              as bool,
      hasQuiz: null == hasQuiz
          ? _self.hasQuiz
          : hasQuiz // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [SearchBookResponse].
extension SearchBookResponsePatterns on SearchBookResponse {
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
    TResult Function(_SearchBookResponse value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SearchBookResponse() when $default != null:
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
    TResult Function(_SearchBookResponse value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SearchBookResponse():
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
    TResult? Function(_SearchBookResponse value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SearchBookResponse() when $default != null:
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
            int bookId,
            String title,
            String bookCover,
            String pubDate,
            String author,
            String publisher,
            bool hasChallenge,
            bool hasChapter,
            bool hasQuiz)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SearchBookResponse() when $default != null:
        return $default(
            _that.bookId,
            _that.title,
            _that.bookCover,
            _that.pubDate,
            _that.author,
            _that.publisher,
            _that.hasChallenge,
            _that.hasChapter,
            _that.hasQuiz);
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
            int bookId,
            String title,
            String bookCover,
            String pubDate,
            String author,
            String publisher,
            bool hasChallenge,
            bool hasChapter,
            bool hasQuiz)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SearchBookResponse():
        return $default(
            _that.bookId,
            _that.title,
            _that.bookCover,
            _that.pubDate,
            _that.author,
            _that.publisher,
            _that.hasChallenge,
            _that.hasChapter,
            _that.hasQuiz);
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
            int bookId,
            String title,
            String bookCover,
            String pubDate,
            String author,
            String publisher,
            bool hasChallenge,
            bool hasChapter,
            bool hasQuiz)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SearchBookResponse() when $default != null:
        return $default(
            _that.bookId,
            _that.title,
            _that.bookCover,
            _that.pubDate,
            _that.author,
            _that.publisher,
            _that.hasChallenge,
            _that.hasChapter,
            _that.hasQuiz);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _SearchBookResponse implements SearchBookResponse {
  const _SearchBookResponse(
      {this.bookId = 0,
      this.title = '',
      this.bookCover = '',
      this.pubDate = '',
      this.author = '',
      this.publisher = '',
      this.hasChallenge = false,
      this.hasChapter = false,
      this.hasQuiz = false});
  factory _SearchBookResponse.fromJson(Map<String, dynamic> json) =>
      _$SearchBookResponseFromJson(json);

  @override
  @JsonKey()
  final int bookId;
  @override
  @JsonKey()
  final String title;
  @override
  @JsonKey()
  final String bookCover;
  @override
  @JsonKey()
  final String pubDate;
  @override
  @JsonKey()
  final String author;
  @override
  @JsonKey()
  final String publisher;
  @override
  @JsonKey()
  final bool hasChallenge;
  @override
  @JsonKey()
  final bool hasChapter;
  @override
  @JsonKey()
  final bool hasQuiz;

  /// Create a copy of SearchBookResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SearchBookResponseCopyWith<_SearchBookResponse> get copyWith =>
      __$SearchBookResponseCopyWithImpl<_SearchBookResponse>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SearchBookResponseToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SearchBookResponse &&
            (identical(other.bookId, bookId) || other.bookId == bookId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.bookCover, bookCover) ||
                other.bookCover == bookCover) &&
            (identical(other.pubDate, pubDate) || other.pubDate == pubDate) &&
            (identical(other.author, author) || other.author == author) &&
            (identical(other.publisher, publisher) ||
                other.publisher == publisher) &&
            (identical(other.hasChallenge, hasChallenge) ||
                other.hasChallenge == hasChallenge) &&
            (identical(other.hasChapter, hasChapter) ||
                other.hasChapter == hasChapter) &&
            (identical(other.hasQuiz, hasQuiz) || other.hasQuiz == hasQuiz));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, bookId, title, bookCover,
      pubDate, author, publisher, hasChallenge, hasChapter, hasQuiz);

  @override
  String toString() {
    return 'SearchBookResponse(bookId: $bookId, title: $title, bookCover: $bookCover, pubDate: $pubDate, author: $author, publisher: $publisher, hasChallenge: $hasChallenge, hasChapter: $hasChapter, hasQuiz: $hasQuiz)';
  }
}

/// @nodoc
abstract mixin class _$SearchBookResponseCopyWith<$Res>
    implements $SearchBookResponseCopyWith<$Res> {
  factory _$SearchBookResponseCopyWith(
          _SearchBookResponse value, $Res Function(_SearchBookResponse) _then) =
      __$SearchBookResponseCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int bookId,
      String title,
      String bookCover,
      String pubDate,
      String author,
      String publisher,
      bool hasChallenge,
      bool hasChapter,
      bool hasQuiz});
}

/// @nodoc
class __$SearchBookResponseCopyWithImpl<$Res>
    implements _$SearchBookResponseCopyWith<$Res> {
  __$SearchBookResponseCopyWithImpl(this._self, this._then);

  final _SearchBookResponse _self;
  final $Res Function(_SearchBookResponse) _then;

  /// Create a copy of SearchBookResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? bookId = null,
    Object? title = null,
    Object? bookCover = null,
    Object? pubDate = null,
    Object? author = null,
    Object? publisher = null,
    Object? hasChallenge = null,
    Object? hasChapter = null,
    Object? hasQuiz = null,
  }) {
    return _then(_SearchBookResponse(
      bookId: null == bookId
          ? _self.bookId
          : bookId // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      bookCover: null == bookCover
          ? _self.bookCover
          : bookCover // ignore: cast_nullable_to_non_nullable
              as String,
      pubDate: null == pubDate
          ? _self.pubDate
          : pubDate // ignore: cast_nullable_to_non_nullable
              as String,
      author: null == author
          ? _self.author
          : author // ignore: cast_nullable_to_non_nullable
              as String,
      publisher: null == publisher
          ? _self.publisher
          : publisher // ignore: cast_nullable_to_non_nullable
              as String,
      hasChallenge: null == hasChallenge
          ? _self.hasChallenge
          : hasChallenge // ignore: cast_nullable_to_non_nullable
              as bool,
      hasChapter: null == hasChapter
          ? _self.hasChapter
          : hasChapter // ignore: cast_nullable_to_non_nullable
              as bool,
      hasQuiz: null == hasQuiz
          ? _self.hasQuiz
          : hasQuiz // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
