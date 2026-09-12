import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../data/diary_archive_repository.dart';
import '../data/learning_repository.dart';
import 'learning_design.dart';

class LearningArchiveScreen extends ConsumerStatefulWidget {
  const LearningArchiveScreen({super.key});

  @override
  ConsumerState<LearningArchiveScreen> createState() =>
      _LearningArchiveScreenState();
}

class _LearningArchiveScreenState extends ConsumerState<LearningArchiveScreen> {
  List<DiaryArchiveItem> _items = [];
  bool _loading = true;
  bool _more = false;
  bool _hasNext = false;
  int? _cursor;
  int _version = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool more = false}) async {
    if (more && (_more || !_hasNext || _loading)) return;
    final version = more ? _version : ++_version;
    setState(() {
      _error = null;
      if (more) {
        _more = true;
      } else {
        _loading = true;
        _more = false;
      }
    });
    try {
      final page = await ref
          .read(diaryArchiveRepositoryProvider)
          .getPage(cursor: more ? _cursor : null);
      if (!mounted || version != _version) return;
      setState(() {
        _items = more ? [..._items, ...page.items] : page.items;
        _cursor = page.nextCursor;
        _hasNext = page.hasNext;
      });
    } catch (error) {
      if (mounted && version == _version) {
        setState(() => _error = _archiveError(error));
      }
    } finally {
      if (mounted && version == _version) {
        setState(() {
          _loading = false;
          _more = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => LearningPage(
      title: '나의 지난 독서 기록',
      child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              children: [
                const LearningLabel('내가 남긴 기록 보관함'),
                const SizedBox(height: 12),
                const Text('예전에 작성한 글을\n이곳에서 다시 읽어요.',
                    style: learningTitleStyle),
                const SizedBox(height: 12),
                const Text(
                    '본인이 작성한 기록만 모았어요.\n이 화면에서는 작성·수정·댓글을 제공하지 않아요.\n기존 글의 공개 설정은 바꾸지 않았어요.',
                    style: learningBodyStyle),
                const SizedBox(height: 24),
                if (_loading)
                  const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator()))
                else ...[
                  if (_items.isEmpty && _error == null)
                    const LearningEmpty(
                        title: '아직 지난 기록이 없어요',
                        message: '예전에 작성한 독서 기록이 있으면\n이곳에서 다시 볼 수 있어요.'),
                  ..._items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: LearningCard(
                          onTap: () =>
                              context.push('/settings/archive/${item.id}'),
                          label:
                              '${item.bookTitle}, ${_archiveDate(item.createdAt)}, '
                              '${item.content.trim().isEmpty ? '기록 내용 보기' : item.content}, '
                              '지난 기록 읽기',
                          excludeChildSemantics: true,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      BookCover(
                                          url: item.bookCover,
                                          title: item.bookTitle,
                                          width: 42),
                                      const SizedBox(width: 14),
                                      Expanded(
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                            Text(item.bookTitle,
                                                style: const TextStyle(
                                                    fontSize: 17,
                                                    height: 1.5,
                                                    fontWeight:
                                                        FontWeight.w700)),
                                            const SizedBox(height: 6),
                                            Text(_archiveDate(item.createdAt),
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        LearningColors.muted)),
                                          ])),
                                    ]),
                                const SizedBox(height: 14),
                                Text(
                                    item.content.trim().isEmpty
                                        ? '기록 내용 보기'
                                        : item.content,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: learningBodyStyle),
                              ])))),
                  if (_error != null)
                    LearningError(
                        message: _error!,
                        onRetry: () =>
                            _load(more: _items.isNotEmpty && _hasNext)),
                  if (_hasNext && _error == null)
                    TextButton(
                        onPressed: _more ? null : () => _load(more: true),
                        child: Text(_more ? '불러오는 중' : '지난 기록 더 보기')),
                ],
              ])));
}

final archiveDetailProvider = FutureProvider.autoDispose
    .family<DiaryArchiveItem, int>(
        (ref, id) => ref.watch(diaryArchiveRepositoryProvider).getDetail(id));

class LearningArchiveDetailScreen extends ConsumerWidget {
  const LearningArchiveDetailScreen({super.key, required this.diaryId});
  final int diaryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) => LearningPage(
      title: '지난 독서 기록',
      child: ref.watch(archiveDetailProvider(diaryId)).when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => SingleChildScrollView(
                child: LearningError(
                    message: _archiveError(error),
                    onRetry: () =>
                        ref.invalidate(archiveDetailProvider(diaryId)))),
            data: (item) =>
                ListView(padding: const EdgeInsets.all(20), children: [
              Text(item.bookTitle, style: learningTitleStyle),
              const SizedBox(height: 12),
              Text(_archiveDate(item.createdAt), style: learningBodyStyle),
              const SizedBox(height: 24),
              if (item.content.isNotEmpty)
                SelectableText(item.content,
                    style: const TextStyle(
                        fontSize: 17, height: 1.8, color: LearningColors.ink)),
              ...item.images.asMap().entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Semantics(
                      image: true,
                      label: '기록 사진 ${entry.key + 1}',
                      child: CachedNetworkImage(
                          imageUrl: entry.value,
                          fit: BoxFit.contain,
                          placeholder: (_, __) => const SizedBox(
                              height: 120,
                              child:
                                  Center(child: CircularProgressIndicator())),
                          errorWidget: (_, __, ___) => const Padding(
                              padding: EdgeInsets.all(20),
                              child: Text('사진을 불러오지 못했어요.',
                                  style: learningBodyStyle)))))),
              if (item.content.isEmpty && item.images.isEmpty)
                const LearningEmpty(
                    title: '내용이 비어 있는 기록이에요',
                    message: '이 기록에는 글이나 사진이 남아 있지 않아요.'),
              const SizedBox(height: 28),
              const Text('나의 지난 기록 · 읽기 전용',
                  style: TextStyle(fontSize: 12, color: LearningColors.muted)),
            ]),
          ));
}

String _archiveDate(DateTime? date) =>
    date == null ? '작성일 정보 없음' : DateFormat('yyyy년 M월 d일').format(date);

String _archiveError(Object error) {
  if (error is DioException && error.response?.statusCode == 404) {
    return '기록을 찾을 수 없어요. 본인이 작성한 기록만 열 수 있어요.';
  }
  return learningErrorMessage(error);
}
