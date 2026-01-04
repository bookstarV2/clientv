import 'package:bookstar/common/components/base_screen.dart';
import 'package:bookstar/common/components/custom_list_view.dart';
import 'package:bookstar/common/theme/style/app_texts.dart';
import 'package:bookstar/gen/assets.gen.dart';
import 'package:bookstar/gen/colors.gen.dart';
import 'package:bookstar/modules/reading_data/view_model/reading_data_view_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

class ReadingDataDetailScreen extends BaseScreen {
  const ReadingDataDetailScreen({
    super.key,
  });

  @override
  BaseScreenState<ReadingDataDetailScreen> createState() =>
      _ReadingDataDetailScreenState();
}

class _ReadingDataDetailScreenState
    extends BaseScreenState<ReadingDataDetailScreen> {
  @override
  bool enableRefreshIndicator() => true;

  @override
  Future<void> onRefresh() async {
    ref.read(readingDataViewModelProvider.notifier).initState();
  }

  void onItemTap(int memberId) {
    context.push('/book-log/thumbnail/$memberId');
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('리딩 데이터'),
      leading: IconButton(
        icon: const BackButton(),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    final state = ref.watch(readingDataViewModelProvider);

    return state.when(
        data: (data) {
          return SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("챌린지 참여 랭킹",
                      style: AppTexts.b1.copyWith(color: ColorName.w1)),
                  SizedBox(
                    height: 6,
                  ),
                  Text("총 ${data.list.length}명 참여",
                      style: AppTexts.b8.copyWith(color: ColorName.g3)),
                  SizedBox(
                    height: 36,
                  ),
                  CustomListView(
                      disableScroll: true,
                      emptyIcon: Assets.icons.icBookpickSearchCharacter.svg(),
                      emptyText: '참여자 정보가 없습니다.',
                      isEmpty: data.list.isEmpty,
                      itemCount: data.list.length,
                      itemBuilder: (context, index) {
                        final item = data.list[index];

                        String rankText = "${item.rank}";
                        if (item.rank == 1) {
                          rankText = "🥇";
                        } else if (item.rank == 2) {
                          rankText = "🥈";
                        } else if (item.rank == 3) {
                          rankText = "🥉";
                        } else if (item.rank == -1) {
                          rankText = "-";
                        }

                        return GestureDetector(
                          onTap: () => onItemTap(item.memberId),
                          child: Row(
                            children: [
                              Text(rankText,
                                  style: AppTexts.b1
                                      .copyWith(color: ColorName.w1)),
                              SizedBox(
                                width: 24,
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
                                width: 12,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.nickname,
                                    style: AppTexts.b5
                                        .copyWith(color: ColorName.w1),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(
                                    height: 4,
                                  ),
                                  Row(
                                    spacing: 10,
                                    children: [
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: Assets.icons
                                                .icReadingDataParticipationDays
                                                .svg(
                                              colorFilter: ColorFilter.mode(
                                                ColorName.w1,
                                                BlendMode.srcIn,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 4,
                                          ),
                                          Text(
                                            "${item.participationDays}일 참여",
                                            style: AppTexts.b10
                                                .copyWith(color: ColorName.w1),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: Assets
                                                .icons.icReadingDataSolvedCount
                                                .svg(
                                              colorFilter: ColorFilter.mode(
                                                ColorName.w1,
                                                BlendMode.srcIn,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 4,
                                          ),
                                          Text(
                                            "${item.solvedCount} 문제",
                                            style: AppTexts.b10
                                                .copyWith(color: ColorName.w1),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: Assets
                                                .icons.icReadingDataCorrectCount
                                                .svg(
                                              colorFilter: ColorFilter.mode(
                                                ColorName.w1,
                                                BlendMode.srcIn,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 4,
                                          ),
                                          Text(
                                            "${item.correctCount} 정답",
                                            style: AppTexts.b10
                                                .copyWith(color: ColorName.w1),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                ],
                              )
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return SizedBox(
                          height: 24,
                        );
                      }),
                  SizedBox(
                    height: 60,
                  ),
                ],
              ),
            ),
          );
        },
        loading: loading,
        error: error("리딩 데이터 정보를 불러올 수 없습니다."));
  }

  @override
  Widget? buildFloatingActionButton(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final state = ref.watch(readingDataViewModelProvider);

    return state.when(
        data: (data) {
          final item = data.my;

          String rankText = "${item.rank}";
          if (item.rank == 1) {
            rankText = "🥇";
          } else if (item.rank == 2) {
            rankText = "🥈";
          } else if (item.rank == 3) {
            rankText = "🥉";
          } else if (item.rank == -1) {
            rankText = "-";
          }
          return GestureDetector(
            onTap: () => onItemTap(item.memberId),
            child: Container(
              width: deviceWidth * 0.9,
              decoration: BoxDecoration(
                color: ColorName.dim3,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(rankText,
                        style: AppTexts.b1.copyWith(color: ColorName.w1)),
                    SizedBox(
                      width: 24,
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
                      width: 12,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.nickname,
                          style: AppTexts.b5.copyWith(color: ColorName.w1),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Row(
                          spacing: 10,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: Assets
                                      .icons.icReadingDataParticipationDays
                                      .svg(
                                    colorFilter: ColorFilter.mode(
                                      ColorName.w1,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                Text(
                                  "${item.participationDays}일 참여",
                                  style: AppTexts.b10
                                      .copyWith(color: ColorName.w1),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child:
                                      Assets.icons.icReadingDataSolvedCount.svg(
                                    colorFilter: ColorFilter.mode(
                                      ColorName.w1,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                Text(
                                  "${item.solvedCount} 문제",
                                  style: AppTexts.b10
                                      .copyWith(color: ColorName.w1),
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
                                  child: Assets.icons.icReadingDataCorrectCount
                                      .svg(
                                    colorFilter: ColorFilter.mode(
                                      ColorName.w1,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                Text(
                                  "${item.correctCount} 정답",
                                  style: AppTexts.b10
                                      .copyWith(color: ColorName.w1),
                                ),
                              ],
                            ),
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        },
        loading: loading,
        error: error("리딩 데이터 정보를 불러올 수 없습니다."));
  }
}
