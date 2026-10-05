import 'package:bookstar/modules/auth/view_model/auth_view_model.dart';
import 'package:bookstar/modules/learning/data/learning_repository.dart';
import 'package:bookstar/modules/learning/view/learning_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() =>
      _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  bool _checked = false;
  bool _withdrawing = false;
  bool _confirming = false;
  String? _error;

  Future<void> _confirmWithdrawal() async {
    if (!_checked || _withdrawing || _confirming) return;
    setState(() => _confirming = true);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('정말 탈퇴할까요?'),
        content: const SingleChildScrollView(
          child: Text('계정과 독서·퀴즈·복습 기록을 삭제해요. 탈퇴 후 다시 로그인해도 이전 기록을 복구할 수 없어요.'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('계속 이용하기')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('계정 삭제')),
        ],
      ),
    );
    if (!mounted) return;
    setState(() => _confirming = false);
    if (confirmed != true) return;
    setState(() {
      _withdrawing = true;
      _error = null;
    });
    try {
      await ref.read(authViewModelProvider.notifier).withdraw();
      // Authentication normally redirects first; never update a disposed page.
      if (mounted) context.go('/login');
    } catch (error) {
      if (mounted) {
        setState(
            () => _error = '탈퇴를 완료하지 못했어요.\n${learningErrorMessage(error)}\n'
                '네트워크 오류라면 처리 결과가 아직 확인되지 않았을 수 있어요. 다시 시도하거나 문의해 주세요.');
      }
    } finally {
      if (mounted) setState(() => _withdrawing = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: !_withdrawing,
        child: LearningPage(
          title: '회원 탈퇴',
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const LearningLabel('계정 관리'),
              const SizedBox(height: 16),
              const Text('탈퇴하면\n기록을 복구할 수 없어요', style: learningTitleStyle),
              const SizedBox(height: 16),
              const Text(
                  '계정과 함께 내 서재, 퀴즈 풀이, 복습 기록, 이전 독서 기록을 삭제해요. 필요한 내용은 탈퇴 전에 따로 보관해 주세요.',
                  style: learningBodyStyle),
              const SizedBox(height: 24),
              const LearningCard(
                color: LearningColors.amberSoft,
                child: Text('탈퇴를 취소하는 유예 기간은 없어요.\n다시 가입하더라도 이전 기록이 돌아오지 않아요.',
                    style: learningBodyStyle),
              ),
              const SizedBox(height: 24),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text('기록을 복구할 수 없음을 확인했고 탈퇴에 동의해요.'),
                value: _checked,
                onChanged: _withdrawing || _confirming
                    ? null
                    : (value) => setState(() => _checked = value ?? false),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(_error!,
                    style: const TextStyle(
                        color: LearningColors.amber, height: 1.6)),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: !_checked || _withdrawing || _confirming
                    ? null
                    : _confirmWithdrawal,
                child: Text(_withdrawing ? '탈퇴 처리 중이에요' : '탈퇴하기'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _withdrawing || _confirming
                    ? null
                    : () => context.canPop()
                        ? context.pop()
                        : context.go('/settings'),
                child: const Text('계속 이용하기'),
              ),
            ],
          ),
        ),
      );
}
