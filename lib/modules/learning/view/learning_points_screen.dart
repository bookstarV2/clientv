import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../data/learning_access.dart';
import '../data/reading_map_remote.dart';
import '../data/reading_points.dart';
import 'bs_ui.dart';

class LearningPointsScreen extends ConsumerStatefulWidget {
  const LearningPointsScreen({super.key});

  @override
  ConsumerState<LearningPointsScreen> createState() =>
      _LearningPointsScreenState();
}

class _LearningPointsScreenState extends ConsumerState<LearningPointsScreen> {
  final _older = <ReadingPointEntry>[];
  int? _nextCursor;
  int? _owner;
  bool _loadingMore = false;
  String? _pageError;
  int _generation = 0;
  ReadingPoints? _firstPage;

  Future<void> _refresh() async {
    setState(() {
      _generation++;
      _older.clear();
      _nextCursor = null;
      _loadingMore = false;
      _pageError = null;
    });
    ref.invalidate(readingPointsProvider);
    ref.invalidate(readingMapStateProvider);
    try {
      await ref.read(readingPointsProvider.future);
    } catch (_) {}
  }

  Future<void> _loadMore(int cursor) async {
    if (_loadingMore) return;
    final generation = _generation;
    final owner = ref.read(learningAccountProvider);
    setState(() {
      _loadingMore = true;
      _pageError = null;
    });
    try {
      final page =
          await ref.read(readingMapRemoteProvider).points(cursor: cursor);
      if (!mounted ||
          generation != _generation ||
          owner != ref.read(learningAccountProvider)) {
        return;
      }
      setState(() {
        final ids = _older.map((entry) => entry.id).toSet();
        _older.addAll(page.items.where((entry) => ids.add(entry.id)));
        _nextCursor = page.nextCursor;
      });
    } catch (_) {
      if (mounted && generation == _generation) {
        setState(() => _pageError = '이전 내역을 불러오지 못했어요. 다시 시도해 주세요.');
      }
    } finally {
      if (mounted && generation == _generation) {
        setState(() => _loadingMore = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final owner = ref.watch(learningAccountProvider);
    if (_owner != owner) {
      _owner = owner;
      _generation++;
      _older.clear();
      _nextCursor = null;
      _loadingMore = false;
      _pageError = null;
    }
    final points = ref.watch(readingPointsProvider);
    final firstPage = points.valueOrNull;
    if (firstPage != null && !identical(firstPage, _firstPage)) {
      _firstPage = firstPage;
      _generation++;
      _older.clear();
      _nextCursor = null;
      _loadingMore = false;
      _pageError = null;
    }
    return BsScaffold(
      title: '내 포인트',
      showBack: true,
      onBack: () => context.canPop() ? context.pop() : context.go('/quiz'),
      body: points.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: Bs.primary)),
        error: (_, __) => Center(
          child: BsEmptyState(
            message: '포인트를 불러오지 못했어요.\n연결을 확인하고 다시 시도해 주세요.',
            action: BsSmallButton(label: '다시 불러오기', onPressed: _refresh),
          ),
        ),
        data: (wallet) => _content(wallet),
      ),
    );
  }

  Widget _content(ReadingPoints wallet) {
    final cursor = _older.isEmpty ? wallet.nextCursor : _nextCursor;
    final ids = <int>{};
    final entries =
        [...wallet.items, ..._older].where((entry) => ids.add(entry.id));
    return RefreshIndicator(
      color: Bs.primary,
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
            16, 24, 16, 24 + MediaQuery.paddingOf(context).bottom),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
                color: Bs.surface, borderRadius: BorderRadius.circular(20)),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('사용 가능한 포인트', style: Bs.text(14, color: Bs.g5)),
              const SizedBox(height: 10),
              Text('${NumberFormat('#,###').format(wallet.balance)} P',
                  style:
                      Bs.text(36, weight: FontWeight.w700, color: Bs.primary)),
              const SizedBox(height: 12),
              Text('퀴즈로 쌓은 생각을\n지도에서 연결해 보세요.',
                  style: Bs.text(16, color: Bs.g6, height: 1.5)),
            ]),
          ),
          const SizedBox(height: 24),
          Text('포인트 모으고 사용하기', style: Bs.text(18, weight: FontWeight.w700)),
          const SizedBox(height: 14),
          _rule('퀴즈 첫 풀이', '+${wallet.quizReward}P'),
          Text('정답 여부와 관계없이 퀴즈마다 처음 한 번 적립돼요.\n복습하거나 같은 퀴즈를 다시 풀면 추가 적립되지 않아요.',
              style: Bs.text(13, color: Bs.g3, height: 1.5)),
          const SizedBox(height: 14),
          _rule('지도 연결 만들기', '${wallet.createCost}P'),
          _rule('지도 연결 추가하기', '${wallet.refreshCost}P'),
          Text(
              '한 번 요청할 때의 비용이에요. 연결 이유와 근거를 함께 저장해요. 실패하거나 새 연결이 없으면 전액 돌려드려요.',
              style: Bs.text(13, color: Bs.g3, height: 1.5)),
          const SizedBox(height: 18),
          BsPrimaryButton(
              label: '지도에서 생각 연결하기', onPressed: () => context.push('/map/all')),
          const SizedBox(height: 28),
          Text('포인트 내역', style: Bs.text(18, weight: FontWeight.w700)),
          const SizedBox(height: 12),
          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                  '아직 포인트 내역이 없어요.\n첫 퀴즈를 풀고 ${wallet.quizReward}P를 받아 보세요.',
                  textAlign: TextAlign.center,
                  style: Bs.text(15, color: Bs.g3, height: 1.5)),
            ),
          for (final entry in entries) _entry(entry),
          if (_pageError != null)
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child:
                    Text(_pageError!, style: Bs.text(13, color: Bs.primary))),
          if (cursor != null)
            BsSecondaryButton(
                label: _loadingMore ? '불러오는 중' : '이전 내역 더 보기',
                onPressed: _loadingMore ? null : () => _loadMore(cursor)),
        ],
      ),
    );
  }

  Widget _rule(String label, String amount) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [
          Expanded(child: Text(label, style: Bs.text(15, color: Bs.g7))),
          Text(amount,
              style: Bs.text(16, weight: FontWeight.w700, color: Bs.primary)),
        ]),
      );

  Widget _entry(ReadingPointEntry entry) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(entry.label, style: Bs.text(15, weight: FontWeight.w600)),
                const SizedBox(height: 5),
                Text(DateFormat('yyyy.MM.dd HH:mm').format(entry.createdAt),
                    style: Bs.text(12, color: Bs.g3)),
              ])),
          const SizedBox(width: 12),
          Text('${entry.delta > 0 ? '+' : ''}${entry.delta}P',
              style: Bs.text(17,
                  weight: FontWeight.w700,
                  color: entry.delta > 0 ? Bs.primary : Bs.g6)),
        ]),
      );
}
