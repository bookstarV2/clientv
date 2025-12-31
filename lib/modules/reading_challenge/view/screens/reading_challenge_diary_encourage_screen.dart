import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/components/button/cta_button_l1.dart';
import '../../../../common/components/button/cta_button_l2.dart';
import '../../../../common/components/dialog/custom_dialog.dart';
import '../../../../common/theme/app_style.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/colors.gen.dart';
import '../../view_model/current_challenge_view_model.dart';
import '../widgets/step_progress_indicator.dart';

class ReadingChallengeDiaryEncourageScreen extends ConsumerWidget {
  const ReadingChallengeDiaryEncourageScreen({
    super.key,
    required this.isChallengeCompleted,
    required this.bookId,
  });

  final bool isChallengeCompleted;
  final int bookId;

  static const path = '/reading-challenge/diary-encourage';
  static const name = 'ReadingChallengeDiaryEncourageScreen';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = '리딩 챌린지';
    final subtitle = isChallengeCompleted ? '완독하셨네요! 챌린지 성공을 축하드려요' : null;
    final image = isChallengeCompleted
        ? Assets.icons.icReadingChallengeCompleted.svg()
        : Assets.icons.icReadingChallengeNotCompleted.svg();

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: BackButton(
          onPressed: context.pop,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              context.go('/reading-challenge');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: AppPaddings.SCREEN_BODY_PADDING,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              Text(
                '오늘 읽은 내용을\n다이어리에 기록해 보세요',
                style: AppTexts.b1.copyWith(color: ColorName.w1),
              ),
              if (subtitle != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFFB9ACFF), Color(0xFF473899)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ).createShader(bounds),
                    child: Text(
                      subtitle,
                      style: AppTexts.b8.copyWith(color: ColorName.w1),
                    ),
                  ),
                ),
              const SizedBox(height: 14),
              const StepProgressIndicator(
                totalSteps: 3,
                currentStep: 3,
              ),
              const Spacer(),
              SizedBox(
                width: 200,
                child: image,
              ),
              const Spacer(),
              _buildBottomButtons(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CtaButtonL1(
          text: '작성하기',
          analyticsEventName: 'click_write_diary_from_encourage',
          analyticsEventParams: {
            'screen_name': 'reading_challenge_diary_encourage',
            'bookId': bookId,
          },
          onPressed: () async {
            await _updateChallengeProgress(ref);
            final bookId =
                ref.read(currentChallengeViewModelProvider).book?.bookId;
            if (bookId == null) return;
            if (!context.mounted) return;
            // TODO: 사용하지 않는 위젯, 삭제 예정
            // context.push('/book-log/$bookId/create');
          },
        ),
        const SizedBox(height: 8),
        CtaButtonL2(
          text: '나중에 하기',
          analyticsEventName: 'click_skip_diary_from_encourage',
          analyticsEventParams: {
            'screen_name': 'reading_challenge_diary_encourage',
            'bookId': bookId,
          },
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => CustomDialog(
                title: '나중에 하기',
                content: '독서 다이어리를 작성하지 않으면\n리딩 챌린지 참여가 인정되지 않아요',
                confirmButtonText: '바로 작성하기',
                cancelButtonText: '나중에 하기',
                confirmAnalyticsEventName: 'click_write_diary_now',
                confirmAnalyticsEventParams: {
                  'screen_name': 'reading_challenge_diary_encourage',
                  'bookId': bookId,
                },
                cancelAnalyticsEventName: 'click_write_diary_later',
                cancelAnalyticsEventParams: {
                  'screen_name': 'reading_challenge_diary_encourage',
                  'bookId': bookId,
                },
                onConfirm: () async {
                  await _updateChallengeProgress(ref);
                  if (!context.mounted) return;
                  final bookId =
                      ref.read(currentChallengeViewModelProvider).book?.bookId;
                  if (bookId == null) return;
                  context.pop();
                  // context.push('/book-log/$bookId/create');
                },
                onCancel: () async {
                  await _updateChallengeProgress(ref);
                  if (!context.mounted) return;
                  context.go('/reading-challenge');
                },
                icon: Assets.icons.icReadingChallengeChar3.svg(
                  width: 80,
                  height: 80,
                ), 
              ),
            );
          },
        ),
        const SizedBox(height: 34),
      ],
    );
  }

  Future<void> _updateChallengeProgress(WidgetRef ref) async {
    try {
      final currentChallenge = ref.read(currentChallengeViewModelProvider);
      final viewModel = ref.read(currentChallengeViewModelProvider.notifier);

      if (currentChallenge.challengeId == null) {
        // Create new challenge if challengeId doesn't exist
        await viewModel.createChallenge(ref);
      } else {
        // Update existing challenge progress
        await viewModel.updateChallengeProgress(ref);
      }
    } catch (e) {
      // Handle error silently or show a snackbar if needed
      debugPrint('Failed to create/update challenge: $e');
    }
  }
}
