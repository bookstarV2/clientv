import 'package:bookstar/modules/reading_challenge/model/challenge_detail_chapter.dart';
import 'package:bookstar/modules/reading_challenge/model/challenge_detail_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'learning_design.dart';
import '../data/learning_repository.dart';

final learningChaptersProvider = FutureProvider.autoDispose
    .family<ChallengeDetailResponse, int>((ref, id) async {
  return ref.watch(learningRepositoryProvider).getChapters(id);
});

class LearningChaptersScreen extends ConsumerWidget {
  const LearningChaptersScreen({super.key, required this.challengeId});
  final int challengeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) => LearningPage(
        title: '읽은 목차 선택',
        child: ref.watch(learningChaptersProvider(challengeId)).when(
              data: (data) => ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                children: [
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    BookCover(
                        url: data.bookOverview.cover,
                        title: data.bookOverview.title,
                        width: 62),
                    const SizedBox(width: 16),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(data.bookOverview.title,
                              style: const TextStyle(
                                  fontSize: 20,
                                  height: 1.4,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          Text(data.bookOverview.author,
                              style: learningBodyStyle),
                        ])),
                  ]),
                  const SizedBox(height: 28),
                  const Text('어디까지 읽었나요?',
                      style:
                          TextStyle(fontSize: 23, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  const Text('읽은 목차를 누르면 바로 한 문제가 시작돼요.\n순서대로 읽지 않아도 괜찮아요.',
                      style: learningBodyStyle),
                  const SizedBox(height: 22),
                  if (data.chapters.isEmpty)
                    const LearningEmpty(
                      title: '지금 풀 수 있는 퀴즈가 없어요',
                      message: '제공 가능한 문항이 아직 없어요.\n내 서재에서 다른 책을 선택해 주세요.',
                    ),
                  ...data.chapters.map((chapter) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Semantics(
                          button: true,
                          enabled: true,
                          label: '${chapter.title}, '
                              '${chapter.status == ChapterStatus.COMPLETED ? '퀴즈를 풀어본 목차, 다시 떠올리기' : '아직 풀지 않은 목차, 한 문제 풀기'}',
                          onTap: () =>
                              _openChapter(context, ref, chapter.chapterId),
                          excludeSemantics: true,
                          child: LearningCard(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 18),
                            onTap: () =>
                                _openChapter(context, ref, chapter.chapterId),
                            child: Row(children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color:
                                      chapter.status == ChapterStatus.COMPLETED
                                          ? LearningColors.greenSoft
                                          : LearningColors.lavender,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.center,
                                child: chapter.status == ChapterStatus.COMPLETED
                                    ? const Icon(Icons.check_rounded,
                                        color: LearningColors.green, size: 20)
                                    : Text(
                                        '${data.chapters.indexOf(chapter) + 1}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: LearningColors.primary)),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    Text(chapter.title,
                                        style: const TextStyle(
                                            fontSize: 15,
                                            height: 1.5,
                                            fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 5),
                                    Text(
                                        chapter.status ==
                                                ChapterStatus.COMPLETED
                                            ? '다시 떠올리기'
                                            : '한 문제 풀기',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: LearningColors.muted)),
                                  ])),
                              const SizedBox(width: 8),
                              const Icon(Icons.chevron_right_rounded,
                                  color: LearningColors.muted),
                            ]),
                          ),
                        ),
                      )),
                  const SizedBox(height: 12),
                  const Text('체크 표시는 퀴즈를 풀어본 목차예요.\n이해도나 기억력을 평가하는 점수는 아니에요.',
                      style: TextStyle(
                          fontSize: 12,
                          height: 1.6,
                          color: LearningColors.muted)),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => SingleChildScrollView(
                  child: LearningError(
                      onRetry: () => ref
                          .invalidate(learningChaptersProvider(challengeId)))),
            ),
      );

  Future<void> _openChapter(
      BuildContext context, WidgetRef ref, int chapterId) async {
    await context.push('/library/$challengeId/quiz/$chapterId');
    if (!context.mounted) return;
    ref.invalidate(learningChaptersProvider(challengeId));
  }
}
