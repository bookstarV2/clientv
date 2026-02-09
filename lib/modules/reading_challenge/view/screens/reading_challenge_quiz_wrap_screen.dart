import 'package:bookstar/common/components/base_screen.dart';
import 'package:bookstar/common/components/dialog/custom_dialog.dart';
import 'package:bookstar/common/service/analytics_service.dart';
import 'package:bookstar/common/theme/style/app_texts.dart';
import 'package:bookstar/gen/assets.gen.dart';
import 'package:bookstar/gen/colors.gen.dart';
import 'package:bookstar/modules/reading_challenge/view/screens/reading_challenge_quiz_check_screen.dart';
import 'package:bookstar/modules/reading_challenge/view/screens/reading_challenge_quiz_deep_time_screen.dart';
import 'package:bookstar/modules/reading_challenge/view/screens/reading_challenge_quiz_screen.dart';
import 'package:bookstar/modules/reading_challenge/view/widgets/report_quiz_error_dialog.dart';
import 'package:bookstar/modules/reading_challenge/view/widgets/report_quiz_error_success_dialog.dart';
import 'package:bookstar/modules/reading_challenge/view_model/challenge_quiz_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ReadingChallengeWrapQuizScreen extends BaseScreen {
  const ReadingChallengeWrapQuizScreen(
      {super.key, required this.chapterId, required this.challengeId});

  final int chapterId;
  final int challengeId;

  @override
  BaseScreenState<ReadingChallengeWrapQuizScreen> createState() =>
      _ReadingChallengeWrapQuizScreenState();
}

