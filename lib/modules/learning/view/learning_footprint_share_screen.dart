import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/footprint_export.dart';
import '../data/learning_access.dart';
import '../data/learning_footprint.dart';
import '../data/learning_repository.dart';
import 'footprint_story_card.dart';
import 'learning_design.dart';

class LearningFootprintShareScreen extends ConsumerStatefulWidget {
  const LearningFootprintShareScreen(
      {super.key, required this.ownerId, required this.footprint});
  final int ownerId;
  final LearningFootprint footprint;

  @override
  ConsumerState<LearningFootprintShareScreen> createState() => _ShareState();
}

class _ShareState extends ConsumerState<LearningFootprintShareScreen> {
  final _imageKey = GlobalKey();
  late LearningFootprint _footprint = widget.footprint;
  FootprintCardStyle _style = FootprintCardStyle.books;
  List<FootprintBook> _books = [];
  bool _numbers = true;
  bool _busy = false;
  bool _invalidated = false;

  @override
  void initState() {
    super.initState();
    ref.listenManual(learningAccountProvider, (previous, next) {
      if (previous != next && mounted) {
        setState(() {
          _invalidated = true;
          _books = [];
        });
      }
    });
  }

  bool get _stillOwner =>
      mounted &&
      !_invalidated &&
      ref.read(learningAccountProvider) == widget.ownerId;
  bool get _hasContent =>
      _footprint.answeredQuizCount > 0 && (_numbers || _books.isNotEmpty);

