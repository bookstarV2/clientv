import 'package:bookstar/common/components/button/menu_button.dart';
import 'package:bookstar/common/components/text/expandable_text.dart';
import 'package:bookstar/common/service/analytics_service.dart';
import 'package:bookstar/gen/assets.gen.dart';
import 'package:bookstar/modules/auth/model/auth_response.dart';
import 'package:bookstar/modules/auth/view_model/auth_state.dart';
import 'package:bookstar/modules/auth/view_model/auth_view_model.dart';
import 'package:bookstar/modules/book_log/view/widgets/star_badge.dart';
import 'package:bookstar/modules/reading_diary/model/diary_response.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:bookstar/common/theme/style/app_texts.dart';
import 'package:bookstar/gen/colors.gen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class FeedCard extends ConsumerStatefulWidget {
  const FeedCard({
    super.key,
    required this.feed,
    required this.onLike,
    required this.onMessage,
    required this.onDelete,
    required this.onReport,
    required this.onProfile,
    required this.onScrap,
    required this.onUpdate,
    required this.onBookTitle,
    this.visibleMenu = true,
  });

  final DiaryResponse feed;
  final Function onLike;
  final Function onMessage;
  final Function onDelete;
  final Function onReport;
  final Function onProfile;
  final Function onScrap;
  final Function onUpdate;
  final Function onBookTitle;
  final bool visibleMenu;

  @override
  ConsumerState<FeedCard> createState() => _FeedCardState();
}

class _FeedCardState extends ConsumerState<FeedCard> {
  int _currentImageIndex = 0;
  void _onImageIndexChanged(int index) {
    setState(() {
      _currentImageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    DateTime dt = DateTime.parse(widget.feed.createdDate);
    String createdAt = DateFormat('yyyy/MM/dd').format(dt);
    final user = ref.watch(authViewModelProvider).value;
    final isMyFeed =
        widget.feed.memberId == ((user is AuthSuccess) ? user.memberId : 0);
    final isAdmin = (user as AuthSuccess?)?.memberRole == MemberRole.ADMIN;
    final currentRoute =
        GoRouter.of(context).routerDelegate.currentConfiguration.uri.path;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: 16,
            bottom: 16,
            left: 16,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => widget.onProfile(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: CircleAvatar(
                        backgroundColor: ColorName.g7,
                        backgroundImage: widget.feed.profileImageUrl.isNotEmpty
                            ? CachedNetworkImageProvider(
                                widget.feed.profileImageUrl,
                              )
                            : null,
                        child: widget.feed.profileImageUrl.isEmpty
                            ? const Icon(Icons.person,
                                size: 32, color: ColorName.g5)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 6),
                    // 닉네임
                    Center(
                      child: Text(
                        "@${widget.feed.nickname}",
                        style: AppTexts.b7.copyWith(color: ColorName.g3),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.visibleMenu)
                MenuButton(
                  menus: [
                    if (isMyFeed)
                      MenuButtonItem(
                        value: "update",
                        label: "수정하기",
                      ),
                    if (isMyFeed || isAdmin)
                      MenuButtonItem(
                        value: "delete",
                        label: "삭제하기",
                      ),
                    MenuButtonItem(
                      value: "report",
                      label: "신고하기",
                    )
                  ],
                  icon: Assets.icons.icMenuMore.svg(),
                  onSelected: (value) {
                    AnalyticsService.logEvent(
                      'click_feed_menu',
                      parameters: {
                        'screen_name': currentRoute,
                        'diary_id': widget.feed.diaryId,
                        'book_id': widget.feed.bookId,
                        'action': value,
                      },
                    );
                    switch (value) {
                      case "update":
                        widget.onUpdate();
                        break;
                      case "delete":
                        widget.onDelete();
                        break;
                      case "report":
                        widget.onReport();
                        break;
                      default:
                    }
                  },
                ),
            ],
          ),
        ),
        AspectRatio(
          aspectRatio: 1,
          child: PageView.builder(
            itemCount: widget.feed.images.length,
            onPageChanged: _onImageIndexChanged,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: CachedNetworkImage(
                  imageUrl: widget.feed.images[index].imageUrl,
                  fit: BoxFit.contain,
                  errorWidget: (context, url, error) => Container(),
                ),
              );
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.feed.images.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentImageIndex == index ? 20 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentImageIndex == index
                    ? ColorName.p1 // 활성화된 인디케이터 색상
                    : ColorName.g7, // 비활성화된 인디케이터 색상
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => widget.onLike(),
                    child: Row(
                      children: [
                        !widget.feed.liked
                            ? Assets.icons.icHeart.svg()
                            : Assets.icons.icHeartFilled.svg(),
                        const SizedBox(width: 3),
                        Text(
                          widget.feed.likeCount.toString(),
                          style: AppTexts.b10.copyWith(color: ColorName.w1),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => widget.onMessage(),
                    child: Row(
                      children: [
                        Assets.icons.icMessage.svg(),
                        const SizedBox(width: 3),
                        Text(
                          widget.feed.commentCount.toString(),
                          style: AppTexts.b10.copyWith(color: ColorName.w1),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => widget.onScrap(),
                  child: widget.feed.scraped
                      ? Assets.icons.icScrapFilled.svg()
                      : Assets.icons.icScrap.svg()),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => widget.onBookTitle(),
                      child: Text(
                        widget.feed.bookTitle,
                        style: AppTexts.b7.copyWith(color: ColorName.p1),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  if (widget.feed.bookRating > 0) const SizedBox(width: 3),
                  if (widget.feed.bookRating > 0)
                    StarBadge(rating: widget.feed.bookRating),
                  if (widget.feed.bookRating > 0) const SizedBox(width: 3),
                  Text(
                    createdAt,
                    style: AppTexts.b10.copyWith(color: ColorName.g3),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.feed.bookAuthor,
                      style: AppTexts.b11.copyWith(color: ColorName.p6),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ExpandableText(
                text: widget.feed.content,
                textStyle: AppTexts.b8.copyWith(color: ColorName.w1),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
