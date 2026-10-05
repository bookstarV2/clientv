import 'package:bookstar/modules/auth/view_model/auth_state.dart';
import 'package:bookstar/modules/auth/view_model/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'bs_ui.dart';
import 'learning_guide_sheet.dart';

const _contactEmail = 'bookstar816@gmail.com';
const _logoutRed = Color(0xFFFF6469);

/// 1.2 / 1.3 설정. iOS follows 1.2 (disclosure chevrons, separators only
/// between the rows of a group); other platforms follow 1.3 (no chevrons and
/// a divider under every row).
class LearningSettingsScreen extends ConsumerWidget {
  const LearningSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authViewModelProvider).valueOrNull;
    final ios = switch (Theme.of(context).platform) {
      TargetPlatform.iOS || TargetPlatform.macOS => true,
      _ => false,
    };
    return BsScaffold(
      title: '설정',
      showBack: true,
      onBack: () => context.canPop() ? context.pop() : context.go('/quiz'),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
            16, 26.5, 16, 24 + MediaQuery.paddingOf(context).bottom),
        children: [
          _LoginCard(account: user is AuthSuccess ? user : null),
          _Section(title: '서비스', ios: ios, gap: 24.9, rows: [
            ('나의 지난 독서 기록', () => context.push('/settings/archive')),
            (
              'AI 퀴즈 이용 안내',
              () => showQuizGuideSheet(context, primaryLabel: '확인')
            ),
            ('퀴즈 체험 다시 보기', () => context.push('/preview')),
            ('문의하기', () => _contact(context)),
          ]),
          _Section(title: '알림', ios: ios, gap: ios ? 13.4 : 24.4, rows: [
            ('알림 설정', () => context.push('/settings/notifications')),
          ]),
          _Section(title: '약관 및 개인정보', ios: ios, gap: ios ? 13.4 : 24.4, rows: [
            ('서비스 이용 약관', () => context.push('/policies/service')),
            ('개인정보 수집 및 이용', () => context.push('/policies/privacy')),
          ]),
          SizedBox(height: ios ? 4.2 : 15.2),
          _TextAction('로그아웃',
              color: _logoutRed,
              top: 17.8,
              onTap: () => _signOut(context, ref)),
          _TextAction('회원탈퇴',
              color: Bs.g3,
              top: 7.8,
              onTap: () => context.push('/settings/delete-account')),
        ],
      ),
    );
  }

  Future<void> _contact(BuildContext context) async {
    await Clipboard.setData(const ClipboardData(text: _contactEmail));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('문의 이메일을 복사했어요: $_contactEmail')),
      );
    }
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showBsConfirmDialog(
      context,
      title: '로그아웃할까요?',
      message: '독서와 복습 기록은 계정에 남아 있어요.',
      confirmLabel: '로그아웃',
    );
    if (confirmed == true) {
      await ref.read(authViewModelProvider.notifier).signOut();
    }
  }
}

String _accountLabel(String provider) => switch (provider.toUpperCase()) {
      'KAKAO' => '카카오 계정',
      'APPLE' => 'Apple 계정',
      'GOOGLE' => 'Google 계정',
      _ => '소셜 로그인 계정',
    };

class _LoginCard extends StatelessWidget {
  const _LoginCard({required this.account});

  final AuthSuccess? account;

  @override
  Widget build(BuildContext context) {
    final email = account?.email ?? '';
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 19.9, 24.5, 20),
      decoration: BoxDecoration(
          color: Bs.surface, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('로그인 정보', style: Bs.text(14, color: Bs.g3)),
          const SizedBox(height: 4.7),
          Text(
              account == null
                  ? '계정 정보를 확인하고 있어요'
                  : _accountLabel(account!.providerType),
              style: Bs.text(18, weight: FontWeight.w700, color: Bs.g7)),
          if (email.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 49.5),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                  color: Bs.white, borderRadius: BorderRadius.circular(12)),
              child: Text(email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Bs.text(16, color: Bs.g6, letterSpacing: 0)),
            ),
          ],
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(
      {required this.title,
      required this.rows,
      required this.ios,
      required this.gap});

  final String title;
  final List<(String, VoidCallback)> rows;
  final bool ios;

  /// Space above the section title.
  final double gap;

  static const _divider = Divider(height: 1, thickness: 1, color: Bs.surface);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: gap),
            Semantics(
                header: true,
                child: Text(title, style: Bs.text(14, color: Bs.g3))),
            const SizedBox(height: 4.8),
            for (final (index, (label, onTap)) in rows.indexed) ...[
              if (ios && index > 0) _divider,
              Semantics(
                button: true,
                child: InkWell(
                  onTap: onTap,
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 47),
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(
                      children: [
                        Expanded(
                            child:
                                Text(label, style: Bs.text(16, color: Bs.g7))),
                        if (ios) ...[
                          const SizedBox(
                            width: 9.7,
                            height: 16.6,
                            child: BsIcon('ic_chevron_right',
                                size: 16.6, color: Bs.g3),
                          ),
                          const SizedBox(width: 5.9),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              if (!ios) _divider,
            ],
          ],
        ),
      );
}

/// 로그아웃 / 회원탈퇴 text rows: 36pt apart in the design, each with a 46pt
/// tap area ([top] places the text inside it).
class _TextAction extends StatelessWidget {
  const _TextAction(this.label,
      {required this.color, required this.top, required this.onTap});

  final String label;
  final Color color;
  final double top;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.fromLTRB(1, top, 1, 22.8 - top),
            child: SizedBox(
              width: double.infinity,
              child: Text(label, style: Bs.text(16, color: color)),
            ),
          ),
        ),
      );
}
