import 'package:bookstar/common/components/button/cta_button_l1.dart';
import 'package:bookstar/common/components/text_field/input_1.dart';
import 'package:bookstar/common/theme/app_style.dart';
import 'package:bookstar/modules/book_pick/model/search_book_response.dart';
import 'package:bookstar/modules/reading_challenge/view/widgets/challenge_book_info_widget.dart';
import 'package:bookstar/modules/reading_challenge/view/widgets/step_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ReadingChallengeTotalPageScreen extends ConsumerStatefulWidget {
  const ReadingChallengeTotalPageScreen({
    super.key,
    required this.book,
  });

  final SearchBookResponse book;

  @override
  ConsumerState<ReadingChallengeTotalPageScreen> createState() =>
      _ReadingChallengeTotalPageScreenState();
}

class _ReadingChallengeTotalPageScreenState
    extends ConsumerState<ReadingChallengeTotalPageScreen>
    with WidgetsBindingObserver {
  final _textController = TextEditingController();
  bool _isButtonEnabled = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _textController.addListener(() {
      setState(() {
        _isButtonEnabled = _textController.text.isNotEmpty;
      });
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
    _textController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text("리딩 챌린지"),
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                context.go('/reading-challenge');
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
                    minHeight: constraints.maxHeight + MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ChallengeBookInfoWidget(book: book),
                            const SizedBox(height: 25),
                            const StepProgressIndicator(
                              totalSteps: 3,
                              currentStep: 1,
                            ),
                            const SizedBox(height: 40),
                            _buildPageInputSection(),
                          ],
                        ),
                        SizedBox(height: 16,),
                        _buildSubmitButtonSection(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPageInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Input1(
          controller: _textController,
          label: '선택하신 책의 전체 페이지 수를 알려주세요',
          hintText: '페이지',
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildSubmitButtonSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 54),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CtaButtonL1(
            text: '다음으로',
            enabled: _isButtonEnabled,
            analyticsEventName: 'click_next_from_total_page',
            analyticsEventParams: {
              'screen_name': 'reading_challenge_total_page',
              'bookId': widget.book.bookId,
            },
            onPressed: () {
              final totalPages = int.tryParse(_textController.text);
              if (totalPages != null && mounted) {
                context.push(
                  '/reading-challenge/start-and-end',
                  extra: {
                    'book': widget.book,
                    'totalPages': totalPages,
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
