import 'package:bookstar/common/service/analytics_service.dart';
import 'package:bookstar/common/theme/style/app_texts.dart';
import 'package:bookstar/gen/colors.gen.dart';
import 'package:flutter/material.dart';

class CtaButtonS extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool enabled;
  final double width;
  final double height;
  final TextStyle textStyle;
  final Color defaultTextColor;
  final double borderRadius;
  final Color defaultBackgroundColor;
  final String? analyticsEventName;
  final Map<String, dynamic>? analyticsEventParams;

  const CtaButtonS({
    Key? key,
    required this.text,
    this.onPressed,
    this.enabled = true,
    this.width = 200,
    this.height = 27,
    this.textStyle = AppTexts.b12,
    this.defaultTextColor = ColorName.p1,
    this.borderRadius = 5,
    this.defaultBackgroundColor = ColorName.g7,
    this.analyticsEventName,
    this.analyticsEventParams,
  }) : super(key: key);

  @override
  State<CtaButtonS> createState() => _CtaButtonSState();
}

class _CtaButtonSState extends State<CtaButtonS> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // 상태별 스타일 정의
    final bool isDisabled = !widget.enabled || widget.onPressed == null;
    Color backgroundColor;
    Color borderColor;
    Color textColor;

    if (isDisabled) {
      backgroundColor = ColorName.g7;
      borderColor = ColorName.g6;
      textColor = ColorName.g3;
    } else if (_isPressed) {
      backgroundColor = const Color(0xFF242429);
      borderColor = const Color(0xFF2F2F35);
      textColor = const Color(0xFF775DFF);
    } else if (_isHovered) {
      backgroundColor = const Color(0xFF38383E);
      borderColor = const Color(0xFF46464F);
      textColor = const Color(0xFF8A75FF);
    } else {
      backgroundColor = widget.defaultBackgroundColor;
      borderColor = ColorName.g6;
      textColor = widget.defaultTextColor;
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
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(color: borderColor, width: 1),
          ),
          alignment: Alignment.center,
          child: Text(
            widget.text,
            style: widget.textStyle.copyWith(color: textColor),
          ),
        ),
      ),
    );
  }
}
