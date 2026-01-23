import 'package:bookstar/common/components/base_screen.dart';
import 'package:bookstar/common/components/custom_list_view.dart';
import 'package:bookstar/common/theme/style/app_paddings.dart';
import 'package:bookstar/common/theme/style/app_texts.dart';
import 'package:bookstar/gen/assets.gen.dart';
import 'package:bookstar/gen/colors.gen.dart';
import 'package:bookstar/modules/reading_challenge/model/challenge_response.dart';
import 'package:bookstar/common/service/full_capture_service.dart';
import 'package:bookstar/modules/reading_challenge/view/widgets/save_success_image_dialog.dart';
import 'package:bookstar/modules/reading_challenge/view_model/completed_challenge_view_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReadingChallengeCompletedScreen extends BaseScreen {
  const ReadingChallengeCompletedScreen({
    super.key,
  });

  @override
  BaseScreenState<ReadingChallengeCompletedScreen> createState() =>
      _ReadingChallengeCompletedScreenState();
}

class _ReadingChallengeCompletedScreenState
    extends BaseScreenState<ReadingChallengeCompletedScreen> {
  @override
  bool enableRefreshIndicator() => true;
  final GlobalKey _screenKey = GlobalKey();

  @override
  Future<void> onRefresh() async {
    final notifier = ref.read(completedChallengeViewModelProvider.notifier);
    await notifier.initState();
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('리딩 챌린지'),
      leading: IconButton(
        icon: const BackButton(),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    final state = ref.watch(completedChallengeViewModelProvider);

    return state.when(
      data: (data) {
        final items = data.challenges;
        final completedCount = data.completedCount;
        return SingleChildScrollView(
          controller: scrollController,
          child: RepaintBoundary(
            key: _screenKey,
            child: Container(
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width,
                minHeight: MediaQuery.of(context).size.height,
              ),
              padding: AppPaddings.SCREEN_BODY_PADDING,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  _buildHeaderSection(
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
                  ),
                  SizedBox(height: 35),
                  // 리스트
                  _buildListSection(
                    items: items,
                  ),
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
    required int completedCount,
    required Function onScreenShot,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    text: "지금까지 총 ",
                    style: AppTexts.b5.copyWith(color: ColorName.g1),
                    children: [
                      TextSpan(
                        text: "$completedCount",
                        style: AppTexts.h4.copyWith(color: ColorName.w1),
                      ),
                      TextSpan(text: "권을 완독하고"),
                    ],
                  ),
                ),
                Text(
                  "챌린지에 성공했어요",
                  style: AppTexts.b5.copyWith(color: ColorName.g1),
                )
              ],
            ),
            Row(
              children: [
                /** 캡처 */
                GestureDetector(
                  onTap: () => onScreenShot(),
                  child: Icon(Icons.crop_free, color: ColorName.w1),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildListSection({
    required List<ChallengeResponse> items,
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
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
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
                                        stops: [
                                          0.2,
                                          1.0
                                        ], // 20%에서 보라 → 100%에서 검정
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
                                          Assets
                                              .icons.icReadingChallengeTimeRate
                                              .svg(),
                                          SizedBox(
                                            width: 4,
                                          ),
                                          Text(
                                            "${item.progressRate}%",
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
                        ),
                      ],
                    ),
                  )
                ],
              ),
            );
          },
          separatorBuilder: (context, index) => Container()),
    );
  }
}
