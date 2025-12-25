import 'package:bookstar/common/components/base_screen.dart';
import 'package:bookstar/common/components/button/menu_button.dart';
import 'package:bookstar/common/theme/style/app_texts.dart';
import 'package:bookstar/gen/assets.gen.dart';
import 'package:bookstar/modules/auth/view_model/auth_state.dart';
import 'package:bookstar/modules/auth/view_model/auth_view_model.dart';
import 'package:bookstar/modules/book_log/view/widgets/book_log_profile.dart';
import 'package:bookstar/modules/book_log/view/widgets/book_log_thumbnail_grid.dart';
import 'package:bookstar/modules/book_log/view/widgets/profile_speech_bubble.dart';
import 'package:bookstar/modules/book_log/view/widgets/report_dialog.dart';
import 'package:bookstar/modules/book_log/view/widgets/report_success_dialog.dart';
import 'package:bookstar/modules/follow/view_model/follow_info_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../gen/colors.gen.dart';
import '../../view_model/book_log_view_model.dart';

class BookLogThumbnailScreen extends BaseScreen {
  const BookLogThumbnailScreen(
      {super.key, required this.memberId, this.requiredRefresh = false});
  final int memberId;
  final bool requiredRefresh;

  @override
  BaseScreenState<BookLogThumbnailScreen> createState() =>
      _BookLogThumbnailScreenState();
}

class _BookLogThumbnailScreenState
    extends BaseScreenState<BookLogThumbnailScreen> {
  @override
  bool enableRefreshIndicator() => true;

  @override
  int getListTotalItemCount() =>
      ref
          .watch(bookLogViewModelProvider(widget.memberId))
          .value
          ?.thumbnails
          .length ??
      0;

  @override
  Future<void> onInitState() async {
    if (widget.requiredRefresh) {
      final bookLogNotifier =
          ref.read(bookLogViewModelProvider(widget.memberId).notifier);
      await bookLogNotifier.initState(widget.memberId);
    }
  }

  @override
  Future<void> onRefresh() async {
    final bookLogNotifier =
        ref.read(bookLogViewModelProvider(widget.memberId).notifier);
    await bookLogNotifier.initState(widget.memberId);
  }

  @override
  Future<void> onBottomReached() async {
    final bookLogNotifier =
        ref.read(bookLogViewModelProvider(widget.memberId).notifier);
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
                      style: AppTexts.b11.copyWith(color: ColorName.g1),
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
    final user = ref.watch(authViewModelProvider).value;
    final isMyProfile =
        (user is AuthSuccess && user.memberId == widget.memberId);
    final followInfoNotifier = ref.read(followInfoViewModelProvider.notifier);

    return AppBar(
        title: const Text('책로그'),
        leading: IconButton(
          icon: const BackButton(),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (!isMyProfile)
            MenuButton(
              maxWidth: 90,
              menus: [
                MenuButtonItem(
                  value: "report",
                  label: "신고하기",
                )
              ],
              icon: Assets.icons.icMenuMore.svg(color: ColorName.g3),
              onSelected: (value) async {
                switch (value) {
                  case "report":
                    final result = await showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: ColorName.b1,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (context) => ReportDialog());

                    if (result == null) return;
                    ReportType? reportType = result?['reportType'];
                    String? content = result?['content'];

                    if (reportType == null || content == null) return;
                    followInfoNotifier.reportMember(
                        widget.memberId, reportType, content);
                    if (!context.mounted) return;
                    await showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: ColorName.b1,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (context) => ReportSuccessDialog());
                    break;
                  default:
                }
              },
            ),
          if (isMyProfile)
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => context.push('/my-feed/my-page'),
            )
        ]);
  }

  @override
  Widget buildBody(BuildContext context) {
    final bookLogAsync = ref.watch(bookLogViewModelProvider(widget.memberId));
    final bookLogNotifier =
        ref.read(bookLogViewModelProvider(widget.memberId).notifier);
    final user = ref.watch(authViewModelProvider).value;
    final followInfo = ref.watch(followInfoViewModelProvider).value;
    final followInfoNotifier = ref.read(followInfoViewModelProvider.notifier);
    final isMyProfile =
        (user is AuthSuccess && user.memberId == widget.memberId);
    final isFollowing = followInfo?.following
            .map((e) => e.memberId)
            .contains(widget.memberId) ??
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
                          await followInfoNotifier.unfollow(widget.memberId);
                        } else {
                          await followInfoNotifier.follow(widget.memberId);
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
                          context.push('/book-log/feed/${widget.memberId}',
                              extra: {
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
