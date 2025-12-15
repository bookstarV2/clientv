import 'package:freezed_annotation/freezed_annotation.dart';

part 'challenge_detail_book_overview.freezed.dart';
part 'challenge_detail_book_overview.g.dart';

@freezed
abstract class ChallengeDetailBookOverview with _$ChallengeDetailBookOverview {
  const factory ChallengeDetailBookOverview({
    @Default(-1) int id,
    @Default('') String title,
    @Default('') String author,
    @Default('') String cover,
    @Default(-1) int readingDiaryCount,
    @Default('') String isbn,
    @Default('') String publisher,
    @Default('') String publishedDate,
    @Default('') String aladinUrl,
    @Default(-1) int star,
    @Default(-1) int starFromMe,
    @Default(false) bool liked,
  }) = _ChallengeDetailBookOverview;

  factory ChallengeDetailBookOverview.fromJson(Map<String, dynamic> json) =>
      _$ChallengeDetailBookOverviewFromJson(json);
}
