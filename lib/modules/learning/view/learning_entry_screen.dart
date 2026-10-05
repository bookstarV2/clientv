import 'package:bookstar/modules/auth/model/policy.dart';
import 'package:bookstar/modules/auth/repository/policy_repository.dart';
import 'package:bookstar/modules/auth/view_model/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/learning_access.dart';
import '../data/learning_repository.dart';
import 'bs_ui.dart';

/// /start – required policy consent after the first sign-in (styled like 0.1).
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
  Widget build(BuildContext context) {
    final policy = ref.watch(learningPolicyProvider);
    final ready = policy.valueOrNull != null &&
        !hasRequiredLearningPolicy(policy.valueOrNull);
    return PopScope(
      canPop: !_saving,
      child: Scaffold(
        backgroundColor: Bs.bg,
        body: SafeArea(
          child: Column(
            children: [
              const BsTopBar(title: '시작하기 전에'),
              Expanded(
                child: policy.when(
                  loading: () => const Center(
                      child: CircularProgressIndicator(color: Bs.primary)),
                  error: (error, _) => Center(
                    child: SingleChildScrollView(
                      padding: Bs.pagePadding,
                      child: BsEmptyState(
                        message: '불러오지 못했어요\n${learningErrorMessage(error)}',
                        action: BsSmallButton(
                            label: '다시 불러오기',
                            onPressed: () =>
                                ref.invalidate(learningPolicyProvider)),
                      ),
                    ),
                  ),
                  data: (_) => !ready
                      ? const Center(
                          child: CircularProgressIndicator(color: Bs.primary))
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(16, 26.5, 16, 24),
                          children: [
                            Text('내 기록을 저장하기 위한\n이용 동의를 확인해요',
                                style: Bs.text(22,
                                    weight: FontWeight.w600, letterSpacing: 0)),
                            const SizedBox(height: 8),
                            Text(
                                '필수 약관의 내용을 확인한 뒤 직접 선택해 주세요.\n마케팅 수신 동의는 추가하지 않아요.',
                                style: Bs.text(16,
                                    color: Bs.g3, letterSpacing: 0)),
                            const SizedBox(height: 32),
                            _Agreement(
                              title: '서비스 이용약관 (필수)',
                              value: _service,
                              onChanged: _saving
                                  ? null
                                  : (value) => setState(() => _service = value),
                              onView: _saving
                                  ? null
                                  : () => context.push('/policies/service'),
                            ),
                            const SizedBox(height: 12),
                            _Agreement(
                              title: '개인정보 수집 및 이용 (필수)',
                              value: _personal,
                              onChanged: _saving
                                  ? null
                                  : (value) =>
                                      setState(() => _personal = value),
                              onView: _saving
                                  ? null
                                  : () => context.push('/policies/privacy'),
                            ),
                            if (_error != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: Text(_error!,
                                    style: Bs.text(14,
                                        color: const Color(0xFFE5484D),
                                        height: 1.5)),
                              ),
                          ],
                        ),
                ),
              ),
              if (ready)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 15),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      BsPrimaryButton(
                        label: '동의하고 계속하기',
                        loading: _saving,
                        onPressed: !_service || !_personal
                            ? null
                            : () => _save(policy.requireValue!),
                      ),
                      const SizedBox(height: 4),
                      TextButton(
                        onPressed: _saving
                            ? null
                            : () => ref
                                .read(authViewModelProvider.notifier)
                                .signOut(),
                        style: TextButton.styleFrom(
                          foregroundColor: Bs.g3,
                          minimumSize: const Size(44, 44),
                          textStyle: Bs.text(14),
                        ),
                        child: const Text('지금은 로그아웃하기'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// White 56pt consent row: round check + title, with a "보기" link to the
/// full policy text.
class _Agreement extends StatelessWidget {
  const _Agreement({
    required this.title,
    required this.value,
    required this.onChanged,
    required this.onView,
  });

  final String title;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final VoidCallback? onView;

  @override
  Widget build(BuildContext context) => Material(
        color: Bs.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Bs.radius),
          side: BorderSide(
              color: value ? Bs.primary : Colors.transparent, width: 1.2),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: onChanged == null ? null : () => onChanged!(!value),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 56),
                  child: Row(
                    children: [
                      const SizedBox(width: 4),
                      Checkbox(
                        value: value,
                        onChanged: onChanged == null
                            ? null
                            : (next) => onChanged!(next ?? false),
                        shape: const CircleBorder(),
                        activeColor: Bs.primary,
                        checkColor: Bs.white,
                        side: const BorderSide(color: Bs.g2, width: 1.5),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Text(title,
                              style: Bs.text(16,
                                  weight: FontWeight.w500, height: 1.4)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Semantics(
              button: true,
              label: '$title 내용 보기',
              excludeSemantics: true,
              child: InkWell(
                onTap: onView,
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(minHeight: 56, minWidth: 64),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('보기', style: Bs.text(14, color: Bs.g3)),
                      const BsIcon('ic_chevron_right', size: 16, color: Bs.g3),
                      const SizedBox(width: 12),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}
