import 'package:bookstar/common/theme/style/app_paddings.dart';
import 'package:bookstar/common/theme/style/app_texts.dart';
import 'package:bookstar/gen/colors.gen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../common/components/button/text_button.dart';

class MyPageScreen extends ConsumerStatefulWidget {
  const MyPageScreen({super.key});

  @override
  ConsumerState<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends ConsumerState<MyPageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('마이페이지'),
        leading: IconButton(
          icon: const BackButton(),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: AppPaddings.SCREEN_BODY_PADDING,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('회원 정보', style: AppTexts.b5.copyWith(color: ColorName.w1)),
              const SizedBox(height: 8),
              CustomTextButton(
                label: '로그인 정보',
                analyticsEventName: 'click_login_info',
                analyticsEventParams: const {
                  'screen_name': 'my_page',
                },
                onTap: () {
                  context.go('/my-feed/my-page/login-info');
                },
              ),
              CustomTextButton(
                label: '회원 탈퇴',
                analyticsEventName: 'click_withdraw_membership',
                analyticsEventParams: const {
                  'screen_name': 'my_page',
                },
                onTap: () {
                  context.go('/my-feed/my-page/delete-account');
                },
              ),
              const SizedBox(height: 35),
              Text('활동 정보', style: AppTexts.b5.copyWith(color: ColorName.w1)),
              const SizedBox(height: 8),
              CustomTextButton(
                label: '고객 센터',
                analyticsEventName: 'click_customer_support',
                analyticsEventParams: const {
                  'screen_name': 'my_page',
                },
                onTap: () {
                  context.go('/my-feed/my-page/customer-support');
                },
              ),
              const SizedBox(height: 35),
              Text('활동 내역', style: AppTexts.b5.copyWith(color: ColorName.w1)),
              const SizedBox(height: 8),
              CustomTextButton(
                label: '좋아요 누른 책로그',
                analyticsEventName: 'click_liked_diaries',
                analyticsEventParams: const {
                  'screen_name': 'my_page',
                },
                onTap: () {
                  context.go('/my-feed/my-page/liked-diaries');
                },
              ),
              CustomTextButton(
                label: '스크랩한 책로그',
                analyticsEventName: 'click_scrapped_diaries',
                analyticsEventParams: const {
                  'screen_name': 'my_page',
                },
                onTap: () {
                  context.go('/my-feed/my-page/scrapped-diaries');
                },
              ),
              CustomTextButton(
                label: '팔로워 관리',
                analyticsEventName: 'click_follower_management',
                analyticsEventParams: const {
                  'screen_name': 'my_page',
                },
                onTap: () {
                  context.go('/my-feed/my-page/follower-management');
                },
              ),
              CustomTextButton(
                label: '챌린지 중단 도서',
                analyticsEventName: 'click_challenge_quit_books',
                analyticsEventParams: const {
                  'screen_name': 'my_page',
                },
                onTap: () {
                  context.go('/my-feed/my-page/challenge-quit-books');
                },
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}