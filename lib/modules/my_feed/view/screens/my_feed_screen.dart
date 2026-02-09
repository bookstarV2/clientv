import 'package:bookstar/common/components/base_screen.dart';
import 'package:bookstar/common/theme/style/app_texts.dart';
import 'package:bookstar/modules/auth/view_model/auth_state.dart';
import 'package:bookstar/modules/auth/view_model/auth_view_model.dart';
import 'package:bookstar/modules/book_log/view/widgets/book_log_profile.dart';
import 'package:bookstar/modules/book_log/view/widgets/book_log_thumbnail_grid.dart';
import 'package:bookstar/modules/book_log/view/widgets/profile_speech_bubble.dart';
import 'package:bookstar/modules/book_log/view_model/book_log_view_model.dart';
import 'package:bookstar/modules/follow/view_model/follow_info_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../gen/colors.gen.dart';

class MyFeedScreen extends BaseScreen {
  const MyFeedScreen({super.key, this.requiredRefresh = false});
  final bool requiredRefresh;

  @override
  BaseScreenState<MyFeedScreen> createState() => _MyFeedScreenState();
}

class _MyFeedScreenState extends BaseScreenState<MyFeedScreen> {
  @override
  bool enableRefreshIndicator() => true;

  @override
  int getListTotalItemCount() {
    final userAsync = ref.read(authViewModelProvider);
    final user = userAsync.value;
    final currentMemberId = (user is AuthSuccess) ? user.memberId : -1;

    return ref
            .read(bookLogViewModelProvider(currentMemberId))
            .value
            ?.thumbnails
            .length ??
        0;
  }

  @override
  Future<void> onInitState() async {
    final userAsync = ref.read(authViewModelProvider);
    final user = userAsync.value;
    final currentMemberId = (user is AuthSuccess) ? user.memberId : -1;
    if (widget.requiredRefresh) {
      final bookLogNotifier =
          ref.read(bookLogViewModelProvider(currentMemberId).notifier);
      await bookLogNotifier.initState(currentMemberId);
    }
  }

  @override
  Future<void> onRefresh() async {
    final userAsync = ref.watch(authViewModelProvider);
    final user = userAsync.value;
    final currentMemberId = (user is AuthSuccess) ? user.memberId : -1;
    final bookLogNotifier =
        ref.read(bookLogViewModelProvider(currentMemberId).notifier);
    await bookLogNotifier.initState(currentMemberId);
  }

  @override
  Future<void> onBottomReached() async {
    final userAsync = ref.watch(authViewModelProvider);
    final user = userAsync.value;
    final currentMemberId = (user is AuthSuccess) ? user.memberId : -1;
    final bookLogNotifier =
        ref.read(bookLogViewModelProvider(currentMemberId).notifier);
    await bookLogNotifier.refreshContentState();
  }

  _onTapBubble({
    required String nickName,
    required String profileImageUrl,
    required String introduction,
  }) {
    showDialog(
      context: context,
      barrierColor: ColorName.b1.withAlpha(204),
      builder: (context) {
        return Material(
          type: MaterialType.transparency,
          child: Center(
            child: Container(
              width: 300,
              height: 200,
              decoration: BoxDecoration(
                  color: ColorName.g7, borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SizedBox(
                      width: 55,
                      height: 55,
                      child: CircleAvatar(
                        backgroundColor: ColorName.g7,
                        backgroundImage: profileImageUrl.isNotEmpty
                            ? NetworkImage(profileImageUrl)
                            : null,
                      ),
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    Text(
                      "@$nickName",
                      style: AppTexts.b7.copyWith(color: ColorName.p1),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Text(
                      introduction,
                      style: AppTexts.b8.copyWith(color: ColorName.g1),
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    final isMyProfile = true;
    return AppBar(title: const Text('마이피드'), actions: [
      if (isMyProfile)
        IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => context.push('/my-feed/my-page'),
        )
    ]);
  }

  @override
  Widget buildBody(BuildContext context) {
    final userAsync = ref.watch(authViewModelProvider);
    final user = userAsync.value;
    final currentMemberId = (user is AuthSuccess) ? user.memberId : -1;
    final bookLogAsync = ref.watch(bookLogViewModelProvider(currentMemberId));
    final bookLogNotifier =
        ref.read(bookLogViewModelProvider(currentMemberId).notifier);
    final followInfo = ref.watch(followInfoViewModelProvider).value;
    final followInfoNotifier = ref.read(followInfoViewModelProvider.notifier);
    final isMyProfile = true;
    final isFollowing = followInfo?.following
            .map((e) => e.memberId)
            .contains(currentMemberId) ??
        false;

    return bookLogAsync.when(
        data: (bookLog) => Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    BookLogProfile(
                      profile: bookLog.profile,
                      isMyProfile: isMyProfile,
                      isFollowing: isFollowing,
                      onEdit: () => context.push('/my-feed/profile'),
                      onFollow: () async {
                        if (isFollowing) {
                          await followInfoNotifier.unfollow(currentMemberId);
                        } else {
                          await followInfoNotifier.follow(currentMemberId);
                        }
                        await bookLogNotifier.refreshFollowState();
                      },
                      profileImageKey: GlobalKey(),
                    ),
                    const SizedBox(height: 20),
                    BookLogThumbnailGrid(
                        thumbnails: bookLog.thumbnails,
                        scrollController: scrollController,
                        onClickThumbnail: (int targetIndex) {
                          context
                              .push('/my-feed/feed/$currentMemberId', extra: {
                            'index': targetIndex,
                          });
                        }),
                  ],
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: ProfileSpeechBubble(
                      text: bookLog.profile.introduction,
                      onTap: () => _onTapBubble(
                          nickName: bookLog.profile.nickName,
                          profileImageUrl: bookLog.profile.profileImageUrl,
                          introduction: bookLog.profile.introduction)),
                ),
              ],
            ),
        error: error("북로그 정보를 불러올 수 없습니다."),
        loading: loading);
  }
}