class _ReadingChallengeWrapQuizScreenState
    extends BaseScreenState<ReadingChallengeWrapQuizScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  bool _showQuizTab = false;
  bool _isLock = false;
  bool _hasQuizScreen = false;
  final CustomCountDownController _timerController =
      CustomCountDownController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onInitState() {
    _tabController = TabController(length: 2, vsync: this);
    super.onInitState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  @override
  bool canPop() {
    return !_isLock;
  }

  Future<bool> _postTimer() async {
    // 독립 화면으로 사용될 때의 기존 로직
    final result = await showDialog(
        context: context,
        builder: (context) {
          return CustomDialog(
            title: '퀴즈를 풀러 가시겠습니까?',
            content: '선택한 챕터를 다 읽으셨다면, 퀴즈 풀러가기를 눌러주세요!',
            titleStyle: AppTexts.b7.copyWith(color: ColorName.w1),
            contentStyle: AppTexts.b11.copyWith(color: ColorName.g2),
            icon: Assets.icons.icDeepTimeGoToQuiz.svg(width: 100, height: 100),
            onCancel: () {
              Navigator.of(context).pop(false);
            },
            onConfirm: () {
              Navigator.of(context).pop(true);
            },
            confirmButtonText: '퀴즈 풀러가기',
            cancelButtonText: '취소',
          );
        });
    if (result != null && result) {
      final notifier =
          ref.read(challengeQuizViewModelProvider(widget.chapterId).notifier);
      final parts = _timerController.currentTime.value.split(':');
      final minutes = int.parse(parts[1]);
      final seconds = int.parse(parts[2]);
      final totalSeconds = minutes * 60 + seconds;
      await notifier.postReadingTimers(
        challengeId: widget.challengeId,
        totalSeconds: totalSeconds,
      );
      await notifier.postProgress(
        challengeId: widget.challengeId,
        chapterId: widget.chapterId,
      );
      return true;
    } else {
      return false;
    }
  }

  void _onShowQuizTab() {
    if (!_showQuizTab) {
      setState(() {
        _showQuizTab = true;
      });
      final currentIndex = _tabController.index;
      _tabController.dispose();
      _tabController = TabController(length: 3, vsync: this);
      _tabController.index = currentIndex;
      setState(() {
        _hasQuizScreen = true;
      });
    }
  }

  Future<void> _onTapQuizError() async {
    final quizId = ref
        .read(challengeQuizViewModelProvider(widget.chapterId))
        .value
        ?.quizId;
    AnalyticsService.logEvent('click_open_report_quiz_error', parameters: {
      'screen_name': "reading_challenge_quiz",
      "quiz_id": quizId
    });

    final result = await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => ReportQuizErrorDialog(
              quizId: quizId!,
            ));

    if (result != null && result && mounted) {
      await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => ReportQuizErrorSuccessDialog());
    }
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('리딩챌린지'),
      automaticallyImplyLeading: false,
      leading: BackButton(
        onPressed: () {
          if (!_isLock) {
            context
                .go('/reading-challenge/start/${widget.challengeId}/', extra: {
              "requiredRefresh": true,
            });
          }
        },
      ),
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    final state = ref.watch(challengeQuizViewModelProvider(widget.chapterId));

    return state.when(
      data: (data) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  SizedBox(height: 23),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildCustomTabBar(
                        tabController: _tabController,
                      ),
                      GestureDetector(
                        onTap: () => _onTapQuizError(),
                        child: Text("오류 신고하기",
                            style: AppTexts.b8.copyWith(color: ColorName.g3)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                key: ValueKey(_showQuizTab),
                controller: _tabController,
                children: [
                  // 퀴즈확인 탭
                  ReadingChallengeQuizCheckScreen(
                      question: data.chapter.question,
                      choices: data.chapter.choices,
                      onButtonTap: () {
                        _tabController.animateTo(1);
                      }),
                  // 딥타이머 탭
                  ReadingChallengeQuizDeepTimeScreen(
                      chapterId: widget.chapterId,
                      challengeId: widget.challengeId,
                      isLock: _isLock,
                      controller: _timerController,
                      onStartTap: () {
                        // WidgetsBinding.instance.addPostFrameCallback((_) {
                        _timerController.start();
                        // });
                      },
                      onPauseTap: () {
                        _timerController.pause();
                        setState(() {});
                      },
                      onResumeTap: () {
                        _timerController.resume();
                        setState(() {});
                      },
                      onStopTap: () async {
                        if (!_hasQuizScreen) {
                          final isPost = await _postTimer();
                          if (isPost) {
                            _onShowQuizTab();
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _tabController.animateTo(2);
                            });
                          }
                        } else {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _tabController.animateTo(2);
                          });
                        }
                      },
                      onLockToggle: () {
                        setState(() {
                          _isLock = !_isLock;
                        });
                      }),
                  // 퀴즈 풀기 탭
                  if (_showQuizTab)
                    ReadingChallengeQuizScreen(
                        chapterId: widget.chapterId,
                        challengeId: widget.challengeId,
                        choiceResults: data.choiceResults,
                        chapter: data.chapter),
                ],
              ),
            ),
          ],
        );
      },
      loading: loading,
      error: error("리딩 챌린지 퀴즈 정보 취득 중 오류가 발생했습니다."),
    );
  }

  Widget _buildCustomTabBar({required TabController tabController}) {
    return AnimatedBuilder(
      animation: tabController,
      builder: (context, child) {
        return Container(
          height: 29,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7), color: ColorName.b2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTabItem(
                label: '퀴즈확인',
                isSelected: tabController.index == 0,
                onTap: () => tabController.animateTo(0),
              ),
              _buildTabItem(
                label: '독서하기',
                isSelected: tabController.index == 1,
                onTap: () => tabController.animateTo(1),
              ),
              if (_showQuizTab)
                _buildTabItem(
                  label: '퀴즈풀기',
                  isSelected: tabController.index == 2,
                  onTap: () => tabController.animateTo(2),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabItem({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 29,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        decoration: BoxDecoration(
          color: isSelected ? ColorName.g6 : ColorName.b2,
          borderRadius: BorderRadius.circular(isSelected ? 7 : 6),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTexts.b5.copyWith(
              color: isSelected ? ColorName.g2 : ColorName.g3,
            ),
          ),
        ),
      ),
    );
  }
}
