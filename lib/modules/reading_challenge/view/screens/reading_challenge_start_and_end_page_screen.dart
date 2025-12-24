import 'package:bookstar/common/components/button/cta_button_l1.dart';
import 'package:bookstar/common/components/dialog/custom_dialog.dart';
import 'package:bookstar/common/components/text_field/input_1.dart';
import 'package:bookstar/common/theme/app_style.dart';
import 'package:bookstar/gen/colors.gen.dart';
import 'package:bookstar/modules/book_pick/model/search_book_response.dart';
import 'package:bookstar/modules/reading_challenge/view/widgets/challenge_book_info_widget.dart';
import 'package:bookstar/modules/reading_challenge/view/widgets/step_progress_indicator.dart';
import 'package:bookstar/modules/reading_challenge/view_model/current_challenge_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ReadingChallengeStartAndEndPageScreen extends ConsumerStatefulWidget {
  const ReadingChallengeStartAndEndPageScreen({
    super.key,
    required this.book,
    required this.totalPages,
    this.challengeId,
  });

  final SearchBookResponse book;
  final int totalPages;
  final int? challengeId;

  @override
  ConsumerState<ReadingChallengeStartAndEndPageScreen> createState() =>
      _ReadingChallengeStartAndEndPageScreenState();
}

class _ReadingChallengeStartAndEndPageScreenState
    extends ConsumerState<ReadingChallengeStartAndEndPageScreen>
    with WidgetsBindingObserver {
  final FocusNode startFocusNode = FocusNode();
  final FocusNode endFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref
            .read(currentChallengeViewModelProvider.notifier)
            .initializeChallenge(
              book: widget.book,
              totalPages: widget.totalPages,
              challengeId: widget.challengeId,
            );
      }
    });
  }

  // 이 메서드는 키보드, 시스템 UI 등 화면 metric이 바뀔 때 호출됨
  @override
  void didChangeMetrics() {
    super.didChangeMetrics();

    final bottomInset = WidgetsBinding
        .instance.platformDispatcher.views.first.viewInsets.bottom;
    if (bottomInset > 0.0) {
      // 키보드가 올라온 직후 frame build 후 스크롤
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    startFocusNode.dispose();
    endFocusNode.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _showSkipDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return CustomDialog(
          title: '알림',
          content: '챌린지 생성이 안됩니다. 괜찮으신가요?',
          confirmButtonText: '확인',
          cancelButtonText: '취소',
          confirmAnalyticsEventName: 'click_skip_challenge_creation_confirm',
          confirmAnalyticsEventParams: {
            'screen_name': 'reading_challenge_start_and_end_page',
            'bookId': widget.book.bookId,
          },
          cancelAnalyticsEventName: 'click_skip_challenge_creation_cancel',
          cancelAnalyticsEventParams: {
            'screen_name': 'reading_challenge_start_and_end_page',
            'bookId': widget.book.bookId,
          },
          onConfirm: () {
            Navigator.of(context).pop();
            context.go('/reading-challenge');
          },
          onCancel: () => Navigator.of(context).pop(), analyticsEventParams: {},
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.read(currentChallengeViewModelProvider.notifier);
    final book = widget.book;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          appBar: AppBar(
            title: const Text("리딩 챌린지"),
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  if (widget.challengeId != null) {
                    // 진행 중인 챌린지에서 왔다면 바로 이전 화면으로
                    context.pop();
                  } else {
                    // 신규 챌린지라면 확인 다이얼로그 표시
                    _showSkipDialog();
                  }
                },
              ),
            ],
          ),
          body: Padding(
            padding: AppPaddings.SCREEN_BODY_PADDING,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                    controller: _scrollController,
                    child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight +
                              MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: IntrinsicHeight(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              // controller: _scrollController,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                ChallengeBookInfoWidget(book: book),
                                const SizedBox(height: 16),
                                const StepProgressIndicator(
                                  totalSteps: 3,
                                  currentStep: 2,
                                ),
                                const SizedBox(height: 40),
                                _buildPageInputSection(context, viewModel,
                                    startFocusNode, endFocusNode),
                              ],
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            _buildSubmitButtonSection(
                                context, book, widget.totalPages)
                          ],
                        ))));
              },
            ),
          )),
    );
  }

  Widget _buildPageInputSection(
      BuildContext ctx,
      CurrentChallengeViewModel viewModel,
      FocusNode startFocusNode,
      FocusNode endFocusNode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '오늘 읽은 페이지 수를 알려주세요',
          style: AppTexts.b10.copyWith(color: ColorName.p1),
          textAlign: TextAlign.left,
        ),
        const SizedBox(height: 20),
        _buildPageInputField(
          label: '에서',
          focusNode: startFocusNode,
          textInputAction: TextInputAction.next,
          onChanged: (value) => viewModel.setStartPage(value),
          onSubmitted: () {
            FocusScope.of(ctx).requestFocus(endFocusNode);
          },
        ),
        const SizedBox(height: 16),
        _buildPageInputField(
          label: '까지 읽었어요',
          focusNode: endFocusNode,
          textInputAction: TextInputAction.done,
          onChanged: (value) => viewModel.setEndPage(value),
          onSubmitted: () {
            FocusScope.of(context).unfocus();
          },
        ),
      ],
    );
  }

  Widget _buildPageInputField({
    required String label,
    required ValueChanged<String> onChanged,
    FocusNode? focusNode,
    TextInputAction? textInputAction,
    Function()? onSubmitted,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Input1(
            hintText: '페이지',
            focusNode: focusNode,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: onChanged,
            onTap: () {
              if (onSubmitted != null) {
                onSubmitted();
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTexts.b4.copyWith(color: ColorName.g3),
        ),
      ],
    );
  }

  Widget _buildSubmitButtonSection(
    BuildContext context,
    SearchBookResponse book,
    int totalPages,
  ) {
    final state = ref.watch(currentChallengeViewModelProvider);
    final viewModel = ref.read(currentChallengeViewModelProvider.notifier);
    final bookId = state.book?.bookId;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 54),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CtaButtonL1(
            text: '다음으로',
            enabled: viewModel.isButtonEnabled,
            analyticsEventName: 'click_next_from_start_end_page',
            analyticsEventParams: {
              'screen_name': 'reading_challenge_start_and_end_page',
              'bookId': book.bookId,
              'totalPages': totalPages,
            },
            onPressed: () async {
              try {
                if (!context.mounted) return;
                final isChallengeCompleted = state.endPage != null &&
                    int.tryParse(state.endPage!) != null &&
                    int.parse(state.endPage!) >= totalPages;

                if (isChallengeCompleted) {
                  context.push(
                    '/reading-challenge/rating',
                    extra: book,
                  );
                } else {
                                    if (!context.mounted) return;
                  context.push(
                    '/reading-challenge/diary-encourage',
                    extra: {
                      'isChallengeCompleted': isChallengeCompleted,
                      'bookId': bookId,
                    },
                  );
                }
              } catch (e) {
                debugPrint('Failed to process reading record: $e');
              }
            },
          ),
        ],
      ),
    );
  }
}
