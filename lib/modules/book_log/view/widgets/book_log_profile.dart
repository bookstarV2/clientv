import 'package:bookstar/common/service/analytics_service.dart';
import 'package:bookstar/modules/book_log/view/widgets/follow_button.dart';
import 'package:bookstar/modules/profile/model/profile_with_counts.dart';
import 'package:flutter/material.dart';
import 'package:bookstar/gen/colors.gen.dart';
import 'package:bookstar/common/theme/style/app_texts.dart';
import 'package:go_router/go_router.dart';
import 'profile_stat.dart';
import 'stat_divider.dart';
import 'profile_edit_button.dart';

class BookLogProfile extends StatelessWidget {
  final ProfileWithCounts profile;
  final bool isMyProfile;
  final bool isFollowing;
  final VoidCallback? onEdit;
  final VoidCallback? onFollow;
  final Key? profileImageKey;

  const BookLogProfile({
    required this.profile,
    this.isMyProfile = false,
    this.isFollowing = false,
    this.onEdit,
    this.onFollow,
    this.profileImageKey,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 188,
      height: 186,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 프로필 이미지
          SizedBox(
            width: 86,
            height: 86,
            child: CircleAvatar(
              key: profileImageKey,
              backgroundColor: ColorName.g7,
              backgroundImage: profile.profileImageUrl.isNotEmpty
                  ? NetworkImage(profile.profileImageUrl)
                  : null,
              child: profile.profileImageUrl.isEmpty
                  ? const Icon(Icons.person, size: 40, color: ColorName.g5)
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          // 닉네임
          SizedBox(
            width: 188,
            height: 21,
            child: Center(
              child: Text(
                '@${profile.nickName}',
                style: AppTexts.b7.copyWith(color: ColorName.p1),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 6),
          // 통계
          SizedBox(
            width: 188,
            height: 19,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ProfileStat(label: '게시물', value: profile.diaryCount),
                StatDivider(),
                ProfileStat(label: '팔로잉', value: profile.followingCount),
                StatDivider(),
                ProfileStat(label: '팔로워', value: profile.followerCount),
              ],
            ),
          ),
          if (isMyProfile) ...[
            const SizedBox(height: 16),
            ProfileEditButton(onPressed: () {
              AnalyticsService.logEvent('click_edit_profile', parameters: {
                'screen_name': 'book_log_profile',
                'profile_id': profile.memberId
              });
              if (onEdit != null) {
                onEdit!();
              } else {
                context.push('/my-feed/profile');
              }
            }),
          ] else ...[
            const SizedBox(height: 16),
            FollowButton(
                isFollowing: isFollowing,
                onPressed: () {
                  AnalyticsService.logEvent(
                      isFollowing ? 'click_unfollow' : 'click_follow',
                      parameters: {
                        'screen_name': 'book_log_profile',
                        'profile_id': profile.memberId
                      });
                  if (onFollow != null) {
                    onFollow!();
                  }
                }),
          ],
        ],
      ),
    );
  }
}
