import 'package:bookstar/gen/colors.gen.dart';
import 'package:flutter/material.dart';

class CustomSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color activeColor;
  final Color inactiveColor;
  final Color activeThumbColor;
  final Color inactiveThumbColor;
  final double width;
  final double height;
  final double thumbSize;
  final Duration animationDuration;

  const CustomSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor = ColorName.p1,
    this.inactiveColor = ColorName.w1,
    this.activeThumbColor = ColorName.w1,
    this.inactiveThumbColor = ColorName.g3,
    this.width = 45.0,
    this.height = 25.0,
    this.thumbSize = 18.0,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  @override
  State<CustomSwitch> createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    if (widget.value) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(CustomSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (widget.value) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.onChanged != null) {
          widget.onChanged!(!widget.value);
        }
      },
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.height / 2),
              color: Color.lerp(
                widget.inactiveColor,
                widget.activeColor,
                _animation.value,
              ),
            ),
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: widget.animationDuration,
                  curve: Curves.easeInOut,
                  left:
                      _animation.value * (widget.width - widget.thumbSize - 4) +
                          2,
                  top: (widget.height - widget.thumbSize) / 2,
                  child: Container(
                    width: widget.thumbSize,
                    height: widget.thumbSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.lerp(
                        widget.inactiveThumbColor,
                        widget.activeThumbColor,
                        _animation.value,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: ColorName.g3.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
