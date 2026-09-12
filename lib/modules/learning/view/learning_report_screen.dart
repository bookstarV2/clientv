import 'package:bookstar/infra/network/dio_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/learning_repository.dart';
import 'learning_design.dart';

class LearningReportScreen extends ConsumerStatefulWidget {
  const LearningReportScreen({super.key, required this.quizId});
  final int quizId;

  @override
  ConsumerState<LearningReportScreen> createState() =>
      _LearningReportScreenState();
}

class _LearningReportScreenState extends ConsumerState<LearningReportScreen> {
  final _content = TextEditingController();
  String? _reason;
  bool _sending = false;
  bool _sent = false;
  String? _error;
  String? _requestId;
  static const _reasons = {
    'DIFFERENT_FROM_BOOK': '책의 내용과 달라요',
    'NOT_IN_BOOK': '책에 없는 내용이에요',
    'SUBJECTIVE_CONTENT': '여러 답이 가능해 보여요',
    'OTHER': '그 밖의 문제가 있어요',
  };

  @override
  void dispose() {
    _content.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_sending || _reason == null) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      _requestId ??= LearningRepository.newRequestId();
      await ref
          .read(dioClientProvider)
          .post('/api/v3/quizzes/${widget.quizId}/error-report', data: {
        'errorType': _reason,
        'content': _content.text.trim(),
        'requestId': _requestId,
      });
      if (mounted) setState(() => _sent = true);
    } catch (error) {
      if (mounted) setState(() => _error = learningErrorMessage(error));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
      canPop: !_sending,
      child: LearningPage(
        title: '문제 오류 알려주기',
        bottom: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
          child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _sent
                    ? () =>
                        context.canPop() ? context.pop() : context.go('/quiz')
                    : _reason == null || _sending
                        ? null
                        : _send,
                child: Text(_sent
                    ? '퀴즈로 돌아가기'
                    : _sending
                        ? '보내는 중…'
                        : '의견 보내기'),
              )),
        ),
        child: _sent
            ? const SingleChildScrollView(
                child: LearningEmpty(
                title: '알려주셔서 고마워요',
                message: '보내주신 내용은 퀴즈를 검토하는 데 사용할게요.',
                icon: Icons.mark_email_read_outlined,
              ))
            : ListView(padding: const EdgeInsets.all(20), children: [
                const Text('어떤 부분을\n확인하면 좋을까요?', style: learningTitleStyle),
                const SizedBox(height: 12),
                const Text('책과 다른 내용이나 모호한 해설을 알려 주세요.\n좋은 질문을 만드는 데 도움이 돼요.',
                    style: learningBodyStyle),
                const SizedBox(height: 24),
                if (_error != null) ...[
                  Semantics(
                      liveRegion: true,
                      child: Text(_error!,
                          style: const TextStyle(
                              color: LearningColors.amber, height: 1.6))),
                  const SizedBox(height: 16),
                ],
                ..._reasons.entries.map((reason) => RadioListTile<String>(
                      value: reason.key,
                      groupValue: _reason,
                      title: Text(reason.value,
                          style: const TextStyle(fontSize: 16)),
                      contentPadding: EdgeInsets.zero,
                      onChanged: _sending
                          ? null
                          : (value) => setState(() {
                                _reason = value;
                                _requestId = null;
                              }),
                    )),
                const SizedBox(height: 18),
                TextField(
                  controller: _content,
                  onChanged: (_) => _requestId = null,
                  minLines: 4,
                  maxLines: 6,
                  maxLength: 1000,
                  enabled: !_sending,
                  decoration: const InputDecoration(
                    labelText: '자세한 내용 (선택)',
                    hintText: '해당 목차나 문장을 알려주시면 확인하기 쉬워요.',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ]),
      ));
}
