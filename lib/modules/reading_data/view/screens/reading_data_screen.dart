import 'package:bookstar/common/components/base_screen.dart';
import 'package:bookstar/common/theme/style/app_texts.dart';
import 'package:bookstar/gen/assets.gen.dart';
import 'package:bookstar/gen/colors.gen.dart';
import 'package:bookstar/modules/reading_data/model/ranking_weekly_response.dart';
import 'package:bookstar/modules/reading_data/view_model/reading_data_view_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

class ReadingDataScreen extends BaseScreen {
  const ReadingDataScreen({
    super.key,
  });

  @override
  BaseScreenState<ReadingDataScreen> createState() => _ReadingDataScreenState();
}

class _ReadingDataScreenState extends BaseScreenState<ReadingDataScreen> {
  @override
  bool enableRefreshIndicator() => true;

  @override
  Future<void> onRefresh() async {
    ref.read(readingDataViewModelProvider.notifier).initState();
  }

  void onItemTap(int memberId) {
    context.push('/book-log/thumbnail/$memberId');
  }

  void goToDetail() {
    context.push('/reading-data/detail');
  }

  @override
  Widget buildBody(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final podium1Height = deviceHeight * 0.4;
    final podium23Height = podium1Height * 0.8;
    final state = ref.watch(readingDataViewModelProvider);

    return state.when(
        data: (data) {
          return SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Container(
                constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width,
                ),
                decoration: BoxDecoration(
                  color: ColorName.b1,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: ColorName.p2.withValues(alpha: 0.15),
                      spreadRadius: 2,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("챌린지 참여 랭킹",
                          style: AppTexts.b8.copyWith(color: ColorName.p2)),
                      SizedBox(
                        height: 6,
                      ),
                      Text("독서는 꾸준히 퀴즈는 완벽히!",
                          style: AppTexts.b1.copyWith(color: ColorName.w1)),
                      Text("이번주 상위 랭커🏆",
                          style: AppTexts.b1.copyWith(color: ColorName.w1)),
                      SizedBox(
                        height: 16,
                      ),
                      GestureDetector(
                        onTap: goToDetail,
                        child: Container(
                            decoration: BoxDecoration(
                                color: ColorName.dim3,
                                borderRadius: BorderRadius.circular(100)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "이번주 나는 몇위일까?",
                                    style: AppTexts.b8
                                        .copyWith(color: ColorName.g1),
                                  ),
                                  SizedBox(
                                    width: 4,
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 12,
                                    color: ColorName.g1,
                                  ),
                                ],
                              ),
                            )),
                      ),
                      SizedBox(
                        height: 36,
                      ),
                      Container(
                        constraints: BoxConstraints(
                          minHeight: podium1Height,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          spacing: 8,
                          children: [
                            Expanded(
                                child: _buildPodium(
                              podiumHeight: podium23Height,
                              podiumColor: ColorName.g7,
                              rank: 2,
                              item: data.top2,
                              onItemTap: onItemTap,
                            )),
                            Expanded(
                                child: _buildPodium(
                              podiumHeight: podium1Height,
                              podiumColor: ColorName.p1,
                              rank: 1,
                              item: data.top1,
                              onItemTap: onItemTap,
                            )),
                            Expanded(
                                child: _buildPodium(
                              podiumHeight: podium23Height,
                              podiumColor: ColorName.g7,
                              rank: 3,
                              item: data.top3,
                              onItemTap: onItemTap,
                            )),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        loading: loading,
        error: error("리딩 데이터 정보를 불러올 수 없습니다."));
  }

  Widget _buildPodium({
    required double podiumHeight,
    required Color podiumColor,
    required int rank,
    required RankingWeeklyResponse? item,
    required Function(int) onItemTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: podiumColor,
        borderRadius: BorderRadius.circular(16),
      ),
      height: podiumHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          children: [
            Text("$rank", style: AppTexts.b1.copyWith(color: ColorName.w1)),
            if (item != null)
              GestureDetector(
                onTap: () {
                  onItemTap(item.memberId);
                },
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    CircleAvatar(
                      backgroundColor: ColorName.g7,
                      backgroundImage: item.profileImage.isNotEmpty
                          ? CachedNetworkImageProvider(
                              item.profileImage,
                            )
                          : null,
                      child: null,
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    Text(
                      item.nickname,
                      style: AppTexts.b5.copyWith(
                          color: rank != 1 ? ColorName.g2 : ColorName.w1),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Column(
                      spacing: 4,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: Assets.icons.icReadingDataParticipationDays
                                  .svg(
                                colorFilter: ColorFilter.mode(
                                  rank != 1 ? ColorName.g2 : ColorName.w1,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            Text(
                              "${item.participationDays}일 참여",
                              style: AppTexts.b10.copyWith(
                                  color:
                                      rank != 1 ? ColorName.g2 : ColorName.w1),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: Assets.icons.icReadingDataSolvedCount.svg(
                                colorFilter: ColorFilter.mode(
                                  rank != 1 ? ColorName.g2 : ColorName.w1,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            Text(
                              "${item.solvedCount} 문제",
                              style: AppTexts.b10.copyWith(
                                  color:
                                      rank != 1 ? ColorName.g2 : ColorName.w1),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: Assets.icons.icReadingDataCorrectCount.svg(
                                colorFilter: ColorFilter.mode(
                                  rank != 1 ? ColorName.g2 : ColorName.w1,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            Text(
                              "${item.correctCount} 정답",
                              style: AppTexts.b10.copyWith(
                                  color:
                                      rank != 1 ? ColorName.g2 : ColorName.w1),
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}
