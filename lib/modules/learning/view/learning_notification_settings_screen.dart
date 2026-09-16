import 'package:bookstar/modules/auth/model/policy.dart';
import 'package:bookstar/modules/auth/repository/policy_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/learning_access.dart';
import '../data/learning_repository.dart';
import 'learning_design.dart';

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
  Widget build(BuildContext context) => PopScope(
        canPop: !_saving,
        child: LearningPage(
          title: '알림 설정',
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _policy == null
                  ? SingleChildScrollView(
                      child: LearningError(
                          message: _error ?? '동의 정보를 확인할 수 없어요.',
                          onRetry: _load))
                  : ListView(padding: const EdgeInsets.all(20), children: [
                      const Text('받고 싶은 소식만\n직접 선택해요',
                          style: learningTitleStyle),
                      const SizedBox(height: 16),
                      const Text(
                          '현재 복습 푸시 알림은 제공하지 않아요. 아래 설정은 마케팅 정보 수신 동의이며, 기기의 알림 권한과는 달라요.',
                          style: learningBodyStyle),
                      const SizedBox(height: 24),
                      LearningCard(
                          padding: const EdgeInsets.all(8),
                          child: Column(children: [
                            SwitchListTile.adaptive(
                              title: const Text('마케팅 정보 수신 동의 (선택)'),
                              subtitle: const Text(
                                  '새 소식·이벤트·광고성 정보. 동의하지 않아도 퀴즈와 복습을 이용할 수 있어요.'),
                              value: _draft,
                              onChanged: _saving
                                  ? null
                                  : (value) => setState(() => _draft = value),
                            ),
                            TextButton(
                                onPressed: _saving
                                    ? null
                                    : () => context.push('/policies/marketing'),
                                child: const Text('마케팅 수신 동의 내용 보기')),
                          ])),
                      const SizedBox(height: 16),
                      Text(
                          '현재 저장된 설정: ${_policy!.marketingAgree == PolicyAgree.Y ? '동의' : '동의 안 함'}',
                          style: learningBodyStyle),
                      if (_draft != (_policy!.marketingAgree == PolicyAgree.Y))
                        const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text('변경한 설정은 아직 저장되지 않았어요.',
                                style: TextStyle(color: LearningColors.amber))),
                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        Text(_error!,
                            style:
                                const TextStyle(color: LearningColors.amber)),
                        TextButton(
                            onPressed: _saving ? null : _load,
                            child: const Text('저장된 설정 다시 불러오기')),
                      ],
                      const SizedBox(height: 24),
                      FilledButton(
                          onPressed: _saving ||
                                  _draft ==
                                      (_policy!.marketingAgree == PolicyAgree.Y)
                              ? null
                              : _save,
                          child: Text(_saving ? '저장하고 있어요' : '변경 내용 저장')),
                    ]),
        ),
      );
}
