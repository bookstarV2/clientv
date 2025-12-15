import 'package:freezed_annotation/freezed_annotation.dart';

part 'challenge_detail_chapter.freezed.dart';
part 'challenge_detail_chapter.g.dart';

enum ChapterStatus {
  COMPLETED,
  PROCESSING,
  LOCKED,
}

@freezed
abstract class ChallengeDetailChapter with _$ChallengeDetailChapter {
  const factory ChallengeDetailChapter({
    @Default(0) int chapterId,
    @Default('') String title,
    @Default(0) int chapterNumber,
    @Default(ChapterStatus.LOCKED) ChapterStatus status,
  }) = _ChallengeDetailChapter;

  factory ChallengeDetailChapter.fromJson(Map<String, dynamic> json) =>
      _$ChallengeDetailChapterFromJson(json);
}
