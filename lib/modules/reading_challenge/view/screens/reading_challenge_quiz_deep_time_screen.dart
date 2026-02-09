import 'dart:async';
import 'dart:math' as math;

import 'package:bookstar/common/components/button/cta_button_s.dart';
import 'package:bookstar/common/theme/style/app_texts.dart';
import 'package:bookstar/gen/assets.gen.dart';
import 'package:bookstar/gen/colors.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReadingChallengeQuizDeepTimeScreen extends ConsumerStatefulWidget {
  const ReadingChallengeQuizDeepTimeScreen({
    super.key,
    required this.chapterId,
    required this.challengeId,
    required this.isLock,
    required this.onStartTap,
    required this.onPauseTap,
    required this.onResumeTap,
    required this.onStopTap,
    required this.onLockToggle,
    required this.controller,
  });

  final int chapterId;
  final int challengeId;
  final bool isLock;
  final VoidCallback onStartTap;
  final VoidCallback onPauseTap;
  final VoidCallback onResumeTap;
  final VoidCallback onStopTap;
  final VoidCallback onLockToggle;
  final CustomCountDownController controller;

  @override
  ConsumerState<ReadingChallengeQuizDeepTimeScreen> createState() =>
      _ReadingChallengeQuizDeepTimeScreenState();
}

class _ReadingChallengeQuizDeepTimeScreenState
    extends ConsumerState<ReadingChallengeQuizDeepTimeScreen>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final screenSize =
        MediaQuery.of(context).size.width > MediaQuery.of(context).size.height
            ? MediaQuery.of(context).size.height
            : MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: screenHeight -
              MediaQuery.of(context).padding.top -
              kToolbarHeight,
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.center,
              colors: [
                ColorName.b1,
                ColorName.p1.withValues(alpha: 0.2),
                Colors.transparent, // 중간에서 투명하게
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 16),
                _buildDeepTimeLock(
                    isLock: widget.isLock,
                    toggleIsLock: () async {
                      widget.onLockToggle();
                    }),
                SizedBox(height: 16),
                Align(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTimer(
                        screenSize: screenSize,
                        controller: widget.controller,
                      ),
                      SizedBox(height: 38),
                      _buildButtons(
                        controller: widget.controller,
                        onStart: () {
                          widget.onStartTap();
                        },
                        onPause: () {
                          widget.onPauseTap();
                        },
                        onResume: () {
                          widget.onResumeTap();
                        },
                        onStop: () {
                          widget.onStopTap();
                        },
                      ),
                      SizedBox(height: 23),
                      // 시간 표시
                      ValueListenableBuilder<String>(
                        valueListenable: widget.controller.currentTime,
                        builder: (context, timeString, child) {
                          final parts = timeString.split(':');
                          final displayTime =
                              '${parts[1]}:${parts[2]}'; // MM:SS 형식
                          return Text(
                            displayTime,
                            style: TextStyle(
                                fontSize: 50,
                                color: ColorName.p1,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'AkiraExpandedDemo'),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeepTimeLock({
    required bool isLock,
    required Function() toggleIsLock,
  }) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: GestureDetector(
          onTap: () {
            toggleIsLock();
          },
          child: !isLock
              ? Assets.icons.icDeepTimeLockOpen.svg()
              : Assets.icons.icDeepTimeLockClose.svg(),
        ),
      ),
    );
  }

  Widget _buildTimer({
    required double screenSize,
    required CustomCountDownController controller,
  }) {
    return SizedBox(
      height: screenSize * 0.6,
      child: CustomCountDownTimer(
        controller: controller,
      ),
    );
  }

  Widget _buildButtons({
    required CustomCountDownController controller,
    required Function() onStart,
    required Function() onPause,
    required Function() onResume,
    required Function() onStop,
  }) {
    return ValueListenableBuilder<bool>(
      valueListenable: controller.isStarted,
      builder: (context, isStarted, child) {
        return ValueListenableBuilder<bool>(
          valueListenable: controller.isPaused,
          builder: (context, isPaused, child) {
            if (!isStarted) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CtaButtonS(
                    width: 135,
                    height: 41,
                    text: "🚀독서 시작하기",
                    textStyle: AppTexts.b7,
                    borderRadius: 10,
                    defaultBackgroundColor: ColorName.p1,
                    defaultTextColor: ColorName.w1,
                    onPressed: () {
                      onStart();
                    },
                  )
                ],
              );
            } else if (isStarted && !isPaused) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CtaButtonS(
                    width: 135,
                    height: 41,
                    text: "️⏸️독서 일시정지",
                    textStyle: AppTexts.b7,
                    borderRadius: 10,
                    defaultBackgroundColor: ColorName.g7,
                    defaultTextColor: ColorName.w1,
                    onPressed: () {
                      onPause();
                    },
                  )
                ],
              );
            } else if (isStarted && isPaused) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CtaButtonS(
                    width: 135,
                    height: 41,
                    text: "🚀독서 계속하기",
                    textStyle: AppTexts.b7,
                    borderRadius: 10,
                    defaultBackgroundColor: ColorName.g7,
                    defaultTextColor: ColorName.w1,
                    onPressed: () {
                      onResume();
                    },
                  ),
                  SizedBox(width: 8),
                  CtaButtonS(
                    width: 135,
                    height: 41,
                    text: "🧩퀴즈 풀러가기",
                    textStyle: AppTexts.b7,
                    borderRadius: 10,
                    defaultBackgroundColor: ColorName.p1,
                    defaultTextColor: ColorName.w1,
                    onPressed: () {
                      onStop();
                    },
                  )
                ],
              );
            } else {
              return Container();
            }
          },
        );
      },
    );
  }
}

