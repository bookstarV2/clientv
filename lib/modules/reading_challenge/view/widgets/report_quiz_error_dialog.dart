import 'package:bookstar/common/components/button/cta_button_l1.dart';
import 'package:bookstar/common/service/analytics_service.dart';
import 'package:bookstar/common/theme/style/app_texts.dart';
import 'package:bookstar/gen/colors.gen.dart';
import 'package:bookstar/modules/book_log/view/widgets/report_text_field.dart';
import 'package:bookstar/modules/reading_challenge/model/report_quiz_error_request.dart';
import 'package:bookstar/modules/reading_challenge/repository/reading_challenge_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum ReportQuizErrorType {
  DIFFERENT_FROM_BOOK("책의 내용과 달라요"),
  NOT_IN_BOOK("책에 존재하지 않는 내용이에요"),
  SUBJECTIVE_CONTENT("주관적인 내용이에요"),
  OTHER("기타");

  const ReportQuizErrorType(this.text);
  final String text;
}

List<ReportQuizErrorType> reportQuizErrorTypes = [
  ReportQuizErrorType.DIFFERENT_FROM_BOOK,
  ReportQuizErrorType.NOT_IN_BOOK,
  ReportQuizErrorType.SUBJECTIVE_CONTENT,
  ReportQuizErrorType.OTHER,
];

class ReportQuizErrorDialog extends ConsumerStatefulWidget {
  const ReportQuizErrorDialog({
    super.key,
    required this.quizId,
  });

  final int quizId;

  @override
  ConsumerState<ReportQuizErrorDialog> createState() =>
      _ReportQuizErrorDialogState();
}

class _ReportQuizErrorDialogState extends ConsumerState<ReportQuizErrorDialog>
    with WidgetsBindingObserver {
  ReportQuizErrorType? _selectedValue;
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _textController.addListener(() {
      setState(() {});
    });
  }

  _hideKeyboard() {
    _focusNode.unfocus();
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

  void _onSubmit() async {
    AnalyticsService.logEvent('click_report_quiz_error', parameters: {
      'screen_name': "report_quiz_error",
      "quiz_id": widget.quizId,
      "error_type": _selectedValue!.toString(),
    });

    await ref.read(readingChallengeRepositoryProvider).reportQuizError(
          widget.quizId,
          ReportQuizErrorRequest(
            errorType: _selectedValue!,
            content: _textController.text,
          ),
        );
    if (!mounted) return;
    context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _hideKeyboard,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("퀴즈에 어떤 오류가 있었나요?"),
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close))
                ],
              ),
              ...reportQuizErrorTypes.map((reportQuizErrorType) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    radioTheme: RadioThemeData(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      fillColor:
                          WidgetStateProperty.resolveWith<Color>((states) {
                        if (states.contains(WidgetState.selected)) {
                          return ColorName.p1; // 선택된 상태의 색상
                        }
                        return ColorName.g7; // 선택되지 않은 상태의 색상
                      }),
                    ),
                  ),
                  child: RadioListTile<ReportQuizErrorType>(
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                    dense: true,
                    visualDensity: const VisualDensity(
                        vertical: -4, horizontal: -4), // 수직 간격 조정
                    title: Text(
                      reportQuizErrorType.text,
                      style: AppTexts.b8.copyWith(color: ColorName.g1),
                    ),
                    value: reportQuizErrorType,
                    groupValue: _selectedValue,
                    onChanged: (value) {
                      setState(() {
                        _selectedValue = value;
                      });
                      _hideKeyboard();
                    },
                  ),
                );
              }),
              SizedBox(
                height: 12,
              ),
              ReportTextField(
                focusNode: _focusNode,
                controller: _textController,
                backgroundColor: ColorName.b1,
                color: ColorName.g7,
                textColor: ColorName.w1,
                hintText: '내용을 입력해 주세요.',
                hintStyle: AppTexts.b10.copyWith(color: ColorName.g3),
                borderRadius: 16,
                keyboardType: TextInputType.multiline,
                minLines: 4,
                maxLines: 4,
              ),
              SizedBox(
                height: 12,
              ),
              CtaButtonL1(
                text: "오류 접수하기",
                enabled: _selectedValue != null,
                onPressed: () => _onSubmit(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
