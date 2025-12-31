import 'package:bookstar/common/components/form/user_with_checkbox.dart';
import 'package:bookstar/common/components/button/cta_button_l1.dart';
import 'package:bookstar/common/service/analytics_service.dart';
import 'package:bookstar/common/theme/style/app_paddings.dart';
import 'package:bookstar/common/theme/style/app_texts.dart';
import 'package:bookstar/gen/assets.gen.dart';
import 'package:bookstar/gen/colors.gen.dart';
import 'package:bookstar/modules/book_log/view/screens/book_log_thumbnail_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bookstar/modules/follow/model/dummy_follower.dart';

class FollowerManagementScreen extends StatefulWidget {
  const FollowerManagementScreen({super.key});

  @override
  State<FollowerManagementScreen> createState() =>
      _FollowerManagementScreenState();
}

class _FollowerManagementScreenState extends State<FollowerManagementScreen> {
  List<bool> checkedList = [];

  @override
  void initState() {
    super.initState();
    checkedList = List.generate(dummyFollowers.length, (_) => false);
  }

  // 더미 데이터 삭제 필요
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('팔로워 관리'),
        leading: IconButton(
          icon: const BackButton(),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              GoRouter.of(context).go('/my-feed');
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: AppPaddings.SCREEN_BODY_PADDING,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text('차단한 유저', style: AppTexts.h4),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Assets.icons.icUser.svg(width: 15, height: 16),
                        const SizedBox(width: 2.73),
                        Text('${dummyFollowers.length}',
                            style: AppTexts.b8.copyWith(color: ColorName.g3)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: dummyFollowers.length,
                  itemBuilder: (context, index) {
                    final follower = dummyFollowers[index];
                    return UserWithCheckbox(
                      id: follower.id,
                      nickname: follower.nickname,
                      profileImageUrl: follower.profileImageUrl,
                      checked: checkedList[index],
                      onChanged: (value) {
                        setState(() {
                          checkedList[index] = value;
                        });
                      },
                      onViewProfile: () {
                        AnalyticsService.logEvent(
                            'click_view_profile_from_follower_management',
                            parameters: {
                              'screen_name': 'follower_management',
                              'tapped_member_id': follower.id
                            });
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => BookLogThumbnailScreen(
                              memberId: follower.id,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 54),
              child: CtaButtonL1(
                text: '차단 해제하기',
                enabled: checkedList.contains(true),
                analyticsEventName: 'click_unblock_user',
                analyticsEventParams: {
                  'screen_name': 'follower_management',
                  'unblocked_user_count':
                      checkedList.where((e) => e).length,
                },
                onPressed: checkedList.contains(true)
                    ? () {
                        // TODO: 차단 해제 처리 로직 추가
                        print('차단 해제하기 버튼 클릭됨');
                      }
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