// ============================================================================
// CustomCountDownTimer
// ============================================================================

class CustomCountDownTimer extends StatefulWidget {
  final VoidCallback? onComplete;
  final VoidCallback? onStart;
  final ValueChanged<String>? onChange;
  final CustomCountDownController? controller;

  const CustomCountDownTimer({
    this.onComplete,
    this.onStart,
    this.onChange,
    super.key,
    this.controller,
  });

  @override
  CustomCountDownTimerState createState() => CustomCountDownTimerState();
}

class CustomCountDownTimerState extends State<CustomCountDownTimer>
    with TickerProviderStateMixin {
  AnimationController? _controller;
  CustomCountDownController? countDownController;
  Timer? _backgroundTimer;
  final duration = 60;
  final ringColor = Color.fromRGBO(45, 45, 51, 1);
  final fillGradient = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [Color.fromRGBO(175, 159, 255, 1), Color.fromRGBO(80, 63, 171, 1)],
  );
  final backgroundColor = Colors.transparent;
  final strokeWidth = 10.0;
  final strokeCap = StrokeCap.round;

  DateTime? _startTime;
  int _totalElapsedSeconds = 0;

  void _setController() {
    countDownController?._state = this;
  }

  void _startBackgroundTimer() {
    _backgroundTimer?.cancel();
    _backgroundTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_startTime != null) {
        final elapsed = DateTime.now().difference(_startTime!);
        _totalElapsedSeconds = elapsed.inSeconds;
        final timeString = _getTime(Duration(seconds: _totalElapsedSeconds));
        countDownController?.currentTime.value = timeString;
        if (widget.onChange != null) widget.onChange!(timeString);
      }
    });
  }

  void _stopBackgroundTimer() {
    _backgroundTimer?.cancel();
    _backgroundTimer = null;
  }

  String _getTime(Duration duration) {
    return '${duration.inHours.toString().padLeft(2, '0')}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  void _onStart() {
    if (widget.onStart != null) widget.onStart!();
  }

  @override
  void initState() {
    countDownController = widget.controller ?? CustomCountDownController();
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: duration),
    );

    bool hasStarted = false;
    _controller!.addStatusListener((status) {
      switch (status) {
        case AnimationStatus.forward:
          if (!hasStarted) {
            _onStart();
            hasStarted = true;
          }
          break;
        case AnimationStatus.reverse:
        case AnimationStatus.dismissed:
        case AnimationStatus.completed:
          break;
      }
    });

    _setController();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxHeight < constraints.maxWidth
            ? constraints.maxHeight
            : constraints.maxWidth;

        return Center(
          child: SizedBox(width: size, height: size, child: _buildTimer(size)),
        );
      },
    );
  }

  Widget _buildTimer(double size) {
    return AnimatedBuilder(
      animation: _controller!,
      builder: (context, child) {
        int currentElapsedSeconds = _totalElapsedSeconds;
        if (_startTime != null && _controller!.isAnimating) {
          final elapsed = DateTime.now().difference(_startTime!);
          currentElapsedSeconds = elapsed.inSeconds;
        }

        return Align(
          child: AspectRatio(
            aspectRatio: 1.0,
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: CustomPaint(
                    painter: CustomTimerPainter(
                      animation: _controller,
                      fillGradient: fillGradient,
                      ringColor: ringColor,
                      strokeWidth: strokeWidth,
                      strokeCap: strokeCap,
                      backgroundColor: backgroundColor,
                      elapsedSeconds: currentElapsedSeconds,
                    ),
                  ),
                ),
                Align(
                  alignment: FractionalOffset.center,
                  child: CharacterWidget(
                    isRunning: _controller?.isAnimating ?? false,
                    size: size,
                  ),
                ),
                if (_controller!.isAnimating)
                  Positioned(
                    right: size * 0.05,
                    top: size * 0.25,
                    child: ProgressMessage(
                      elapsedMinutes: currentElapsedSeconds ~/ 60,
                      fontSize: size * 0.04,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _stopBackgroundTimer();
    _controller!.stop();
    _controller!.dispose();
    super.dispose();
  }
}

// ============================================================================
// CustomCountDownController
// ============================================================================

class CustomCountDownController {
  CustomCountDownTimerState? _state;
  ValueNotifier<bool> isStarted = ValueNotifier<bool>(false);
  ValueNotifier<bool> isPaused = ValueNotifier<bool>(false);
  ValueNotifier<String> currentTime = ValueNotifier<String>("00:00:00");

  void start() {
    if (_state != null && _state?._controller != null) {
      _state?._startTime = DateTime.now();
      _state?._totalElapsedSeconds = 0;
      _state?._controller?.repeat();
      _state?._startBackgroundTimer();
      isStarted.value = true;
      isPaused.value = false;
    }
  }

  void pause() {
    if (_state != null && _state?._controller != null) {
      if (_state!._startTime != null) {
        final elapsed = DateTime.now().difference(_state!._startTime!);
        _state!._totalElapsedSeconds = elapsed.inSeconds;
        currentTime.value = _state!._getTime(
          Duration(seconds: _state!._totalElapsedSeconds),
        );
      }
      _state?._controller?.stop(canceled: false);
      _state?._stopBackgroundTimer();
      isPaused.value = true;
    }
  }

  void resume() {
    if (_state != null && _state?._controller != null) {
      _state?._startTime = DateTime.now().subtract(
        Duration(seconds: _state!._totalElapsedSeconds),
      );
      _state?._controller?.repeat(min: _state!._controller!.value);
      _state?._startBackgroundTimer();
      isPaused.value = false;
    }
  }

  void restart({int? duration}) {
    if (_state != null && _state?._controller != null) {
      _state?._controller!.duration = Duration(
        seconds: duration ?? _state!._controller!.duration!.inSeconds,
      );
      _state?._startTime = DateTime.now();
      _state?._totalElapsedSeconds = 0;
      _state?._controller?.repeat();
      _state?._startBackgroundTimer();
      isStarted.value = true;
      isPaused.value = false;
      currentTime.value = "00:00:00";
    }
  }

  void reset() {
    if (_state != null && _state?._controller != null) {
      _state?._controller?.reset();
      _state?._stopBackgroundTimer();
      _state?._startTime = null;
      _state?._totalElapsedSeconds = 0;
      isStarted.value = false;
      isPaused.value = false;
      currentTime.value = "00:00:00";
    }
  }

  String? getTime() {
    if (_state != null) {
      int totalSeconds = _state!._totalElapsedSeconds;
      if (_state!._startTime != null && _state!._controller!.isAnimating) {
        final elapsed = DateTime.now().difference(_state!._startTime!);
        totalSeconds = elapsed.inSeconds;
      }
      return _state?._getTime(Duration(seconds: totalSeconds));
    }
    return "00:00:00";
  }
}

// ============================================================================
// CustomTimerPainter
// ============================================================================

class CustomTimerPainter extends CustomPainter {
  CustomTimerPainter({
    this.animation,
    this.fillGradient,
    this.ringColor,
    this.strokeWidth,
    this.strokeCap,
    this.backgroundColor,
    this.elapsedSeconds = 0,
  }) : super(repaint: animation);

  final Animation<double>? animation;
  final Color? ringColor, backgroundColor;
  final double? strokeWidth;
  final StrokeCap? strokeCap;
  final Gradient? fillGradient;
  final int elapsedSeconds;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = ringColor!
      ..strokeWidth = strokeWidth!
      ..strokeCap = strokeCap!
      ..style = PaintingStyle.stroke;

    paint.shader = null;

    canvas.drawCircle(size.center(Offset.zero), size.width / 2, paint);

    // 1시간(3600초) 단위로 progress 계산
    const oneHourInSeconds = 3600;
    final secondsInCurrentHour = elapsedSeconds % oneHourInSeconds;
    final progressRatio = secondsInCurrentHour / oneHourInSeconds;
    double progress = progressRatio * 2 * math.pi;
    double startAngle = math.pi * 1.5;

    if (fillGradient != null) {
      final rect = Rect.fromCircle(
        center: size.center(Offset.zero),
        radius: size.width / 2,
      );
      paint.shader = fillGradient!.createShader(rect);
    }

    canvas.drawArc(Offset.zero & size, startAngle, progress, false, paint);

    if (backgroundColor != null) {
      final backgroundPaint = Paint();
      backgroundPaint.color = backgroundColor!;
      canvas.drawCircle(
        size.center(Offset.zero),
        size.width / 2.2,
        backgroundPaint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomTimerPainter oldDelegate) {
    return animation!.value != oldDelegate.animation!.value ||
        ringColor != oldDelegate.ringColor ||
        elapsedSeconds != oldDelegate.elapsedSeconds;
  }
}

// ============================================================================
// CharacterWidget
// ============================================================================

class CharacterWidget extends StatefulWidget {
  final bool isRunning;
  final double? size;

  const CharacterWidget({
    super.key,
    this.isRunning = false,
    this.size,
  });

  @override
  State<CharacterWidget> createState() => _CharacterWidgetState();
}

class _CharacterWidgetState extends State<CharacterWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, widget.isRunning ? _bounceAnimation.value : 0),
          child: child,
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!widget.isRunning) Assets.icons.icDeepTimeWait.svg(),
          if (widget.isRunning) Assets.icons.icDeepTimeStarting.svg(),
        ],
      ),
    );
  }
}

