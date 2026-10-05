import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'bs_ui.dart';
import 'learning_guide_sheet.dart';

enum _PreviewStep { reading, question, answer }

/// /preview – sample quiz before signing in (Figma 0.2.1 – 0.2.4).
class LearningPreviewScreen extends StatefulWidget {
  const LearningPreviewScreen({super.key});

  @override
  State<LearningPreviewScreen> createState() => _LearningPreviewScreenState();
}

class _LearningPreviewScreenState extends State<LearningPreviewScreen> {
  static const _passage =
      '민지는 책을 읽은 뒤 기억하고 싶은 내용을 한 가지 고릅니다. 다음 날에는 책을 펼치기 전에 그 내용을 자기 말로 떠올려 봅니다. 잘 기억나지 않는 부분은 다시 읽으며 확인합니다.';
  static const _question = '민지가 다음 날 책을 펼치기 전에 한 행동은 무엇인가요?';
  static const _options = ['읽은 쪽수를 세었어요', '기억할 내용을 자기 말로 떠올렸어요', '새로운 책을 골랐어요'];
  static const _answer = 1;
  static const _explanation =
      '민지는 책을 펼치기 전에 기억할 내용을 자기 말로 떠올렸어요. 기억이 흐릿한 부분은 책으로 돌아가 확인했죠.';

  var _step = _PreviewStep.reading;
  int? _selected;
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _changeStep(_PreviewStep step) {
    setState(() => _step = step);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }

  void _back() {
    switch (_step) {
      case _PreviewStep.reading:
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/login');
        }
      case _PreviewStep.question:
        _changeStep(_PreviewStep.reading);
      case _PreviewStep.answer:
        _changeStep(_PreviewStep.question);
    }
  }

  void _startWithMyBook() =>
      showQuizGuideSheet(context, onStart: () => context.go('/library/search'));

  @override
  Widget build(BuildContext context) {
    final answered = _step == _PreviewStep.answer;
    return PopScope(
      canPop: _step == _PreviewStep.reading,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        backgroundColor: Bs.bg,
        body: DecoratedBox(
          decoration: BoxDecoration(
            gradient: answered
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0, 0.67, 1],
                    colors: [Bs.bg, Bs.bg, Bs.gradientEnd],
                  )
                : null,
          ),
          child: SafeArea(
            child: Column(
              children: [
                BsTopBar(title: '한 문제 풀어보기', showBack: true, onBack: _back),
                Expanded(
                  child: ListView(
                    key: ValueKey(_step),
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 26.5, 16, 24),
                    children: [
                      Text(
                          switch (_step) {
                            _PreviewStep.reading => '가볍게 읽고\n한 문제 풀어볼까요?',
                            _PreviewStep.question => '읽은 내용을\n얼마나 기억하고 있나요?',
                            _PreviewStep.answer => '이렇게 하나씩\n내 것으로 남겨요',
                          },
                          style: Bs.text(20,
                              weight: FontWeight.w600, letterSpacing: 0)),
                      ...switch (_step) {
                        _PreviewStep.reading => [
                            const SizedBox(height: 8),
                            Text('아래 문장을 읽고,\nAI가 만든 퀴즈를 풀어보세요.',
                                style: Bs.text(14,
                                    color: Bs.g3,
                                    height: 1.5,
                                    letterSpacing: 0)),
                            const SizedBox(height: 22),
                            const _PassageCard(_passage),
                          ],
                        _PreviewStep.question => [
                            const SizedBox(height: 22),
                            BsQuizCard(question: _question, options: [
                              for (final (index, option) in _options.indexed)
                                BsOptionTile(
                                  text: option,
                                  state: _selected == index
                                      ? BsOptionState.selected
                                      : BsOptionState.idle,
                                  semanticsLabel: '${index + 1}번 $option',
                                  onTap: () =>
                                      setState(() => _selected = index),
                                ),
                            ]),
                          ],
                        _PreviewStep.answer => [
                            const SizedBox(height: 22),
                            BsQuizCard(question: _question, options: [
                              for (final (index, option) in _options.indexed)
                                BsOptionTile(
                                  text: option,
                                  state: index == _answer
                                      ? BsOptionState.answer
                                      : BsOptionState.dimmed,
                                ),
                            ]),
                            const SizedBox(height: 12),
                            const BsExplanationCard(body: _explanation),
                          ],
                      },
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 15),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_step == _PreviewStep.question)
                        _RereadLink(
                            muted: _selected != null,
                            onTap: () => _changeStep(_PreviewStep.reading)),
                      switch (_step) {
                        _PreviewStep.reading => BsPrimaryButton(
                            label: '퀴즈 풀어보기',
                            onPressed: () =>
                                _changeStep(_PreviewStep.question)),
                        _PreviewStep.question => BsPrimaryButton(
                            label: '정답 확인하기',
                            onPressed: _selected == null
                                ? null
                                : () => _changeStep(_PreviewStep.answer)),
                        _PreviewStep.answer => BsPrimaryButton(
                            label: '내 책으로 시작하기', onPressed: _startWithMyBook),
                      },
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PassageCard extends StatelessWidget {
  const _PassageCard(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(minHeight: 332),
        decoration: BoxDecoration(
            color: Bs.surface, borderRadius: BorderRadius.circular(18)),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 54),
              child: Text(text,
                  style: Bs.text(16,
                      weight: FontWeight.w500,
                      color: Bs.g7,
                      height: 1.5,
                      letterSpacing: -0.1)),
            ),
            Positioned(
              right: 16,
              bottom: 19.5,
              child: Image.asset('assets/images/learning/onb_watermark.png',
                  width: 100, height: 15.5, excludeFromSemantics: true),
            ),
          ],
        ),
      );
}

class _RereadLink extends StatelessWidget {
  const _RereadLink({required this.muted, required this.onTap});

  final bool muted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = muted ? const Color(0xFF8E79FF) : Bs.primary;
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44, minWidth: 88),
          child: Center(
            widthFactor: 1,
            heightFactor: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text('문장 다시 읽기',
                  style: Bs.text(14,
                          weight: FontWeight.w500, color: color, height: 1.5)
                      .copyWith(
                          decoration: TextDecoration.underline,
                          decorationColor: color)),
            ),
          ),
        ),
      ),
    );
  }
}
