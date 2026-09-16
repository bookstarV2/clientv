import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/learning_footprint.dart';
import 'learning_design.dart';

enum FootprintCardStyle { books, numbers }

class FootprintStoryCard extends StatelessWidget {
  const FootprintStoryCard(
      {super.key,
      required this.footprint,
      required this.books,
      required this.showNumbers,
      required this.style});
  final LearningFootprint footprint;
  final List<FootprintBook> books;
  final bool showNumbers;
  final FootprintCardStyle style;

  @override
  Widget build(BuildContext context) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
      child: SizedBox(
          width: 360,
          height: 640,
          child: ColoredBox(
              color: LearningColors.paper,
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 42, 28, 32),
                  child: DefaultTextStyle(
                      style: const TextStyle(
                          fontFamily: 'Pretendard',
                          color: LearningColors.ink,
                          fontSize: 14,
                          height: 1.5),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(children: [
                              Icon(Icons.bookmark_outline_rounded,
                                  size: 16, color: LearningColors.primary),
                              SizedBox(width: 8),
                              Text('MY QUIZ RECORD',
                                  style: TextStyle(
                                      fontSize: 11,
                                      letterSpacing: 1.5,
                                      fontWeight: FontWeight.w600,
                                      color: LearningColors.primary)),
                            ]),
                            const SizedBox(height: 18),
                            const Divider(height: 1),
                            const SizedBox(height: 26),
                            Text(
                                style == FootprintCardStyle.numbers
                                    ? '지금까지,\n한 문제씩.'
                                    : '책을 덮고도,\n한 번 더.',
                                style: const TextStyle(
                                    fontSize: 36,
                                    height: 1.25,
                                    letterSpacing: -0.8,
                                    fontWeight: FontWeight.w600)),
                            const Spacer(),
                            if (style == FootprintCardStyle.books &&
                                books.isNotEmpty) ...[
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    for (var i = 0; i < books.length; i++) ...[
                                      if (i > 0) const SizedBox(width: 10),
                                      SizedBox(
                                          width: books.length == 1
                                              ? 128
                                              : books.length == 2
                                                  ? 120
                                                  : 94,
                                          child: Container(
                                              height:
                                                  books.length == 1 ? 174 : 144,
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 9, vertical: 16),
                                              decoration: BoxDecoration(
                                                  color: [
                                                    LearningColors.lavender,
                                                    const Color(0xFFE0E9E2),
                                                    const Color(0xFFEDE5D8)
                                                  ][i % 3],
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  boxShadow: const [
                                                    BoxShadow(
                                                        color:
                                                            Color(0x2028262C),
                                                        offset: Offset(2, 6),
                                                        blurRadius: 10)
                                                  ],
                                                  border: const Border(
                                                      left: BorderSide(
                                                          color:
                                                              Color(0xFFD2CCD9),
                                                          width: 3))),
                                              child: Text(books[i].title,
                                                  textAlign: TextAlign.left,
                                                  maxLines: 5,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontSize: books.length == 1
                                                          ? 18
                                                          : 13,
                                                      height: 1.45,
                                                      fontWeight: FontWeight.w600)))),
                                    ]
                                  ]),
                              const SizedBox(height: 12),
                              const Text('퀴즈를 풀어본 책 중 내가 고른 책',
                                  style: TextStyle(fontSize: 11)),
                            ] else if (showNumbers) ...[
                              FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                      NumberFormat.decimalPattern()
                                          .format(footprint.answeredQuizCount),
                                      style: const TextStyle(
                                          fontSize: 84,
                                          height: 1.1,
                                          color: LearningColors.primary,
                                          letterSpacing: -3,
                                          fontWeight: FontWeight.w500))),
                              const Text('지금까지 풀어본 퀴즈',
                                  style: TextStyle(fontSize: 15)),
                            ] else
                              const Text('읽었던 책을\n다시 떠올리는 시간.',
                                  style: TextStyle(fontSize: 22, height: 1.5)),
                            const Spacer(),
                            const Divider(height: 1),
                            const SizedBox(height: 16),
                            if (showNumbers) ...[
                              const Text('앱에 남아 있는 전체 퀴즈 기록',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: LearningColors.muted)),
                              if (style == FootprintCardStyle.books &&
                                  books.isNotEmpty)
                                Text(
                                    '풀어본 퀴즈 ${NumberFormat.decimalPattern().format(footprint.answeredQuizCount)}개'),
                              Text(
                                  '그중 다시 풀어본 퀴즈 ${NumberFormat.decimalPattern().format(footprint.reviewedQuizCount)}개'),
                              const SizedBox(height: 10),
                            ],
                            Text(
                                '앱에 보관된 기록 · ${DateFormat('yyyy.MM.dd').format(footprint.generatedAt.toLocal())}',
                                style: const TextStyle(
                                    fontSize: 10, color: LearningColors.muted)),
                            const Text('퀴즈 풀이 기록이며, 완독 인증은 아니에요.',
                                style: TextStyle(
                                    fontSize: 10, color: LearningColors.muted)),
                            const SizedBox(height: 16),
                            const Text('북스타 · 독서 퀴즈 기록',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: LearningColors.primary)),
                          ]))))));
}