// ============================================================================
// ProgressMessage
// ============================================================================

class ProgressMessage extends StatefulWidget {
  final int elapsedMinutes;
  final double? fontSize;

  const ProgressMessage({
    super.key,
    required this.elapsedMinutes,
    this.fontSize,
  });

  @override
  State<ProgressMessage> createState() => _ProgressMessageState();
}

class _ProgressMessageState extends State<ProgressMessage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void didUpdateWidget(ProgressMessage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.elapsedMinutes != widget.elapsedMinutes) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _getMessage() {
    final minutes = widget.elapsedMinutes;
    if (minutes == 0) {
      return '시작!';
    } else {
      return '$minutes분째 독서 중!';
    }
  }

  @override
  Widget build(BuildContext context) {
    final textSize = widget.fontSize ?? 14;
    final paddingScale = textSize / 14;
    final radius = 20 * paddingScale;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 12 * paddingScale,
          vertical: 6 * paddingScale,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF2D2D33),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(radius),
            topRight: Radius.circular(radius),
            bottomRight: Radius.circular(radius),
            bottomLeft: Radius.circular(2 * paddingScale),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 4 * paddingScale,
              offset: Offset(0, 2 * paddingScale),
            ),
          ],
        ),
        child: Text(
          _getMessage(),
          style: AppTexts.b7.copyWith(color: ColorName.w1),
        ),
      ),
    );
  }
}
