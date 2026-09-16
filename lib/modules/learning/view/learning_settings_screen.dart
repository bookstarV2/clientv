import 'package:bookstar/modules/auth/view_model/auth_state.dart';
import 'package:bookstar/modules/auth/view_model/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'learning_design.dart';

class LearningSettingsScreen extends ConsumerWidget {
  const LearningSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authViewModelProvider).valueOrNull;
    return LearningPage(
      title: '설정',
      actions: [
        IconButton(
            tooltip: '오늘 퀴즈로',
            onPressed: () => context.go('/quiz'),
            icon: const Icon(Icons.home_outlined))
      ],
      child: ListView(padding: const EdgeInsets.all(20), children: [
        const LearningLabel('나를 위한 독서'),
        const SizedBox(height: 12),
        const Text('읽은 책이\n내 지식이 되는 곳', style: learningTitleStyle),
        const SizedBox(height: 12),
        const Text('한 문제로 되짚고, 다시 꺼내 보며\n내 속도로 오래 기억하는 독서를 해요.',
            style: learningBodyStyle),
        const SizedBox(height: 28),
        LearningCard(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const LearningLabel('로그인 정보'),
          const SizedBox(height: 12),
          Text(
              user is AuthSuccess
                  ? '${user.providerType} 계정'
                  : '계정 정보를 확인하고 있어요',
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          if (user is AuthSuccess && user.email.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(user.email, style: learningBodyStyle),
          ],
        ])),
        const SizedBox(height: 20),
        _row(Icons.inventory_2_outlined, '나의 지난 독서 기록',
            () => context.push('/settings/archive')),
        _row(Icons.help_outline_rounded, 'AI 퀴즈 이용 안내',
            () => _showGuide(context)),
        _row(Icons.mail_outline_rounded, '문의하기', () async {
          await Clipboard.setData(
              const ClipboardData(text: 'bookstar816@gmail.com'));
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('문의 이메일을 복사했어요: bookstar816@gmail.com')),
            );
          }
        }),
        _row(Icons.play_circle_outline_rounded, '퀴즈 체험 다시 보기',
            () => context.push('/preview')),
        _row(Icons.description_outlined, '서비스 이용약관',
            () => context.push('/policies/service')),
        _row(Icons.privacy_tip_outlined, '개인정보 수집 및 이용',
            () => context.push('/policies/privacy')),
        _row(Icons.notifications_none_rounded, '알림 설정',
            () => context.push('/settings/notifications')),
        const SizedBox(height: 18),
        const Divider(),
        _row(Icons.logout_rounded, '로그아웃', () => _signOut(context, ref)),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: LearningColors.muted),
          onPressed: () => context.push('/settings/delete-account'),
          child: const Text('회원 탈퇴'),
        ),
        const SizedBox(height: 28),
        const Center(
            child: Text('BookStar · 읽고, 떠올리고, 기억하다',
                style: TextStyle(fontSize: 12, color: LearningColors.muted))),
      ]),
    );
  }

  Widget _row(IconData icon, String title, VoidCallback onTap) => ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        leading: Icon(icon, color: LearningColors.muted),
        title: Text(title, style: const TextStyle(fontSize: 15)),
        trailing: const Icon(Icons.chevron_right_rounded,
            color: LearningColors.muted),
        onTap: onTap,
      );

  void _showGuide(BuildContext context) => showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('AI 퀴즈 이용 안내'),
          content: const SingleChildScrollView(
              child: Text(
            '퀴즈는 책 정보와 목차를 참고해 AI가 만들어요. 책 원문 전체를 검증한 문제는 아니며, 오류나 다른 해석이 있을 수 있어요.\n\n'
            '처음 푼 문제는 복습에 저장돼요. 복습에서 정답을 연속으로 맞히면 1일, 3일, 7일, 14일 간격으로 다음 일정을 잡아요. 틀리면 다음날 다시 보게 돼요.\n\n'
            '복습 일정은 초기 운영 규칙이며, 개인의 기억력을 측정한 결과는 아니에요. 예정일 전에도 다시 풀 수 있어요. 푸시 알림은 제공하지 않으니 복습 탭에서 일정을 확인해 주세요.',
            style: TextStyle(height: 1.6),
          )),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('확인했어요'))
          ],
        ),
      );

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('로그아웃할까요?'),
              content: const Text('독서와 복습 기록은 계정에 남아 있어요.'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('취소')),
                TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('로그아웃')),
              ],
            ));
    if (confirmed == true) {
      await ref.read(authViewModelProvider.notifier).signOut();
    }
  }
}
