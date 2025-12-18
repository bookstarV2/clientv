// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ranking_weekly_top3_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RankingWeeklyTop3Response {
  int get rank;
  int get memberId;
  String get nickname;
  String get profileImage;
  int get participationDays;
  int get solvedCount;
  int get correctCount;
  bool get myRank;

  /// Create a copy of RankingWeeklyTop3Response
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RankingWeeklyTop3ResponseCopyWith<RankingWeeklyTop3Response> get copyWith =>
      _$RankingWeeklyTop3ResponseCopyWithImpl<RankingWeeklyTop3Response>(
          this as RankingWeeklyTop3Response, _$identity);

  /// Serializes this RankingWeeklyTop3Response to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RankingWeeklyTop3Response &&
            (identical(other.rank, rank) || other.rank == rank) &&
            (identical(other.memberId, memberId) ||
                other.memberId == memberId) &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname) &&
            (identical(other.profileImage, profileImage) ||
                other.profileImage == profileImage) &&
            (identical(other.participationDays, participationDays) ||
                other.participationDays == participationDays) &&
            (identical(other.solvedCount, solvedCount) ||
                other.solvedCount == solvedCount) &&
            (identical(other.correctCount, correctCount) ||
                other.correctCount == correctCount) &&
            (identical(other.myRank, myRank) || other.myRank == myRank));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, rank, memberId, nickname,
      profileImage, participationDays, solvedCount, correctCount, myRank);

  @override
  String toString() {
    return 'RankingWeeklyTop3Response(rank: $rank, memberId: $memberId, nickname: $nickname, profileImage: $profileImage, participationDays: $participationDays, solvedCount: $solvedCount, correctCount: $correctCount, myRank: $myRank)';
  }
}

/// @nodoc
abstract mixin class $RankingWeeklyTop3ResponseCopyWith<$Res> {
  factory $RankingWeeklyTop3ResponseCopyWith(RankingWeeklyTop3Response value,
          $Res Function(RankingWeeklyTop3Response) _then) =
      _$RankingWeeklyTop3ResponseCopyWithImpl;
  @useResult
  $Res call(
      {int rank,
      int memberId,
      String nickname,
      String profileImage,
      int participationDays,
      int solvedCount,
      int correctCount,
      bool myRank});
}

