import 'package:bookstar/modules/reading_challenge/model/challenge_detail_chapter.dart';
import 'package:bookstar/modules/reading_challenge/model/challenge_detail_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/learning_footprint.dart';
import '../data/learning_repository.dart';
import 'bs_ui.dart';
import 'library_widgets.dart';

final learningChaptersProvider = FutureProvider.autoDispose
    .family<ChallengeDetailResponse, int>((ref, id) async {
  return ref.watch(learningRepositoryProvider).getChapters(id);
});

/// 2.2 목차선택: progress, 진행 중인 목차 (퀴즈풀기) and 완료한 목차 (다시풀기).
class LearningChaptersScreen extends ConsumerWidget {
  const LearningChaptersScreen({super.key, required this.challengeId});
  final int challengeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) => LibraryPage(
        body: ref.watch(learningChaptersProvider(challengeId)).when(
              data: (data) => _content(context, ref, data),
              loading: () => const Center(
                  child: CircularProgressIndicator(color: Bs.primary)),
              error: (error, _) => Center(
                child: SingleChildScrollView(
                  padding: Bs.pagePadding,
                  child: BsEmptyState(
                    message: learningErrorMessage(error),
                    action: BsSecondaryButton(
                        label: '다시 불러오기',
                        expand: false,
                        onPressed: () => ref
                            .invalidate(learningChaptersProvider(challengeId))),
                  ),
                ),
              ),
            ),
      );

  Widget _content(
      BuildContext context, WidgetRef ref, ChallengeDetailResponse data) {
    final book = data.bookOverview;
    final done = data.chapters
        .where((chapter) => chapter.status == ChapterStatus.COMPLETED)
        .toList();
    final open = data.chapters
        .where((chapter) => chapter.status != ChapterStatus.COMPLETED)
        .toList();
    final percent = data.chapters.isEmpty
        ? 0
        : (done.length * 100 / data.chapters.length).round();
    Widget section(String title, List<ChallengeDetailChapter> chapters,
            {required bool completed}) =>
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LibrarySectionTitle(title),
            const SizedBox(height: 16),
            for (final (index, chapter) in chapters.indexed) ...[
              if (index > 0) const SizedBox(height: 6),
              _chapter(context, ref, chapter, completed: completed),
            ],
          ],
        );
    return ListView(
      padding: EdgeInsets.fromLTRB(
          16, 26, 16, 24 + MediaQuery.paddingOf(context).bottom),
      children: [
        LibraryBookHeader(
          title: libraryTitle(book.title),
          author: book.author,
          cover: book.cover,
          trailing: _ChaptersProgress(percent: percent),
        ),
        const SizedBox(height: 30),
        if (data.chapters.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 24),
            child: BsEmptyState(
                message: '지금 풀 수 있는 퀴즈가 없어요\n내 서재에서 다른 책을 선택해 주세요'),
          ),
        if (open.isNotEmpty) section('진행 중인 목차', open, completed: false),
        if (open.isNotEmpty && done.isNotEmpty) const SizedBox(height: 32),
        if (done.isNotEmpty) section('완료한 목차', done, completed: true),
      ],
    );
  }

  Widget _chapter(
      BuildContext context, WidgetRef ref, ChallengeDetailChapter chapter,
      {required bool completed}) {
    final action = completed ? '다시풀기' : '퀴즈풀기';
    void start() => _openChapter(context, ref, chapter.chapterId);
    return Semantics(
      container: true,
      button: true,
      enabled: true,
      label: '${chapter.title}, ${completed ? '완료한 목차' : '진행 중인 목차'}, $action',
      onTap: start,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: start,
        child: LibraryChapterRow(
          title: chapter.title,
          action: BsSmallButton(
              label: action, filled: !completed, onPressed: start),
        ),
      ),
    );
  }

  Future<void> _openChapter(
      BuildContext context, WidgetRef ref, int chapterId) async {
    await context.push('/library/$challengeId/quiz/$chapterId');
    if (!context.mounted) return;
    ref.invalidate(learningChaptersProvider(challengeId));
    ref.invalidate(learningBooksProvider);
    ref.invalidate(finishedLearningBooksProvider);
    ref.invalidate(learningFootprintProvider);
  }
}

/// 100pt bar and the grey "N% 진행" pill next to the book title.
class _ChaptersProgress extends StatelessWidget {
  const _ChaptersProgress({required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) => Semantics(
        label: '$percent% 진행',
        excludeSemantics: true,
        child: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              BsProgressBar(value: percent / 100, width: 100),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                    color: Bs.surface, borderRadius: BorderRadius.circular(6)),
                child: Text('$percent% 진행',
                    style: Bs.text(12,
                        weight: FontWeight.w600, color: BsProgressBar.fill)),
              ),
            ],
          ),
        ),
      );
}
