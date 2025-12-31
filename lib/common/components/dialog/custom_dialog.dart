import 'package:flutter/material.dart';

import '../../../gen/colors.gen.dart';
import '../../theme/app_style.dart';
import '../button/cta_button_l1.dart';
import '../button/cta_button_l2.dart';

class CustomDialog extends StatelessWidget {
  const CustomDialog({
    super.key,
    required this.title,
    required this.content,
    required this.confirmButtonText,
    required this.cancelButtonText,
    required this.onConfirm,
    required this.onCancel,
    this.icon,
    this.titleStyle,
    this.contentStyle,
    this.confirmAnalyticsEventName,
    this.confirmAnalyticsEventParams,
    this.cancelAnalyticsEventName,
    this.cancelAnalyticsEventParams,
  });

  final String title;
  final String content;
  final String confirmButtonText;
  final String cancelButtonText;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final Widget? icon;
  final TextStyle? titleStyle;
  final TextStyle? contentStyle;
  final String? confirmAnalyticsEventName;
  final Map<String, dynamic>? confirmAnalyticsEventParams;
  final String? cancelAnalyticsEventName;
  final Map<String, dynamic>? cancelAnalyticsEventParams;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorName.g7,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: ColorName.g6, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title,
                style:
                    titleStyle ?? AppTexts.b11.copyWith(color: ColorName.g2)),
            const SizedBox(height: 3),
            Text(
              content,
              style: contentStyle ?? AppTexts.b7.copyWith(color: ColorName.w1),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            if (icon != null) ...[
              icon!,
            ],
            const SizedBox(height: 30),
            Row(
              children: [
                if (cancelButtonText.isNotEmpty)
                  Expanded(
                    child: CtaButtonL2(
                      text: cancelButtonText,
                      onPressed: onCancel,
                      height: 41,
                      borderRadius: 7,
                      analyticsEventName: cancelAnalyticsEventName,
                      analyticsEventParams: cancelAnalyticsEventParams,
                    ),
                  ),
                if (cancelButtonText.isNotEmpty) const SizedBox(width: 6),
                Expanded(
                  child: CtaButtonL1(
                    text: confirmButtonText,
                    onPressed: onConfirm,
                    height: 41,
                    borderRadius: 7,
                    analyticsEventName: confirmAnalyticsEventName,
                    analyticsEventParams: confirmAnalyticsEventParams,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
