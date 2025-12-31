import 'package:bookstar/common/components/base_screen.dart';
import 'package:bookstar/common/components/button/cta_button_l1.dart';
import 'package:bookstar/common/components/custom_list_view.dart';
import 'package:bookstar/common/theme/style/app_paddings.dart';
import 'package:bookstar/common/theme/style/app_texts.dart';
import 'package:bookstar/gen/assets.gen.dart';
import 'package:bookstar/gen/colors.gen.dart';
import 'package:bookstar/modules/reading_challenge/model/challenge_response.dart';
import 'package:bookstar/common/service/full_capture_service.dart';
import 'package:bookstar/modules/reading_challenge/view/widgets/save_success_image_dialog.dart';
import 'package:bookstar/modules/reading_challenge/view_model/ongoing_challenge_view_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ReadingChallengeScreen extends BaseScreen {
  const ReadingChallengeScreen({super.key, required this.challengeId});

  final int challengeId;

  @override
  BaseScreenState<ReadingChallengeScreen> createState() =>
      _ReadingChallengeScreenState();
}

class _ReadingChallengeScreenState
    extends BaseScreenState<ReadingChallengeScreen> {
  @override
  bool enableRefreshIndicator() => true;

  final GlobalKey _screenKey = GlobalKey();
  bool _hasScrolledToTarget = false;
  int? _targetIndex;
  int? _newIndex;

  @override
  void onDidUpdateWidget(covariant ReadingChallengeScreen oldWidget) async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.challengeId != oldWidget.challengeId) {
        setState(() {
          _hasScrolledToTarget = false;
          _targetIndex = null;
        });
        final notifier = ref.read(ongoingChallengeViewModelProvider.notifier);
        await notifier.initState();
        final state = ref.read(ongoingChallengeViewModelProvider);
        final targetIndex = state.value?.challenges
                .indexWhere((e) => e.challengeId == widget.challengeId) ??
            -1;
        if (targetIndex != -1 && !_hasScrolledToTarget) {
          setState(() {
            _hasScrolledToTarget = true;
            _targetIndex = targetIndex;
            _newIndex = targetIndex;
          });
          if (mounted && scrollController.hasClients) {
            scrollController.animateTo(
              targetIndex * 170,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }

          final hasQuiz = state.value!.challenges[targetIndex].hasQuiz;
          print("hasQuiz: $hasQuiz");
          if (mounted && !hasQuiz) {
            await notifier.pollingUntilHasQuiz(widget.challengeId);
          }
        }
      }
    });
  }

  @override
  Future<void> onRefresh() async {
    final notifier = ref.read(ongoingChallengeViewModelProvider.notifier);
    await notifier.initState();
  }

  @override
  Widget buildBody(BuildContext context) {
    final state = ref.watch(ongoingChallengeViewModelProvider);

    return state.when(
      data: (data) {
        final items = data.challenges;
        final totalCount = items.length;
        final completedCount =
            items.where((element) => element.completed).length;
        return SingleChildScrollView(
          controller: scrollController,
          child: RepaintBoundary(
            key: _screenKey,
            child: Container(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              padding: AppPaddings.SCREEN_BODY_PADDING,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  _buildHeaderSection(
                    totalCount: totalCount,
                    completedCount: completedCount,
                    onScreenShot: () async {
                      final result = await FullCaptureService.captureAndShow(
                          context, _screenKey);
                      bool? isSaved = result?['isSaved'];
                      if (isSaved == true && context.mounted) {
                        await showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            barrierColor: ColorName.b1.withValues(alpha: 0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20)),
                            ),
                            builder: (context) => SaveSuccessImageDialog());
                      }
                    },
                    onCalender: () {
                      /** 캘린더 */
                      // TODO: 포인트 내역
                    },
                    onNew: () {
                      /** 새로운책 읽기*/
                      context.go('/reading-challenge/search-new');
                    },
                  ),
                  SizedBox(height: 35),
                  // 리스트
                  _buildListSection(
                    items: items,
                    onTapItem: (item, index) {
                      setState(() {
                        _targetIndex = index;
                      });
                    },
                    targetIndex: _targetIndex,
                    newIndex: _newIndex,
                  ),
                  if (_targetIndex != null)
                    SizedBox(
                      height: 80,
                    )
                ],
              ),
            ),
          ),
        );
      },
      error: error("리딩챌린지 정보를 가져오는데 실패했습니다."),
      loading: loading,
    );
  }

  // Header
  Widget _buildHeaderSection({
    required int totalCount,
    required int completedCount,
    required Function onScreenShot,
    required Function onCalender,
    required Function onNew,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                text: "지금까지 ",
                style: AppTexts.b5.copyWith(color: ColorName.g2),
                children: [
                  TextSpan(
                    text: "$totalCount",
                    style: AppTexts.h4.copyWith(color: ColorName.w1),
                  ),
                  TextSpan(text: "권 읽고"),
                ],
              ),
            ),
            Text.rich(
              TextSpan(
                text: "$completedCount",
                style: AppTexts.h4.copyWith(color: ColorName.w1),
                children: [
                  TextSpan(
                    text: "권 완독했어요!",
                    style: AppTexts.b5.copyWith(color: ColorName.g2),
                  ),
                ],
              ),
            ),
          ],
        ),
        Row(
          children: [
            /** 캡처 */
            GestureDetector(
              onTap: () => onScreenShot(),
              child: Icon(Icons.crop_free, color: ColorName.w1),
            ),
            SizedBox(width: 8),
            /** 새로운 책 읽기 */
            GestureDetector(
              onTap: () => onNew(),
              child: Assets.icons.icPlus.svg(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildListSection({
    required List<ChallengeResponse> items,
    required Function(ChallengeResponse, int) onTapItem,
    required int? targetIndex,
    required int? newIndex,
  }) {
    return Flexible(
      child: CustomListView(
          emptyIcon: Assets.icons.icBookpickSearchCharacter.svg(),
          emptyText: '읽던 책이 없네요!',
          emptyTextStyle: AppTexts.b8.copyWith(color: ColorName.w1),
          isEmpty: items.isEmpty,
          disableScroll: true,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];

            final isSelectedMode = targetIndex != null;
            final isTarget = targetIndex == index;
            final isNew = newIndex == index;

            double angle = 0;
            switch (index % 3) {
              case 0:
                angle = 0;
                break;
              case 1:
                angle = 0.2;
                break;
              case 2:
                angle = -0.2;
                break;
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GestureDetector(
                onTap: () {
                  onTapItem(item, index);
                },
                child: Opacity(
                  opacity: !isSelectedMode ? 1 : (isTarget ? 1 : 0.6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Transform.rotate(
                        angle: angle,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 125,
                              height: 170,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                border: BoxBorder.all(color: Color(0xFFF5F5F5)),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: CachedNetworkImage(
                                  imageUrl: item.bookImageUrl,
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) {
                                    return Container();
                                  },
                                ),
                              ),
                            ),
                            if (isNew)
                              Positioned(
                                top: -8, // 음수 값으로 위로 올림
                                left: -8, // 왼쪽 여백
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color: ColorName.p1,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 1),
                                    child: Text("NEW",
                                        style: AppTexts.b9
                                            .copyWith(color: ColorName.w1)),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.bookTitle,
                                    style: AppTexts.b7
                                        .copyWith(color: ColorName.w1),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: RadialGradient(
                                      colors: [
                                        ColorName.p1,
                                        ColorName.b1,
                                      ],
                                      stops: [0.2, 1.0], // 20%에서 보라 → 100%에서 검정
                                      center: Alignment.bottomCenter, // 중심 고정
                                      radius: 0.85, // 퍼지는 정도 (1.0이면 꽉 채움)
                                    ),
                                    color: ColorName.b1,
                                    border:
                                        Border.all(color: Color(0xFFA99AFF)),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 3),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Assets.icons.icReadingChallengeTimeRate
                                            .svg(),
                                        SizedBox(
                                          width: 4,
                                        ),
                                        Text(
                                          "${item.progressPercentage}%",
                                          style: AppTexts.b7
                                              .copyWith(color: ColorName.p2),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Row(
                              children: [
                                Text(
                                  "저자: ",
                                  style: AppTexts.b10
                                      .copyWith(color: ColorName.g2),
                                ),
                                Expanded(
                                  child: Text(
                                    item.bookAuthor,
                                    style: AppTexts.b10
                                        .copyWith(color: ColorName.w1),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
          separatorBuilder: (context, index) => Container()),
    );
  }

  @override
  Widget? buildFloatingActionButton(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final state = ref.watch(ongoingChallengeViewModelProvider);

    if (_targetIndex == null || (state.value?.challenges.isEmpty ?? true)) {
      return null;
    }

    if (_targetIndex! >= state.value!.challenges.length) {
      // This can happen if the list of challenges changes after an index has been selected.
      // Returning null is a safe fallback.
      return null;
    }

    final hasQuiz = state.value!.challenges[_targetIndex!].hasQuiz;

    return SizedBox(
      width: deviceWidth * 0.9,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (!hasQuiz)
            Column(
              children: [
                Container(
                    decoration: BoxDecoration(
                      color: ColorName.dim3,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Assets.icons.icStar4Filled.svg(),
                          SizedBox(
                            width: 8,
                          ),
                          Text(
                            "책이 더 궁금해지는 퀴즈를 준비하고 있어요",
                            style:
                                AppTexts.b8.copyWith(color: ColorName.w1),
                          ),
                        ],
                      ),
                    )),
                SizedBox(
                  height: 16,
                ),
              ],
            ),
          CtaButtonL1(
            text: '리딩 챌린지 시작하기',
            enabled: hasQuiz,
            onPressed: () {
              goToStartScreen();
            },
          ),
        ],
      ),
    );
  }

  void goToStartScreen() {
    final state = ref.watch(ongoingChallengeViewModelProvider);
    final challengeId = state.value!.challenges[_targetIndex!].challengeId;
    context.push('/reading-challenge/start/$challengeId');
  }
}
