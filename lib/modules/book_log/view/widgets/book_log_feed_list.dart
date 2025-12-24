import 'package:bookstar/common/service/analytics_service.dart';
import 'package:bookstar/common/theme/style/app_texts.dart';
import 'package:bookstar/gen/assets.gen.dart';
import 'package:bookstar/gen/colors.gen.dart';
import 'package:bookstar/modules/book_log/view/widgets/feed_card.dart';
import 'package:bookstar/modules/reading_diary/model/diary_response.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class BookLogFeedList extends StatefulWidget {
  const BookLogFeedList(
      {super.key,
      required this.feeds,
      // required this.followInfo,
      required this.itemScrollController,
      required this.itemPositionsListener,
      this.initialIndex,
      required this.onLike,
      required this.onMessage,
      required this.onDelete,
      required this.onReport,
      required this.onProfile,
      required this.onScrap,
      required this.onUpdate,
      required this.onBookTitle,
      this.onScrollChanged,
      this.visibleMenu = true});
  final List<DiaryResponse> feeds;
  // final FollowInfoState followInfo;
  final int? initialIndex;
  final Function(int) onLike;
  final Function(BuildContext, int) onMessage;
  final Function(BuildContext, int) onDelete;
  final Function(BuildContext, int) onReport;
  final Function(int) onProfile;
  final Function(int) onScrap;
  final Function(int) onUpdate;
  final Function(int) onBookTitle;
  final Function(bool)? onScrollChanged;
  final ItemScrollController itemScrollController;
  final ItemPositionsListener itemPositionsListener;
  final bool visibleMenu;

  @override
  State<BookLogFeedList> createState() => BookLogFeedListState();
}

class BookLogFeedListState extends State<BookLogFeedList> {
  @override
  void initState() {
    super.initState();
    if (widget.initialIndex != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _jumpToIndex(widget.initialIndex!);
      });
    }
  }

  void _jumpToIndex(int index, {bool animate = false}) {
    if (mounted) {
      if (!animate) {
        widget.itemScrollController.jumpTo(
          index: index,
        );
      } else {
        widget.itemScrollController.scrollTo(
          index: index,
          duration: const Duration(milliseconds: 500), // 애니메이션 시간
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feeds = widget.feeds;
    final currentRoute = GoRouter.of(context).routerDelegate.currentConfiguration.uri.path;

    return feeds.isNotEmpty
        ? ScrollablePositionedList.separated(
            itemScrollController: widget.itemScrollController,
            itemPositionsListener: widget.itemPositionsListener,
            itemCount: feeds.length,
            itemBuilder: (context, index) {
              final feed = feeds[index];
              return FeedCard(
                feed: feed,
                onLike: () {
                  AnalyticsService.logEvent(
                    'click_feed_like',
                    parameters: {
                      'screen_name': currentRoute,
                      'diary_id': feed.diaryId,
                      'book_id': feed.bookId,
                    },
                  );
                  widget.onLike(index);
                },
                onMessage: () {
                  AnalyticsService.logEvent(
                    'click_feed_comment',
                    parameters: {
                      'screen_name': currentRoute,
                      'diary_id': feed.diaryId,
                      'book_id': feed.bookId,
                    },
                  );
                  widget.onMessage(context, index);
                },
                onDelete: () => widget.onDelete(context, index),
                onReport: () => widget.onReport(context, index),
                onProfile: () {
                  AnalyticsService.logEvent(
                    'click_feed_profile',
                    parameters: {
                      'screen_name': currentRoute,
                      'diary_id': feed.diaryId,
                      'member_id': feed.memberId,
                    },
                  );
                  widget.onProfile(index);
                },
                onScrap: () {
                  AnalyticsService.logEvent(
                    'click_feed_scrap',
                    parameters: {
                      'screen_name': currentRoute,
                      'diary_id': feed.diaryId,
                      'book_id': feed.bookId,
                    },
                  );
                  widget.onScrap(index);
                },
                onUpdate: () => widget.onUpdate(index),
                onBookTitle: () {
                  AnalyticsService.logEvent(
                    'click_feed_book_title',
                    parameters: {
                      'screen_name': currentRoute,
                      'diary_id': feed.diaryId,
                      'book_id': feed.bookId,
                    },
                  );
                  widget.onBookTitle(index);
                },
                visibleMenu: widget.visibleMenu,
              );
            },
            separatorBuilder: (context, index) => const Divider(
              color: ColorName.g7,
              height: 0,
              thickness: 1,
              indent: 16,
              endIndent: 16,
            ),
          )
        : LayoutBuilder(builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Assets.icons.icBooktalkSearchCharacter.svg(
                        width: 110,
                        height: 110,
                      ),
                      SizedBox(height: 18),
                      Text(
                        "팔로잉하는 유저들이\n리딩 챌린지를 시작하지 않았어요",
                        textAlign: TextAlign.center,
                        style: AppTexts.b7.copyWith(color: ColorName.w1),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "가장 먼저 리딩 챌린지를 시작하고, 유저들의 도전을 응원해 보세요!",
                        style: AppTexts.b10.copyWith(color: ColorName.g2),
                      ),
                    ],
                  ),
                ),
              ),
            );
          });
  }
}
