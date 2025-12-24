import 'package:bookstar/common/service/analytics_service.dart';
import 'package:bookstar/common/theme/style/app_texts.dart';
import 'package:bookstar/gen/colors.gen.dart';
import 'package:flutter/material.dart';

class CtaButtonL2 extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool enabled;
  final Color? backgroundColor;
  final Color? borderColor;
  final double height;
  final double borderRadius;
  final String? analyticsEventName;
  final Map<String, dynamic>? analyticsEventParams;

  const CtaButtonL2({
    Key? key,
    required this.text,
    this.onPressed,
    this.enabled = true,
    this.backgroundColor,
    this.borderColor,
    this.height = 56,
    this.borderRadius = 10,
    this.analyticsEventName,
    this.analyticsEventParams,
  }) : super(key: key);

  @override
  State<CtaButtonL2> createState() => _CtaButtonL2State();
}

class _CtaButtonL2State extends State<CtaButtonL2> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // 상태별 스타일 정의
    final bool isDisabled = !widget.enabled || widget.onPressed == null;
    Color backgroundColor;
    Color borderColor;

    if (widget.backgroundColor != null) {
      backgroundColor = widget.backgroundColor!;
    } else if (isDisabled) {
      backgroundColor = ColorName.g7;
    } else if (_isPressed) {
      backgroundColor = const Color(0xFF222228);
    } else if (_isHovered) {
      backgroundColor = const Color(0xFF46464F);
    } else {
      backgroundColor = ColorName.g7;
    }

    if (widget.borderColor != null) {
      borderColor = widget.borderColor!;
    } else if (isDisabled) {
      borderColor = ColorName.g6;
    } else if (_isPressed) {
      borderColor = const Color(0xFF2E2E34);
    } else if (_isHovered) {
      borderColor = const Color(0xFF484851);
    } else {
      borderColor = ColorName.g6;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() {
        _isHovered = false;
        _isPressed = false;
      }),
      child: GestureDetector(
        onTapDown: (_) {
          if (!isDisabled) setState(() => _isPressed = true);
        },
        onTapUp: (_) {
          if (!isDisabled) setState(() => _isPressed = false);
        },
        onTapCancel: () {
          if (!isDisabled) setState(() => _isPressed = false);
        },
        onTap: isDisabled
            ? null
            : () {
                if (widget.analyticsEventName != null) {
                  AnalyticsService.logEvent(
                    widget.analyticsEventName!,
                    parameters: widget.analyticsEventParams,
                  );
                }
                widget.onPressed?.call();
              },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: 341,
          height: widget.height,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(color: borderColor, width: 1),
          ),
          alignment: Alignment.center,
          child: Text(
            widget.text,
            style: isDisabled
                ? AppTexts.b7.copyWith(color: ColorName.g3)
                : AppTexts.b7.copyWith(color: ColorName.w1),
          ),
        ),
      ),
    );
  }
}
