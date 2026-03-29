import 'package:bookstar/common/components/base_screen.dart';
import 'package:bookstar/common/components/custom_list_view.dart';
import 'package:bookstar/common/components/form/book_with_checkbok.dart';
import 'package:bookstar/common/components/button/cta_button_l1.dart';
import 'package:bookstar/common/theme/style/app_texts.dart';
import 'package:bookstar/gen/assets.gen.dart';
import 'package:bookstar/gen/colors.gen.dart';
import 'package:bookstar/modules/reading_challenge/state/abandoned_challenges_state.dart';
import 'package:bookstar/modules/reading_challenge/view_model/abandoned_challenges_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChallengeQuitBooksScreen extends BaseScreen {
  const ChallengeQuitBooksScreen({super.key});

  @override
  BaseScreenState<ChallengeQuitBooksScreen> createState() =>
      _ChallengeQuitBooksScreenState();
}

class _ChallengeQuitBooksScreenState
    extends BaseScreenState<ChallengeQuitBooksScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(abandonedChallengesViewModelProvider.notifier).initState();
    });
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('챌린지 중단 도서'),
      leading: IconButton(
        icon: const BackButton(),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    final state = ref.watch(abandonedChallengesViewModelProvider);

    return state.when(
        data: (data) {
          return CustomListView(
            emptyIcon: Assets.icons.icSearchEmptyCharacter.svg(),
            emptyText: '검색 결과가 없어요',
            emptyTextStyle: AppTexts.b3.copyWith(color: ColorName.w1),
            emptyDescription: '유저의 닉네임을 다시 확인해 보세요',
            emptyDescriptionStyle: AppTexts.b6.copyWith(color: ColorName.g2),
            isEmpty: data.challenges.isEmpty,
            itemCount: data.challenges.length,
            itemBuilder: (context, index) {
              final challenge = data.challenges[index];
              return BookWithCheckbox(
                thumbnailUrl: challenge.bookImageUrl,
                title: challenge.bookTitle,
                author: challenge.bookAuthor,
                lastReadAt: challenge.createdAt.toString(),
                checked: data.checkedList[index],
                onChanged: (v) {
                  ref
                      .read(abandonedChallengesViewModelProvider.notifier)
                      .toggleCheck(index);
                },
              );
            },
            separatorBuilder: (context, index) => SizedBox(
              height: 20,
            ),
            scrollController: scrollController,
          );
        },
        loading: loading,
        error: error("오류가 발생했습니다"));
  }

  @override
  Widget? buildFloatingActionButton(BuildContext context) {
    final state = ref.watch(abandonedChallengesViewModelProvider);
    final data = state.value ?? AbandonedChallengesState();

    return data.challenges.isNotEmpty
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CtaButtonL1(
                text: '다시 시작하기',
                enabled: data.checkedList.contains(true),
                analyticsEventName: 'click_restart_challenges',
                analyticsEventParams: const {
                  'screen_name': 'challenge_quit_books',
                },
                onPressed: data.checkedList.contains(true)
                    ? () async {
                        await ref
                            .read(abandonedChallengesViewModelProvider.notifier)
                            .restartSelectedChallenges();
                      }
                    : null,
              ),
              const SizedBox(height: 8),
              CtaButtonL1(
                text: '삭제하기',
                enabled: data.checkedList.contains(true),
                analyticsEventName: 'click_delete_abandoned_challenges',
                analyticsEventParams: const {
                  'screen_name': 'challenge_quit_books',
                },
                onPressed: data.checkedList.contains(true)
                    ? () async {
                        await ref
                            .read(abandonedChallengesViewModelProvider.notifier)
                            .deleteSelectedChallenges();
                      }
                    : null,
                backgroundColor: ColorName.g7,
                borderColor: ColorName.g6,
              ),
            ],
          )
        : null;
  }
}
