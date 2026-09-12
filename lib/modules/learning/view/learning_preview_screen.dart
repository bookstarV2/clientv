import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'learning_design.dart';

class LearningPreviewScreen extends StatefulWidget {
  const LearningPreviewScreen({super.key});

  @override
  State<LearningPreviewScreen> createState() => _LearningPreviewScreenState();
}

class _LearningPreviewScreenState extends State<LearningPreviewScreen> {
  bool _ready = false;
  int? _selected;
  bool _answered = false;
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _changeStep(VoidCallback change) {
    setState(change);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) => LearningPage(
        title: '한 문제 체험',
        bottom: SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: !_ready
                  ? () => _changeStep(() => _ready = true)
                  : _answered
                      ? () => context.go('/library/search')
                      : _selected == null
                          ? null
                          : () => _changeStep(() => _answered = true),
              child: Text(!_ready
                  ? '글을 가리고 퀴즈 풀기'
                  : _answered
                      ? '내 책으로 시작하기'
                      : '답 확인하기'),
            )),
        child: ListView(
            key: ValueKey(!_ready
                ? 'reading'
                : _answered
                    ? 'answer'
                    : 'question'),
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              const LearningLabel('체험용 예시 · 실제 책의 문제가 아니에요'),
              const SizedBox(height: 18),
              Text(
                  !_ready
                      ? '짧게 읽고,\n한 번 떠올려 볼까요?'
                      : _answered
                          ? '이렇게, 한 가지를\n내 것으로 남겨요'
                          : '읽은 내용을\n꺼내 볼 시간',
                  style: learningTitleStyle),
              const SizedBox(height: 24),
              if (!_ready) ...[
                const LearningCard(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      LearningLabel('작은 독서 습관'),
                      SizedBox(height: 16),
                      Text(
                          '민지는 책을 읽은 뒤 기억하고 싶은 내용을 한 가지 고릅니다. 다음 날에는 책을 펼치기 전에 그 내용을 자기 말로 떠올려 봅니다. 잘 기억나지 않는 부분은 다시 읽으며 확인합니다.',
                          style: TextStyle(
                              fontSize: 19,
                              height: 1.85,
                              color: LearningColors.ink)),
                    ])),
                const SizedBox(height: 20),
                const Text('다 외울 필요 없어요.\n읽고 나서 무엇이 남았는지만 확인해요.',
                    style: learningBodyStyle),
              ] else if (!_answered) ...[
                const Text('민지가 다음 날 책을 펼치기 전에 한 행동은 무엇인가요?',
                    style: TextStyle(
                        fontSize: 22,
                        height: 1.5,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 24),
                ...[
                  '읽은 쪽수를 세었어요',
                  '기억할 내용을 자기 말로 떠올렸어요',
                  '새로운 책을 골랐어요'
                ].asMap().entries.map((entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Semantics(
                        button: true,
                        selected: _selected == entry.key,
                        enabled: true,
                        onTap: () => setState(() => _selected = entry.key),
                        label: '${entry.key + 1}번 ${entry.value}',
                        excludeSemantics: true,
                        child: LearningCard(
                          color: _selected == entry.key
                              ? LearningColors.lavender
                              : Colors.white,
                          onTap: () => setState(() => _selected = entry.key),
                          child: Row(children: [
                            Icon(
                                _selected == entry.key
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                color: _selected == entry.key
                                    ? LearningColors.primary
                                    : LearningColors.muted),
                            const SizedBox(width: 12),
                            Expanded(
                                child: Text(entry.value,
                                    style: const TextStyle(
                                        fontSize: 16, height: 1.5))),
                          ]),
                        ),
                      ),
                    )),
                TextButton(
                    onPressed: () => _changeStep(() => _ready = false),
                    child: const Text('글 다시 읽기')),
              ] else ...[
                LearningCard(
                  color: _selected == 1
                      ? LearningColors.greenSoft
                      : LearningColors.amberSoft,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LearningLabel(_selected == 1 ? '잘 떠올렸어요' : '함께 다시 짚어봐요',
                            color: _selected == 1
                                ? LearningColors.green
                                : LearningColors.amber),
                        const SizedBox(height: 14),
                        const Text('자기 말로 떠올려 보기',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        const Text(
                            '민지는 책을 펼치기 전에 기억할 내용을 자기 말로 떠올렸어요. 기억이 흐릿한 부분은 책으로 돌아가 확인했죠.',
                            style: learningBodyStyle),
                      ]),
                ),
                const SizedBox(height: 24),
                const Text('내 책에서도 이렇게 이어져요',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                const Text(
                    '1. 읽은 목차를 골라요\n2. 한 문제를 풀고 해설을 확인해요\n3. 복습에 저장된 문제를 다시 떠올려요',
                    style: learningBodyStyle),
                const SizedBox(height: 24),
                const Text('체험 결과는 독서·복습 기록에 저장되지 않아요.',
                    style:
                        TextStyle(fontSize: 12, color: LearningColors.muted)),
              ],
            ]),
      );
}