  Future<void> _chooseBooks() async {
    final selected = await showModalBottomSheet<List<FootprintBook>>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) =>
            FootprintBookPicker(ownerId: widget.ownerId, selected: _books));
    if (_stillOwner && selected != null) setState(() => _books = selected);
  }

  void _message(String text) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    }
  }

  Future<void> _export(BuildContext buttonContext, {required bool save}) async {
    if (_busy || !_hasContent || !_stillOwner) return;
    final box = buttonContext.findRenderObject() as RenderBox;
    final origin = box.localToGlobal(Offset.zero) & box.size;
    setState(() => _busy = true);
    try {
      final latest = await ref.read(learningRepositoryProvider).getFootprint();
      if (!_stillOwner) return;
      if (_books.isNotEmpty) {
        final verified = await ref
            .read(learningRepositoryProvider)
            .getFootprintBooks(
                bookIds: _books.map((book) => book.bookId).toList());
        if (!_stillOwner) return;
        final byId = {for (final book in verified.items) book.bookId: book};
        final changed = _books.any((book) =>
            byId[book.bookId]?.title != book.title ||
            byId[book.bookId]?.author != book.author ||
            byId[book.bookId]?.cover != book.cover);
        if (changed) {
          setState(() {
            _books = _books
                .where((book) => byId.containsKey(book.bookId))
                .map((book) => byId[book.bookId]!)
                .toList();
            _footprint = latest;
          });
          _message('선택한 책 기록이 바뀌었어요. 새 미리보기를 확인한 뒤 다시 눌러 주세요.');
          return;
        }
      }
      if (latest.answeredQuizCount != _footprint.answeredQuizCount ||
          latest.reviewedQuizCount != _footprint.reviewedQuizCount ||
          latest.bookCount != _footprint.bookCount) {
        setState(() {
          _footprint = latest;
          _books = [];
        });
        ref.invalidate(learningFootprintProvider);
        _message('기록이 바뀌어 미리보기를 새로 만들었어요. 담을 내용을 다시 확인해 주세요.');
        return;
      }
      await WidgetsBinding.instance.endOfFrame;
      if (!_stillOwner) return;
      final boundary =
          _imageKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (!_stillOwner || data == null) return;
      final exporter = ref.read(footprintExportProvider);
      final bytes = data.buffer.asUint8List();
      if (save) {
        final saved = await exporter.save(bytes, () => _stillOwner);
        if (saved && _stillOwner) _message('사진에 저장했어요. 나만 간직해도 좋아요.');
      } else {
        await exporter.share(bytes, origin, () => _stillOwner);
      }
    } catch (_) {
      if (_stillOwner) {
        _message(save
            ? '저장하지 못했어요. 네트워크와 사진 추가 권한을 확인해 주세요.'
            : '공유를 열지 못했어요. 네트워크를 확인하거나 사진에 저장해 보세요.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final account = ref.watch(learningAccountProvider);
    if (_invalidated || account != widget.ownerId) {
      return const LearningPage(
          title: '내 기록 카드',
          child: Center(child: Text('계정이 바뀌었어요. 기록을 다시 열어 주세요.')));
    }
    return PopScope(
        canPop: true,
        child: LearningPage(
          title: '내 기록 카드',
          child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('어떤 모습으로 남길까요?',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    const Text('고른 내용만 이미지에 담아요.\n계정 이름·정답·해설은 담지 않아요.',
                        style: learningBodyStyle),
                    const SizedBox(height: 16),
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      for (final style in FootprintCardStyle.values)
                        ChoiceChip(
                            label: Text(style == FootprintCardStyle.books
                                ? '책과 함께'
                                : '숫자 중심'),
                            selected: _style == style,
                            onSelected: _busy
                                ? null
                                : (_) => setState(() {
                                      _style = style;
                                      _books = [];
                                    })),
                    ]),
                    if (_style == FootprintCardStyle.books) ...[
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                          onPressed: _busy ? null : _chooseBooks,
                          icon: const Icon(Icons.menu_book_outlined),
                          label: Text(_books.isEmpty
                              ? '담을 책 직접 고르기 · 최대 3권'
                              : '선택한 책 ${_books.length}권 바꾸기')),
                      if (_books.isNotEmpty)
                        TextButton(
                            onPressed: _busy
                                ? null
                                : () => setState(() => _books = []),
                            child: const Text('책 없이 만들기')),
                    ],
                    SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('누적 수치 담기'),
                        value: _numbers,
                        onChanged: _busy
                            ? null
                            : (value) => setState(() => _numbers = value)),
                    const SizedBox(height: 12),
                    Semantics(
                        label: '이미지 미리보기. 아래 공개 내용 요약에서 텍스트로 확인할 수 있어요.',
                        image: true,
                        excludeSemantics: true,
                        child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: RepaintBoundary(
                                key: _imageKey,
                                child: FootprintStoryCard(
                                    footprint: _footprint,
                                    books: _books,
                                    showNumbers: _numbers,
                                    style: _style)))),
                    const SizedBox(height: 16),
                    Text(
                        '이미지에 담기는 내용\n'
                        '${_books.isEmpty ? '책 제목 없음' : _books.map((book) => book.title).join(' · ')}\n'
                        '${_numbers ? '전체 풀어본 퀴즈 ${_footprint.answeredQuizCount}개 · 그중 다시 풀어본 퀴즈 ${_footprint.reviewedQuizCount}개' : '누적 수치 없음'}\n'
                        '기록 기준일 · 카드 문구 · 북스타 서명',
                        style: learningBodyStyle),
                    if (!_hasContent)
                      const Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: Text('기록을 남기려면 책이나 누적 수치를 골라 주세요.',
                              style: learningBodyStyle)),
                    const SizedBox(height: 24),
                    Builder(
                        builder: (buttonContext) => FilledButton.icon(
                            onPressed: _busy || !_hasContent
                                ? null
                                : () => _export(buttonContext, save: false),
                            icon: _busy
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2))
                                : const Icon(Icons.ios_share),
                            label: Text(_busy ? '기록 확인 중…' : '이미지 공유'))),
                    const SizedBox(height: 10),
                    Builder(
                        builder: (buttonContext) => OutlinedButton.icon(
                            onPressed: _busy || !_hasContent
                                ? null
                                : () => _export(buttonContext, save: true),
                            icon: const Icon(Icons.save_alt),
                            label: const Text('사진에 저장해서 간직하기'))),
                    const SizedBox(height: 12),
                    const Text(
                        '스토리에 올리고 싶다면 사진에 저장한 뒤 Instagram에서 선택할 수도 있어요. '
                        '이 앱이 대신 게시하지는 않아요.',
                        style: TextStyle(
                            fontSize: 12,
                            height: 1.6,
                            color: LearningColors.muted)),
                  ])),
        ));
  }
}

class FootprintBookPicker extends ConsumerStatefulWidget {
  const FootprintBookPicker(
      {super.key,
      required this.ownerId,
      this.selected = const [],
      this.readOnly = false});
  final int ownerId;
  final List<FootprintBook> selected;
  final bool readOnly;
  @override
  ConsumerState<FootprintBookPicker> createState() => _BookPickerState();
}

