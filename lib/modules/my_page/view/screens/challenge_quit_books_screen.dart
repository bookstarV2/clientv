import 'package:bookstar/common/components/form/book_with_checkbok.dart';
import 'package:bookstar/common/components/button/cta_button_l1.dart';
import 'package:bookstar/common/theme/style/app_paddings.dart';
import 'package:bookstar/gen/colors.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bookstar/modules/reading_challenge/state/abandoned_challenges_state.dart';
import 'package:bookstar/modules/reading_challenge/view_model/abandoned_challenges_view_model.dart';

class ChallengeQuitBooksScreen extends ConsumerStatefulWidget {
  const ChallengeQuitBooksScreen({super.key});

  @override
  ConsumerState<ChallengeQuitBooksScreen> createState() =>
      _ChallengeQuitBooksScreenState();
}

class _ChallengeQuitBooksScreenState
    extends ConsumerState<ChallengeQuitBooksScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(abandonedChallengesViewModelProvider.notifier).initState();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(abandonedChallengesViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('챌린지 중단 도서'),
        leading: IconButton(
          icon: const BackButton(),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              GoRouter.of(context).go('/my-feed');
            },
          ),
        ],
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(AbandonedChallengesState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '오류가 발생했습니다',
              style: TextStyle(color: ColorName.g3),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(abandonedChallengesViewModelProvider.notifier)
                    .initState();
              },
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (state.challenges.isEmpty) {
      return const Center(
        child: Text(
          '중단된 챌린지가 없습니다.',
          style: TextStyle(
            color: ColorName.g7,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      );
    }

    return Stack(
      children: [
        Padding(
          padding: AppPaddings.SCREEN_BODY_PADDING.copyWith(left: 0, right: 0),
          child: ListView.builder(
            itemCount: state.challenges.length,
            itemBuilder: (context, index) {
              final challenge = state.challenges[index];
              return BookWithCheckbox(
                thumbnailUrl: challenge.bookImageUrl,
                title: challenge.bookTitle,
                author: challenge.bookAuthor,
                lastReadAt: challenge.createdAt.toString(),
                checked: state.checkedList[index],
                onChanged: (v) {
                  ref
                      .read(abandonedChallengesViewModelProvider.notifier)
                      .toggleCheck(index);
                },
              );
            },
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 54),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CtaButtonL1(
                  text: '다시 시작하기',
                  enabled: state.checkedList.contains(true),
                  analyticsEventName: 'click_restart_challenges',
                  analyticsEventParams: const {
                    'screen_name': 'challenge_quit_books',
                  },
                  onPressed: state.checkedList.contains(true)
                      ? () async {
                          await ref
                              .read(
                                  abandonedChallengesViewModelProvider.notifier)
                              .restartSelectedChallenges();
                        }
                      : null,
                ),
                const SizedBox(height: 8),
                CtaButtonL1(
                  text: '삭제하기',
                  enabled: state.checkedList.contains(true),
                  analyticsEventName: 'click_delete_abandoned_challenges',
                  analyticsEventParams: const {
                    'screen_name': 'challenge_quit_books',
                  },
                  onPressed: state.checkedList.contains(true)
                      ? () async {
                          await ref
                              .read(
                                  abandonedChallengesViewModelProvider.notifier)
                              .deleteSelectedChallenges();
                        }
                      : null,
                  backgroundColor: ColorName.g7,
                  borderColor: ColorName.g6,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
