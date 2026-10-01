import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../data/diary_archive_repository.dart';
import '../data/learning_repository.dart';
import 'bs_ui.dart';

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
  Widget build(BuildContext context) => BsScaffold(
        title: '나의 지난 독서 기록',
        showBack: true,
        body: RefreshIndicator(
          color: Bs.primary,
          onRefresh: _load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
            children: [
              Text('내가 남긴 기록 보관함', style: Bs.text(14, color: Bs.g3)),
              const SizedBox(height: 8),
              Text('예전에 작성한 글을\n이곳에서 다시 읽어요.', style: Bs.title),
              const SizedBox(height: 12),
              Text(
                  '본인이 작성한 기록만 모았어요.\n이 화면에서는 작성·수정·댓글을 제공하지 않아요.\n기존 글의 공개 설정은 바꾸지 않았어요.',
                  style: Bs.text(14, color: Bs.g3, height: 1.5)),
              const SizedBox(height: 24),
              if (_loading)
                const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                        child: CircularProgressIndicator(color: Bs.primary)))
              else ...[
                if (_items.isEmpty && _error == null) const _ArchiveEmpty(),
                for (final item in _items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ArchiveCard(
                        item: item,
                        onTap: () =>
                            context.push('/settings/archive/${item.id}')),
                  ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: BsEmptyState(
                      message: _error!,
                      action: BsPrimaryButton(
                          label: '다시 불러오기',
                          onPressed: () =>
                              _load(more: _items.isNotEmpty && _hasNext)),
                    ),
                  ),
                if (_hasNext && _error == null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: BsSecondaryButton(
                        label: _more ? '불러오는 중' : '지난 기록 더 보기',
                        onPressed: _more ? null : () => _load(more: true)),
                  ),
              ],
            ],
          ),
        ),
      );
}

class _ArchiveCard extends StatelessWidget {
  const _ArchiveCard({required this.item, required this.onTap});

  final DiaryArchiveItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final preview = item.content.trim().isEmpty ? '기록 내용 보기' : item.content;
    return Semantics(
      button: true,
      enabled: true,
      onTap: onTap,
      label:
          '${item.bookTitle}, ${_archiveDate(item.createdAt)}, $preview, 지난 기록 읽기',
      excludeSemantics: true,
      child: Material(
        color: Bs.white,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BsBookCover(
                        url: item.bookCover, title: item.bookTitle, width: 42),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.bookTitle,
                              style: Bs.text(16, weight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(_archiveDate(item.createdAt), style: Bs.caption),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(preview,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Bs.text(14, color: Bs.g6, height: 1.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ArchiveEmpty extends StatelessWidget {
  const _ArchiveEmpty();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            const BsCharacterImage(BsCharacter.dizzy),
            const SizedBox(height: 16),
            Text('아직 지난 기록이 없어요',
                textAlign: TextAlign.center,
                style: Bs.text(16, weight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text('예전에 작성한 독서 기록이 있으면\n이곳에서 다시 볼 수 있어요.',
                textAlign: TextAlign.center,
                style: Bs.text(14, color: Bs.g3, height: 1.5)),
          ],
        ),
      );
}

final archiveDetailProvider = FutureProvider.autoDispose
    .family<DiaryArchiveItem, int>(
        (ref, id) => ref.watch(diaryArchiveRepositoryProvider).getDetail(id));

class LearningArchiveDetailScreen extends ConsumerWidget {
  const LearningArchiveDetailScreen({super.key, required this.diaryId});
  final int diaryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) => BsScaffold(
        title: '지난 독서 기록',
        showBack: true,
        body: ref.watch(archiveDetailProvider(diaryId)).when(
              loading: () => const Center(
                  child: CircularProgressIndicator(color: Bs.primary)),
              error: (error, _) => Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: BsEmptyState(
                    message: _archiveError(error),
                    action: BsPrimaryButton(
                        label: '다시 불러오기',
                        onPressed: () =>
                            ref.invalidate(archiveDetailProvider(diaryId))),
                  ),
                ),
              ),
              data: (item) => ListView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                children: [
                  Text(item.bookTitle, style: Bs.title),
                  const SizedBox(height: 8),
                  Text(_archiveDate(item.createdAt),
                      style: Bs.text(14, color: Bs.g3)),
                  const SizedBox(height: 24),
                  if (item.content.isNotEmpty)
                    SelectableText(item.content,
                        style: Bs.text(16, color: Bs.g7, height: 1.8)),
                  for (final (index, url) in item.images.indexed)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Semantics(
                        image: true,
                        label: '기록 사진 ${index + 1}',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(Bs.radius),
                          child: CachedNetworkImage(
                            imageUrl: url,
                            fit: BoxFit.contain,
                            placeholder: (_, __) => const SizedBox(
                                height: 120,
                                child: Center(
                                    child: CircularProgressIndicator(
                                        color: Bs.primary))),
                            errorWidget: (_, __, ___) => Padding(
                                padding: const EdgeInsets.all(20),
                                child: Text('사진을 불러오지 못했어요.',
                                    style: Bs.text(14, color: Bs.g3))),
                          ),
                        ),
                      ),
                    ),
                  if (item.content.isEmpty && item.images.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: BsEmptyState(
                          message:
                              '내용이 비어 있는 기록이에요\n이 기록에는 글이나 사진이 남아 있지 않아요.'),
                    ),
                  const SizedBox(height: 28),
                  Text('나의 지난 기록 · 읽기 전용', style: Bs.caption),
                ],
              ),
            ),
      );
}

String _archiveDate(DateTime? date) =>
    date == null ? '작성일 정보 없음' : DateFormat('yyyy년 M월 d일').format(date);

String _archiveError(Object error) {
  if (error is DioException && error.response?.statusCode == 404) {
    return '기록을 찾을 수 없어요. 본인이 작성한 기록만 열 수 있어요.';
  }
  return learningErrorMessage(error);
}