class _BookPickerState extends ConsumerState<FootprintBookPicker> {
  late final Map<int, FootprintBook> _selected = {
    for (final book in widget.selected) book.bookId: book
  };
  final List<FootprintBook> _items = [];
  bool _loading = false;
  bool _hasNext = true;
  bool _failed = false;
  int? _cursor;
  bool _invalidated = false;

  @override
  void initState() {
    super.initState();
    ref.listenManual(learningAccountProvider, (previous, next) {
      if (previous != next && mounted) {
        setState(() {
          _invalidated = true;
          _selected.clear();
          _items.clear();
        });
      }
    });
    _load();
  }

  Future<void> _load() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final page = await ref
          .read(learningRepositoryProvider)
          .getFootprintBooks(cursor: _cursor);
      if (!mounted ||
          _invalidated ||
          ref.read(learningAccountProvider) != widget.ownerId) {
        return;
      }
      if (page.hasNext && page.nextCursor == _cursor) {
        throw StateError('Cursor did not advance');
      }
      setState(() {
        final known = _items.map((item) => item.bookId).toSet();
        _items.addAll(page.items.where((item) => known.add(item.bookId)));
        _cursor = page.nextCursor;
        _hasNext = page.hasNext;
      });
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_invalidated || ref.watch(learningAccountProvider) != widget.ownerId) {
      return const SafeArea(
          child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('계정이 바뀌었어요. 다시 열어 주세요.')));
    }
    return SafeArea(
        child: SizedBox(
            height: MediaQuery.sizeOf(context).height * .85,
            child: Column(children: [
              Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
                  child: Row(children: [
                    Expanded(
                        child: Text(
                            widget.readOnly ? '퀴즈를 풀어본 책' : '담을 책 직접 고르기',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w700))),
                    IconButton(
                        tooltip: '선택 취소',
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close))
                  ])),
              Expanded(
                  child: ListView.builder(
                      itemCount: _items.length + 2,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                  widget.readOnly
                                      ? '퀴즈로 다시 만나 본 책들이에요. 서재에 담기만 한 책이나 완독 목록은 아니에요.'
                                      : '퀴즈를 풀어본 책 중 최대 3권. 선택한 책 제목만 카드에 담아요.',
                                  style: learningBodyStyle));
                        }
                        if (index == _items.length + 1) {
                          return Padding(
                              padding: const EdgeInsets.all(20),
                              child: _loading
                                  ? const Center(
                                      child: CircularProgressIndicator())
                                  : _failed
                                      ? TextButton(
                                          onPressed: _load,
                                          child: const Text('책 목록 다시 불러오기'))
                                      : _hasNext
                                          ? TextButton(
                                              onPressed: _load,
                                              child: const Text('책 더 보기'))
                                          : _items.isEmpty
                                              ? const Text(
                                                  '지금 선택할 수 있는 책이 없어요. 책 없이도 누적 기록을 만들 수 있어요.')
                                              : const SizedBox.shrink());
                        }
                        final book = _items[index - 1];
                        if (widget.readOnly) {
                          return ListTile(
                              title: Text(book.title),
                              subtitle: Text(book.author),
                              leading: BookCover(
                                  url: book.cover,
                                  title: book.title,
                                  width: 36));
                        }
                        final selected = _selected.containsKey(book.bookId);
                        return CheckboxListTile(
                            value: selected,
                            controlAffinity: ListTileControlAffinity.leading,
                            title: Text(book.title),
                            subtitle:
                                book.author.isEmpty ? null : Text(book.author),
                            onChanged: !selected && _selected.length >= 3
                                ? null
                                : (value) => setState(() {
                                      if (value == true) {
                                        _selected[book.bookId] = book;
                                      } else {
                                        _selected.remove(book.bookId);
                                      }
                                    }));
                      })),
              if (!widget.readOnly)
                Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                            onPressed: () => Navigator.pop(
                                context, _selected.values.toList()),
                            child: Text(_selected.isEmpty
                                ? '책 없이 만들기'
                                : '선택한 ${_selected.length}권 담기')))),
            ])));
  }
}
