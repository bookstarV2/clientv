import 'dart:math' as math;

import 'package:bookstar/modules/reading_challenge/model/challenge_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/learning_repository.dart';
import '../data/library_layout.dart';
import 'learning_design.dart';

class LearningLibraryScreen extends ConsumerStatefulWidget {
  const LearningLibraryScreen({super.key});

  @override
  ConsumerState<LearningLibraryScreen> createState() =>
      _LearningLibraryScreenState();
}

class _LearningLibraryScreenState extends ConsumerState<LearningLibraryScreen> {
  bool _finished = false;

  @override
  Widget build(BuildContext context) {
    final provider =
        _finished ? finishedLearningBooksProvider : learningBooksProvider;
    final books = ref.watch(provider);
    final preference = ref.watch(libraryLayoutProvider);
    return LayoutBuilder(builder: (context, constraints) {
      final width = math.max(0.0, constraints.maxWidth - 40);
      final layout = effectiveLibraryLayout(preference.preferred,
          availableWidth: width,
          textScaler: MediaQuery.textScalerOf(context),
          textDirection: Directionality.of(context),
          fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily);
      return RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(provider);
          try {
            await ref.read(provider.future);
          } catch (_) {
            // The provider below displays a retry action.
          }
        },
        child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  sliver:
                      SliverToBoxAdapter(child: _header(preference, layout))),
              books.when(
                data: (items) => items.isEmpty
                    ? SliverToBoxAdapter(
                        child: LearningEmpty(
                        title: _finished ? '아직 퀴즈를 마친 책이 없어요' : '책을 담아 볼까요?',
                        message: _finished
                            ? '모든 목차의 퀴즈를 풀면 여기서\n다시 펼쳐볼 수 있어요.'
                            : '지금 읽고 있거나, 다시 기억하고 싶은\n책을 찾아 추가해 주세요.',
                      ))
                    : _books(items, layout, width),
                loading: () => const SliverToBoxAdapter(
                    child: Padding(
                        padding: EdgeInsets.all(50),
                        child: Center(child: CircularProgressIndicator()))),
                error: (_, __) => SliverToBoxAdapter(
                    child:
                        LearningError(onRetry: () => ref.invalidate(provider))),
              ),
            ]),
      );
    });
  }

  Widget _header(LibraryLayoutPreference preference, LibraryLayout layout) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: LearningColors.surface,
                  foregroundColor: LearningColors.ink,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                ),
                onPressed: () => context.push('/library/search'),
                icon: const Icon(Icons.search_rounded),
                label: const Text('책 찾아서 추가하기'))),
        const SizedBox(height: 8),
        SizedBox(
            width: double.infinity,
            child: Wrap(
                spacing: 8,
                runSpacing: 4,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                      style: TextButton.styleFrom(
                          foregroundColor: LearningColors.ink,
                          padding: const EdgeInsets.symmetric(horizontal: 4)),
                      onPressed: () => context.push('/library/footprint'),
                      icon: const Icon(Icons.auto_stories_outlined, size: 20),
                      label: const Text('나의 독서 흔적')),
                  OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                          side: BorderSide.none,
                          padding: const EdgeInsets.symmetric(horizontal: 8)),
                      onPressed: _chooseLayout,
                      icon: Icon(
                          layout == LibraryLayout.list
                              ? Icons.view_list_outlined
                              : Icons.grid_view_rounded,
                          size: 20),
                      label: Text('보기: ${layout.label}')),
                ])),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: [
          ChoiceChip(
              label: const Text('읽고 있는 책'),
              selected: !_finished,
              showCheckmark: false,
              onSelected: (_) => setState(() => _finished = false)),
          ChoiceChip(
              label: const Text('퀴즈를 마친 책'),
              selected: _finished,
              showCheckmark: false,
              onSelected: (_) => setState(() => _finished = true)),
        ]),
        if (layout != preference.preferred) ...[
          const SizedBox(height: 12),
          Text(
              '글자 크기와 화면 폭에 맞춰 ${layout.label}${layout == LibraryLayout.list ? '으로' : '로'} 보여드려요. '
              '선택한 ${preference.preferred.label} 보기는 유지돼요.',
              style:
                  const TextStyle(fontSize: 12, color: LearningColors.muted)),
        ],
        if (preference.notice != null) ...[
          const SizedBox(height: 12),
          Text(preference.notice!,
              style:
                  const TextStyle(fontSize: 12, color: LearningColors.muted)),
        ],
      ]);

  Future<void> _chooseLayout() async {
    final selected = await showModalBottomSheet<LibraryLayout>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (context) => SafeArea(
            child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('서재 보기', style: learningTitleStyle),
                      const SizedBox(height: 12),
                      for (final layout in LibraryLayout.values)
                        RadioListTile<LibraryLayout>(
                            contentPadding: EdgeInsets.zero,
                            value: layout,
                            groupValue:
                                ref.read(libraryLayoutProvider).preferred,
                            title: Text(layout.label),
                            subtitle: Text(layout.description),
                            onChanged: (value) =>
                                Navigator.of(context).pop(value)),
                    ]))));
    if (selected != null && mounted) {
      await ref.read(libraryLayoutProvider.notifier).select(selected);
    }
  }

  Widget _books(
      List<ChallengeResponse> items, LibraryLayout layout, double width) {
    if (layout == LibraryLayout.list) {
      return SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
          sliver: SliverList.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Divider(height: 1)),
              itemBuilder: (context, index) => _listBook(items[index])));
    }
    final cellWidth =
        (width - libraryGridGap * (layout.columns - 1)) / layout.columns;
    final coverWidth = math.min(cellWidth - libraryGridPadding * 2, 140.0);
    final height = libraryGridPadding * 2 +
        coverWidth * 1.45 +
        10 +
        _lineHeight(libraryGridTitleStyle) * 2 +
        (layout == LibraryLayout.twoColumns
            ? 6 + _lineHeight(_authorStyle)
            : 0);
    return SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: layout.columns,
                crossAxisSpacing: libraryGridGap,
                mainAxisSpacing: libraryGridGap,
                mainAxisExtent: height),
            delegate: SliverChildBuilderDelegate(
                (context, index) => _gridBook(items[index], layout, coverWidth),
                childCount: items.length)));
  }

  double _lineHeight(TextStyle style) {
    final painter = TextPainter(
        text: TextSpan(
            text: '책',
            style: style.copyWith(
                fontFamily:
                    Theme.of(context).textTheme.bodyMedium?.fontFamily)),
        textScaler: MediaQuery.textScalerOf(context),
        textDirection: Directionality.of(context))
      ..layout();
    final height = painter.height;
    painter.dispose();
    return height;
  }

  static const _authorStyle =
      TextStyle(fontSize: 12, height: 1.4, color: LearningColors.muted);
  String _title(ChallengeResponse book) =>
      book.bookTitle.trim().isEmpty ? '제목 없는 책' : book.bookTitle;

  Widget _card(ChallengeResponse book, Widget child,
          {EdgeInsets padding = const EdgeInsets.all(20)}) =>
      Tooltip(
          excludeFromSemantics: true,
          message: _title(book),
          child: LearningCard(
              flat: true,
              key: ValueKey('library-book-${book.challengeId}'),
              onTap: () =>
                  context.push('/library/${book.challengeId}/chapters'),
              label:
                  '${_title(book)}, ${book.bookAuthor.trim().isEmpty ? '' : '${book.bookAuthor}, '}'
                  '${_finished ? '퀴즈를 마친 책' : '읽고 있는 책'}, 목차 열기',
              excludeChildSemantics: true,
              padding: padding,
              child: child));

  Widget _listBook(ChallengeResponse book) => _card(
      book,
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        BookCover(url: book.bookImageUrl, title: _title(book)),
        const SizedBox(width: 16),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_title(book),
              style: const TextStyle(
                  fontSize: 16, height: 1.4, fontWeight: FontWeight.w700)),
          if (book.bookAuthor.trim().isNotEmpty) ...[
            const SizedBox(height: 7),
            Text(book.bookAuthor, style: _authorStyle),
          ],
          const SizedBox(height: 12),
          LearningLabel(_finished ? '다시 펼쳐보기' : '목차 퀴즈 풀기',
              color: LearningColors.primary),
        ])),
      ]),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4));

  Widget _gridBook(
          ChallengeResponse book, LibraryLayout layout, double coverWidth) =>
      _card(
          book,
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(
                child: BookCover(
                    url: book.bookImageUrl,
                    title: _title(book),
                    width: coverWidth)),
            const SizedBox(height: 10),
            Text(_title(book),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: libraryGridTitleStyle),
            if (layout == LibraryLayout.twoColumns) ...[
              const SizedBox(height: 6),
              Text(book.bookAuthor,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _authorStyle),
            ],
          ]),
          padding: const EdgeInsets.all(libraryGridPadding));
}
