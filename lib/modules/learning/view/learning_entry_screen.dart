import 'package:bookstar/modules/auth/model/policy.dart';
import 'package:bookstar/modules/auth/repository/policy_repository.dart';
import 'package:bookstar/modules/auth/view_model/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/learning_access.dart';
import '../data/learning_repository.dart';
import 'learning_design.dart';

class LearningEntryScreen extends ConsumerStatefulWidget {
  const LearningEntryScreen({super.key});

  @override
  ConsumerState<LearningEntryScreen> createState() =>
      _LearningEntryScreenState();
}

class _LearningEntryScreenState extends ConsumerState<LearningEntryScreen> {
  bool _service = false;
  bool _personal = false;
  bool _saving = false;
  String? _error;

  Future<void> _save(Policy previous) async {
    if (_saving || !_service || !_personal) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(policyRepositoryProvider).updatePolicy(previous.copyWith(
          serviceUsingAgree: PolicyAgree.Y,
          personalInformationAgree: PolicyAgree.Y));
      ref.invalidate(learningPolicyProvider);
    } catch (error) {
      if (mounted) setState(() => _error = learningErrorMessage(error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: !_saving,
        child: LearningPage(
          title: '시작하기 전에',
          child: ref.watch(learningPolicyProvider).when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => SingleChildScrollView(
                    child: LearningError(
                        message: learningErrorMessage(error),
                        onRetry: () => ref.invalidate(learningPolicyProvider))),
                data: (policy) => policy == null ||
                        hasRequiredLearningPolicy(policy)
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(padding: const EdgeInsets.all(20), children: [
                        const Text('내 기록을 저장하기 위한\n이용 동의를 확인해요',
                            style: learningTitleStyle),
                        const SizedBox(height: 16),
                        const Text(
                            '필수 약관의 내용을 확인한 뒤 직접 선택해 주세요.\n마케팅 수신 동의는 추가하지 않아요.',
                            style: learningBodyStyle),
                        const SizedBox(height: 24),
                        _agreement('서비스 이용약관 (필수)', 'service', _service,
                            (value) => setState(() => _service = value)),
                        _agreement('개인정보 수집 및 이용 (필수)', 'privacy', _personal,
                            (value) => setState(() => _personal = value)),
                        if (_error != null)
                          Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Text(_error!,
                                  style: const TextStyle(
                                      color: LearningColors.amber))),
                        const SizedBox(height: 20),
                        FilledButton(
                            onPressed: !_service || !_personal || _saving
                                ? null
                                : () => _save(policy),
                            child: Text(_saving ? '저장하고 있어요' : '동의하고 계속하기')),
                        const SizedBox(height: 12),
                        TextButton(
                            onPressed: _saving
                                ? null
                                : () => ref
                                    .read(authViewModelProvider.notifier)
                                    .signOut(),
                            child: const Text('지금은 로그아웃하기')),
                      ]),
              ),
        ),
      );

  Widget _agreement(String title, String kind, bool value,
          ValueChanged<bool> onChanged) =>
      LearningCard(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Column(children: [
            CheckboxListTile(
                value: value,
                onChanged: _saving ? null : (next) => onChanged(next ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(title)),
            TextButton(
                onPressed:
                    _saving ? null : () => context.push('/policies/$kind'),
                child: Text('$title 내용 보기')),
          ]));
}