/// @nodoc
class _$RankingWeeklyTop3ResponseCopyWithImpl<$Res>
    implements $RankingWeeklyTop3ResponseCopyWith<$Res> {
  _$RankingWeeklyTop3ResponseCopyWithImpl(this._self, this._then);

  final RankingWeeklyTop3Response _self;
  final $Res Function(RankingWeeklyTop3Response) _then;

  /// Create a copy of RankingWeeklyTop3Response
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rank = null,
    Object? memberId = null,
    Object? nickname = null,
    Object? profileImage = null,
    Object? participationDays = null,
    Object? solvedCount = null,
    Object? correctCount = null,
    Object? myRank = null,
  }) {
    return _then(_self.copyWith(
      rank: null == rank
          ? _self.rank
          : rank // ignore: cast_nullable_to_non_nullable
              as int,
      memberId: null == memberId
          ? _self.memberId
          : memberId // ignore: cast_nullable_to_non_nullable
              as int,
      nickname: null == nickname
          ? _self.nickname
          : nickname // ignore: cast_nullable_to_non_nullable
              as String,
      profileImage: null == profileImage
          ? _self.profileImage
          : profileImage // ignore: cast_nullable_to_non_nullable
              as String,
      participationDays: null == participationDays
          ? _self.participationDays
          : participationDays // ignore: cast_nullable_to_non_nullable
              as int,
      solvedCount: null == solvedCount
          ? _self.solvedCount
          : solvedCount // ignore: cast_nullable_to_non_nullable
              as int,
      correctCount: null == correctCount
          ? _self.correctCount
          : correctCount // ignore: cast_nullable_to_non_nullable
              as int,
      myRank: null == myRank
          ? _self.myRank
          : myRank // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [RankingWeeklyTop3Response].
extension RankingWeeklyTop3ResponsePatterns on RankingWeeklyTop3Response {
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
    TResult Function(_RankingWeeklyTop3Response value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RankingWeeklyTop3Response() when $default != null:
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
    TResult Function(_RankingWeeklyTop3Response value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RankingWeeklyTop3Response():
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
    TResult? Function(_RankingWeeklyTop3Response value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RankingWeeklyTop3Response() when $default != null:
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
            int rank,
            int memberId,
            String nickname,
            String profileImage,
            int participationDays,
            int solvedCount,
            int correctCount,
            bool myRank)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RankingWeeklyTop3Response() when $default != null:
        return $default(
            _that.rank,
            _that.memberId,
            _that.nickname,
            _that.profileImage,
            _that.participationDays,
            _that.solvedCount,
            _that.correctCount,
            _that.myRank);
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
            int rank,
            int memberId,
            String nickname,
            String profileImage,
            int participationDays,
            int solvedCount,
            int correctCount,
            bool myRank)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RankingWeeklyTop3Response():
        return $default(
            _that.rank,
            _that.memberId,
            _that.nickname,
            _that.profileImage,
            _that.participationDays,
            _that.solvedCount,
            _that.correctCount,
            _that.myRank);
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
            int rank,
            int memberId,
            String nickname,
            String profileImage,
            int participationDays,
            int solvedCount,
            int correctCount,
            bool myRank)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RankingWeeklyTop3Response() when $default != null:
        return $default(
            _that.rank,
            _that.memberId,
            _that.nickname,
            _that.profileImage,
            _that.participationDays,
            _that.solvedCount,
            _that.correctCount,
            _that.myRank);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _RankingWeeklyTop3Response implements RankingWeeklyTop3Response {
  const _RankingWeeklyTop3Response(
      {this.rank = -1,
      this.memberId = -1,
      this.nickname = "",
      this.profileImage = "",
      this.participationDays = -1,
      this.solvedCount = -1,
      this.correctCount = -1,
      this.myRank = false});
  factory _RankingWeeklyTop3Response.fromJson(Map<String, dynamic> json) =>
      _$RankingWeeklyTop3ResponseFromJson(json);

  @override
  @JsonKey()
  final int rank;
  @override
  @JsonKey()
  final int memberId;
  @override
  @JsonKey()
  final String nickname;
  @override
  @JsonKey()
  final String profileImage;
  @override
  @JsonKey()
  final int participationDays;
  @override
  @JsonKey()
  final int solvedCount;
  @override
  @JsonKey()
  final int correctCount;
  @override
  @JsonKey()
  final bool myRank;

  /// Create a copy of RankingWeeklyTop3Response
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$RankingWeeklyTop3ResponseCopyWith<_RankingWeeklyTop3Response>
      get copyWith =>
          __$RankingWeeklyTop3ResponseCopyWithImpl<_RankingWeeklyTop3Response>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$RankingWeeklyTop3ResponseToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _RankingWeeklyTop3Response &&
            (identical(other.rank, rank) || other.rank == rank) &&
            (identical(other.memberId, memberId) ||
                other.memberId == memberId) &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname) &&
            (identical(other.profileImage, profileImage) ||
                other.profileImage == profileImage) &&
            (identical(other.participationDays, participationDays) ||
                other.participationDays == participationDays) &&
            (identical(other.solvedCount, solvedCount) ||
                other.solvedCount == solvedCount) &&
            (identical(other.correctCount, correctCount) ||
                other.correctCount == correctCount) &&
            (identical(other.myRank, myRank) || other.myRank == myRank));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, rank, memberId, nickname,
      profileImage, participationDays, solvedCount, correctCount, myRank);

  @override
  String toString() {
    return 'RankingWeeklyTop3Response(rank: $rank, memberId: $memberId, nickname: $nickname, profileImage: $profileImage, participationDays: $participationDays, solvedCount: $solvedCount, correctCount: $correctCount, myRank: $myRank)';
  }
}

/// @nodoc
abstract mixin class _$RankingWeeklyTop3ResponseCopyWith<$Res>
    implements $RankingWeeklyTop3ResponseCopyWith<$Res> {
  factory _$RankingWeeklyTop3ResponseCopyWith(_RankingWeeklyTop3Response value,
          $Res Function(_RankingWeeklyTop3Response) _then) =
      __$RankingWeeklyTop3ResponseCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int rank,
      int memberId,
      String nickname,
      String profileImage,
      int participationDays,
      int solvedCount,
      int correctCount,
      bool myRank});
}

/// @nodoc
class __$RankingWeeklyTop3ResponseCopyWithImpl<$Res>
    implements _$RankingWeeklyTop3ResponseCopyWith<$Res> {
  __$RankingWeeklyTop3ResponseCopyWithImpl(this._self, this._then);

  final _RankingWeeklyTop3Response _self;
  final $Res Function(_RankingWeeklyTop3Response) _then;

  /// Create a copy of RankingWeeklyTop3Response
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? rank = null,
    Object? memberId = null,
    Object? nickname = null,
    Object? profileImage = null,
    Object? participationDays = null,
    Object? solvedCount = null,
    Object? correctCount = null,
    Object? myRank = null,
  }) {
    return _then(_RankingWeeklyTop3Response(
      rank: null == rank
          ? _self.rank
          : rank // ignore: cast_nullable_to_non_nullable
              as int,
      memberId: null == memberId
          ? _self.memberId
          : memberId // ignore: cast_nullable_to_non_nullable
              as int,
      nickname: null == nickname
          ? _self.nickname
          : nickname // ignore: cast_nullable_to_non_nullable
              as String,
      profileImage: null == profileImage
          ? _self.profileImage
          : profileImage // ignore: cast_nullable_to_non_nullable
              as String,
      participationDays: null == participationDays
          ? _self.participationDays
          : participationDays // ignore: cast_nullable_to_non_nullable
              as int,
      solvedCount: null == solvedCount
          ? _self.solvedCount
          : solvedCount // ignore: cast_nullable_to_non_nullable
              as int,
      correctCount: null == correctCount
          ? _self.correctCount
          : correctCount // ignore: cast_nullable_to_non_nullable
              as int,
      myRank: null == myRank
          ? _self.myRank
          : myRank // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
