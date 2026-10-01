import 'package:flutter/material.dart';

import 'bs_ui.dart';

/// 0.2.4 사용안내 – "내 책으로도 이어서 해볼 수 있어요" bottom sheet.
/// Shown after the sample quiz (0.2.3) and from 설정 > AI 퀴즈 이용 안내.
Future<void> showQuizGuideSheet(BuildContext context,
        {String primaryLabel = '내 책으로 시작하기', VoidCallback? onStart}) =>
    showBsSheet<void>(
      context,
      title: '내 책으로도 이어서 해볼 수 있어요',
      primaryLabel: primaryLabel,
      onPrimary: () {
        Navigator.of(context, rootNavigator: true).pop();
        onStart?.call();
      },
      body: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GuideStep(1, '읽을 목차를 골라요'),
          SizedBox(height: 8),
          _GuideStep(2, '퀴즈를 확인해요'),
          SizedBox(height: 8),
          _GuideStep(3, '퀴즈를 풀고 해설을 확인해요'),
          SizedBox(height: 8),
          _GuideStep(4, '저장한 문제로 다시 복습해요'),
        ],
      ),
    );

class _GuideStep extends StatelessWidget {
  const _GuideStep(this.number, this.text);

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) => Semantics(
        label: '$number단계, $text',
        excludeSemantics: true,
        child: Row(
          children: [
            Container(
              constraints: const BoxConstraints(minWidth: 23, minHeight: 29),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Bs.surface, borderRadius: BorderRadius.circular(6)),
              child: Text('$number',
                  style: Bs.text(16,
                      weight: FontWeight.w600, color: const Color(0xFF8E79FF))),
            ),
            const SizedBox(width: 8),
            Expanded(
                child: Text(text,
                    style: Bs.text(16,
                        weight: FontWeight.w500,
                        color: Bs.g7,
                        height: 1.45,
                        letterSpacing: -0.1))),
          ],
        ),
      );
}
