import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../data/learning_access.dart';
import '../data/learning_footprint.dart';
import 'learning_design.dart';
import 'learning_footprint_share_screen.dart';

class LearningFootprintScreen extends ConsumerWidget {
  const LearningFootprintScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(learningFootprintProvider);
    return LearningPage(
      title: '나의 독서 흔적',
      actions: [
        IconButton(
            tooltip: '기록 기준',
            icon: const Icon(Icons.info_outline),
            onPressed: () => showDialog<void>(
                context: context,
                builder: (context) => AlertDialog(
                        title: const Text('어떤 기록인가요?'),
                        content: const SingleChildScrollView(
                            child: Text(
                                '앱에 보관된 본인 풀이 기록을 셉니다. 같은 퀴즈는 여러 번 풀어도 한 개예요. '
                                '다시 풀어본 퀴즈는 그중 복습한 퀴즈이고, 책은 퀴즈를 풀어본 책의 수예요.\n\n'
                                '완독이나 지식 습득을 인증하는 수치는 아니에요. 기록이나 문항이 삭제되면 수치가 달라질 수 있어요.')),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('확인'))
                        ])))
      ],
      child: state.when(
        skipLoadingOnRefresh: false,
        data: (data) => RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(learningFootprintProvider);
              try {
                await ref.read(learningFootprintProvider.future);
              } catch (_) {}
            },
            child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                children: [
                  const LearningLabel('지금까지 · 앱에 보관된 기록'),
                  const SizedBox(height: 16),
                  Text(
                      data.answeredQuizCount == 0
                          ? '첫 흔적은\n한 문제부터.'
                          : data.answeredQuizCount <= 5
                              ? '내가 시작한\n기록이에요.'
                              : '책을 덮고도,\n한 번 더.',
                      style: learningTitleStyle),
                  const SizedBox(height: 12),
                  Text(
                      data.answeredQuizCount == 0
                          ? '읽은 책과 목차를 고르면 시작할 수 있어요.'
                          : '읽었던 내용을 다시 꺼내 본 기록이에요.\n나만 간직해도 충분해요.',
                      style: learningBodyStyle),
                  const SizedBox(height: 24),
                  LearningCard(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      child: Column(children: [
                        _metric('풀어본 퀴즈', data.answeredQuizCount, '개'),
                        const Divider(),
                        _metric('그중 다시 풀어본 퀴즈', data.reviewedQuizCount, '개'),
                        const Divider(),
                        _metric('퀴즈를 풀어본 책', data.bookCount, '권'),
                      ])),
                  const SizedBox(height: 12),
                  Text(
                      '${DateFormat('yyyy.MM.dd HH:mm').format(data.generatedAt.toLocal())} 불러온 기록',
                      style: const TextStyle(
                          fontSize: 12, color: LearningColors.muted)),
                  const SizedBox(height: 28),
                  if (data.answeredQuizCount > 0) ...[
                    OutlinedButton.icon(
                        icon: const Icon(Icons.menu_book_outlined),
                        label: const Text('퀴즈로 다시 만나 본 책들'),
                        onPressed: () {
                          final owner = ref.read(learningAccountProvider);
                          if (owner == null) return;
                          showModalBottomSheet<void>(
                              context: context,
                              isScrollControlled: true,
                              useSafeArea: true,
                              builder: (_) => FootprintBookPicker(
                                  ownerId: owner, readOnly: true));
                        }),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                        icon: const Icon(Icons.auto_awesome_outlined),
                        label: const Text('내 기록 카드 만들기'),
                        onPressed: () {
                          final owner = ref.read(learningAccountProvider);
                          if (owner == null) return;
                          Navigator.of(context).push(MaterialPageRoute<void>(
                              builder: (_) => LearningFootprintShareScreen(
                                  ownerId: owner, footprint: data)));
                        }),
                    const SizedBox(height: 10),
                    const Text('담을 책과 숫자는 직접 골라요.\n공유하지 않고 사진으로 저장할 수도 있어요.',
                        textAlign: TextAlign.center, style: learningBodyStyle),
                  ] else
                    FilledButton.icon(
                        icon: const Icon(Icons.search),
                        onPressed: () => context.push('/library/search'),
                        label: const Text('AI 퀴즈 풀 책 찾기')),
                ])),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: LearningError(
                onRetry: () => ref.invalidate(learningFootprintProvider))),
      ),
    );
  }

  Widget _metric(String label, int count, String unit) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SizedBox(
          width: double.infinity,
          child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 8,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 14, color: LearningColors.muted)),
                Text('${NumberFormat.decimalPattern().format(count)}$unit',
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.7))
              ])));
}
