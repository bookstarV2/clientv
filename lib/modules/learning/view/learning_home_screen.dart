import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/reading_graph.dart';
import 'learning_design.dart';
import 'reading_graph_canvas.dart';
import 'reading_graph_screen.dart';

/// Quiz is primary; the map is an optional view of its accumulated traces.
class LearningHomeScreen extends ConsumerWidget {
  const LearningHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final map = ref.watch(readingGraphProvider);
    return ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        children: [
          const Text('READ · RECALL · CONNECT',
              style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 1.7,
                  color: LearningColors.muted)),
          const SizedBox(height: 16),
          const Text('읽은 만큼,\n한 문제씩 떠올려요.',
              style: TextStyle(
                  fontSize: 28,
                  height: 1.25,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -.7)),
          const SizedBox(height: 14),
          const Text(
              '읽은 책과 목차를 고르고 AI 독서 퀴즈를 풀어 보세요.\n답을 떠올린 흔적은 나만의 지도에 차곡차곡 남아요.',
              style: learningBodyStyle),
          const SizedBox(height: 24),
          FilledButton.icon(
              onPressed: () => context.go('/library'),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('내 책으로 퀴즈 풀기')),
          const SizedBox(height: 8),
          OutlinedButton.icon(
              onPressed: () => context.go('/library/search'),
              icon: const Icon(Icons.search),
              label: const Text('퀴즈 풀 책 찾기')),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 20),
          const Text('퀴즈로 쌓인 독서 지도',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          map.when(
            loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text('풀이 흔적을 불러오고 있어요.', style: learningBodyStyle)),
            error: (_, __) =>
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('지도를 불러오지 못했어요. 퀴즈는 위에서 계속 시작할 수 있어요.',
                  style: learningBodyStyle),
              TextButton(
                  onPressed: () => ref.invalidate(readingGraphProvider),
                  child: const Text('지도 다시 불러오기')),
            ]),
            data: (graph) =>
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (graph.nodes.isEmpty)
                const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text('한 문제를 풀면 책과 목차, 질문의 첫 점들이 연결돼요.',
                        style: learningBodyStyle))
              else ...[
                Text(
                    '${graph.books.length}권에서 떠올린 ${graph.questionCount}개 질문${graph.truncated ? ' · 일부 기록' : ''}',
                    style: learningBodyStyle),
                IgnorePointer(
                    child: SizedBox(
                        height: 190,
                        child: ReadingGraphCanvas(
                            graph: graph, interactive: false))),
              ],
              OutlinedButton.icon(
                  onPressed: () => openReadingMap(context),
                  icon: const Icon(Icons.hub_outlined, size: 19),
                  label: const Text('내 독서 지도 보기')),
            ]),
          ),
          const SizedBox(height: 24),
          const Text('AI 퀴즈에는 오류가 있을 수 있어요. 낯선 해설은 책과 함께 확인해 주세요.',
              style: TextStyle(
                  fontSize: 12, height: 1.6, color: LearningColors.muted)),
        ]);
  }
}
