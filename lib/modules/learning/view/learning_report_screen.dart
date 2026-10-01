import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/learning_repository.dart';
import 'bs_ui.dart';

/// 2.3.1 오류 신고: bottom sheet opened from the quiz top bar report icon.
Future<void> showQuizReportSheet(BuildContext context, int quizId) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Bs.white,
      barrierColor: Bs.dim,
      showDragHandle: false,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => QuizReportPanel(quizId: quizId),
    );

/// `/quiz/:quizId/report`: the same report flow as a full page.
class LearningReportScreen extends StatelessWidget {
  const LearningReportScreen({super.key, required this.quizId});
  final int quizId;

  @override
  Widget build(BuildContext context) =>
      QuizReportPanel(quizId: quizId, fullScreen: true);
}

/// Report content shared by the sheet and the page: Default → Completed.
class QuizReportPanel extends ConsumerStatefulWidget {
  const QuizReportPanel(
      {super.key, required this.quizId, this.fullScreen = false});
  final int quizId;
  final bool fullScreen;

  @override
  ConsumerState<QuizReportPanel> createState() => _QuizReportPanelState();
}

class _QuizReportPanelState extends ConsumerState<QuizReportPanel> {
  bool _sending = false;
  bool _sent = false;
  String? _error;
  String? _requestId;

  Future<void> _send() async {
    if (_sending || _sent) return;
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      _requestId ??= LearningRepository.newRequestId();
      await ref.read(learningRepositoryProvider).reportQuiz(widget.quizId,
          errorType: 'OTHER', requestId: _requestId!);
      if (mounted) setState(() => _sent = true);
    } catch (error) {
      if (mounted) setState(() => _error = learningErrorMessage(error));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _close() {
    if (!widget.fullScreen) {
      Navigator.of(context).pop();
    } else if (context.canPop()) {
      context.pop();
    } else {
      context.go('/quiz');
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          liveRegion: _sent,
          child:
              Text(_sent ? '신고가 접수되었어요.' : '퀴즈 내용에 오류가 있나요?', style: Bs.title),
        ),
        const SizedBox(height: 12),
        Text(
            _sent
                ? '보내주신 의견은 더 나은 북스타 경험을 만드는 데\n도움이 돼요.'
                : '책의 내용과 다르거나 정답에 오류가 있다면 알려주세요.\n확인 후 신속히 수정할게요.',
            // Figma fits line 1 within 3px; the default tracking keeps two lines.
            style: Bs.text(16,
                weight: FontWeight.w500, color: Bs.g7, height: 1.5)),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Semantics(
            liveRegion: true,
            child: Text(_error!,
                style: Bs.text(14, color: quizErrorTextColor, height: 1.5)),
          ),
        ],
      ],
    );
    final button = BsPrimaryButton(
      label: _sent ? '확인' : '퀴즈 신고하기',
      loading: _sending,
      onPressed: _sent ? _close : _send,
    );
    if (widget.fullScreen) {
      return PopScope(
        canPop: !_sending,
        child: Scaffold(
          backgroundColor: Bs.white,
          body: SafeArea(
            child: Column(
              children: [
                const BsTopBar(showBack: true),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const BsCharacterImage(BsCharacter.cloud, width: 82),
                        const SizedBox(height: 20),
                        content,
                      ],
                    ),
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 15),
                    child: button),
              ],
            ),
          ),
        ),
      );
    }
    return PopScope(
      canPop: !_sending,
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 100,
                child: Stack(
                  children: [
                    const Positioned(
                      left: 15,
                      top: 30,
                      child: BsCharacterImage(BsCharacter.cloud, width: 82),
                    ),
                    Positioned(
                      right: 4,
                      top: 12,
                      child: IconButton(
                        tooltip: '닫기',
                        onPressed: _sending ? null : _close,
                        icon: const BsIcon('ic_close', size: 16, color: Bs.g3),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: content,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 28, 16, 15),
                child: button,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Inline error text on report and quiz submissions.
const quizErrorTextColor = Color(0xFFE5484D);
