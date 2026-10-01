import 'package:bookstar/modules/learning/data/learning_access.dart';
import 'package:bookstar/modules/learning/data/learning_footprint.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final json = {
    'answeredQuizCount': 3,
    'reviewedQuizCount': 1,
    'bookCount': 1,
    'generatedAt': '2026-09-09T00:00:00Z',
    'scope': 'STORED_RECORDS'
  };

  test('footprint uses explicit stored scope and rejects inconsistent counts',
      () {
    expect(LearningFootprint.fromJson(json).answeredQuizCount, 3);
    expect(
        () => LearningFootprint.fromJson({...json, 'scope': 'ALL_KNOWLEDGE'}),
        throwsFormatException);
    expect(() => LearningFootprint.fromJson({...json, 'reviewedQuizCount': 4}),
        throwsFormatException);
    expect(() => LearningFootprint.fromJson({...json, 'bookCount': -1}),
        throwsFormatException);
    expect(learningReturnPath('/library/footprint'), '/library/footprint');
  });

  test('footprint reads the distinct chapter count for the library summary',
      () {
    expect(
        LearningFootprint.fromJson({...json, 'chapterCount': 2}).chapterCount,
        2);
    expect(LearningFootprint.fromJson(json).chapterCount, 0);
  });

  test('book page requires progressing pagination metadata', () {
    expect(
        () => FootprintBookPage.fromJson({
              'scope': 'STORED_RECORDS',
              'items': [],
              'hasNext': true,
              'totalCount': 10
            }),
        throwsFormatException);
  });
}
