import 'package:bookstar/modules/auth/model/policy.dart';
import 'package:bookstar/modules/auth/repository/policy_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/learning_access.dart';
import '../data/learning_repository.dart';
import 'bs_ui.dart';

const _errorRed = Color(0xFFFF6469);

class LearningNotificationSettingsScreen extends ConsumerStatefulWidget {
  const LearningNotificationSettingsScreen({super.key});

  @override
  ConsumerState<LearningNotificationSettingsScreen> createState() =>
      _LearningNotificationSettingsScreenState();
}

class _LearningNotificationSettingsScreenState
    extends ConsumerState<LearningNotificationSettingsScreen> {
  Policy? _policy;
  bool _draft = false;
  bool _loading = true;
  bool _saving = false;
  String? _error;
  int _epoch = 0;
  int? _policyAccount;

  @override
  void initState() {
    super.initState();
    ref.listenManual(learningAccountProvider, (previous, next) {
      if (previous != next) _load();
    });
    _load();
  }

  bool _isCurrent(int epoch, int? account) =>
      mounted &&
      epoch == _epoch &&
      account == ref.read(learningAccountProvider);

  Future<void> _load() async {
    final account = ref.read(learningAccountProvider);
    final epoch = ++_epoch;
    setState(() {
      _loading = true;
      _saving = false;
      _policy = null;
      _policyAccount = null;
      _draft = false;
      _error = null;
    });
    try {
      final policy =
          (await ref.read(policyRepositoryProvider).getPolicy()).data;
      if (!_isCurrent(epoch, account)) return;
      setState(() {
        _policy = policy;
        _policyAccount = account;
        _draft = policy.marketingAgree == PolicyAgree.Y;
      });
    } catch (error) {
      if (_isCurrent(epoch, account)) {
        setState(() => _error = learningErrorMessage(error));
      }
    } finally {
      if (_isCurrent(epoch, account)) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (_saving || _loading || _policy == null) return;
    final account = ref.read(learningAccountProvider);
    if (_policyAccount != account) return;
    final epoch = _epoch;
    final marketing = _draft ? PolicyAgree.Y : PolicyAgree.N;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final repository = ref.read(policyRepositoryProvider);
      // Read current required agreements; this screen changes marketing only.
      final current = (await repository.getPolicy()).data;
      if (!_isCurrent(epoch, account)) return;
      final updated = current.copyWith(marketingAgree: marketing);
      await repository.updatePolicy(updated);
      if (!_isCurrent(epoch, account)) return;
      setState(() => _policy = updated);
      ref.invalidate(learningPolicyProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('수신 동의 설정을 저장했어요.')));
    } catch (error) {
      if (_isCurrent(epoch, account)) {
        setState(() => _error =
            '${learningErrorMessage(error)}\n저장 여부를 확인하려면 다시 불러와 주세요.');
      }
    } finally {
      if (_isCurrent(epoch, account)) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final policy = _policy;
    final saved = policy?.marketingAgree == PolicyAgree.Y;
    return PopScope(
      canPop: !_saving,
      child: BsScaffold(
        title: '알림 설정',
        showBack: true,
        bottom: policy == null
            ? null
            : BsPrimaryButton(
                label: _saving ? '저장하고 있어요' : '변경 내용 저장',
                onPressed: _saving || _draft == saved ? null : _save),
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: Bs.primary))
            : policy == null
                ? Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: BsEmptyState(
                        message: _error ?? '동의 정보를 확인할 수 없어요.',
                        action:
                            BsPrimaryButton(label: '다시 불러오기', onPressed: _load),
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                    children: [
                      Text('받고 싶은 소식만\n직접 선택해요', style: Bs.title),
                      const SizedBox(height: 12),
                      Text(
                          '현재 복습 푸시 알림은 제공하지 않아요. 아래 설정은 마케팅 정보 수신 동의이며, 기기의 알림 권한과는 달라요.',
                          style: Bs.text(14, color: Bs.g3, height: 1.5)),
                      const SizedBox(height: 28),
                      Text('마케팅 정보', style: Bs.text(14, color: Bs.g3)),
                      const SizedBox(height: 6),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        activeColor: Bs.primary,
                        title: Text('마케팅 정보 수신 동의 (선택)',
                            style: Bs.text(16, color: Bs.g7)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                              '새 소식·이벤트·광고성 정보. 동의하지 않아도 퀴즈와 복습을 이용할 수 있어요.',
                              style: Bs.text(13, color: Bs.g3, height: 1.5)),
                        ),
                        value: _draft,
                        onChanged: _saving
                            ? null
                            : (value) => setState(() => _draft = value),
                      ),
                      const Divider(height: 1, thickness: 1, color: Bs.surface),
                      InkWell(
                        onTap: _saving
                            ? null
                            : () => context.push('/policies/marketing'),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 47),
                          child: Row(
                            children: [
                              Expanded(
                                  child: Text('마케팅 수신 동의 내용 보기',
                                      style: Bs.text(16, color: Bs.g7))),
                              const SizedBox(
                                width: 9.7,
                                height: 16.6,
                                child: BsIcon('ic_chevron_right',
                                    size: 16.6, color: Bs.g3),
                              ),
                              const SizedBox(width: 5.9),
                            ],
                          ),
                        ),
                      ),
                      const Divider(height: 1, thickness: 1, color: Bs.surface),
                      const SizedBox(height: 20),
                      Text('현재 저장된 설정: ${saved ? '동의' : '동의 안 함'}',
                          style: Bs.text(14, color: Bs.g3)),
                      if (_draft != saved)
                        Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text('변경한 설정은 아직 저장되지 않았어요.',
                                style: Bs.text(14,
                                    weight: FontWeight.w500,
                                    color: Bs.primary))),
                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        Text(_error!,
                            style: Bs.text(14, color: _errorRed, height: 1.5)),
                        const SizedBox(height: 8),
                        BsSecondaryButton(
                            label: '저장된 설정 다시 불러오기',
                            onPressed: _saving ? null : _load),
                      ],
                    ],
                  ),
      ),
    );
  }
}
