import 'package:bookstar/common/service/analytics_service.dart';
import 'package:bookstar/common/theme/style/app_texts.dart';
import 'package:bookstar/gen/colors.gen.dart';
import 'package:flutter/material.dart';

class CustomTextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final String? analyticsEventName;
  final Map<String, dynamic>? analyticsEventParams;

  const CustomTextButton({
    required this.label,
    this.onTap,
    this.analyticsEventName,
    this.analyticsEventParams,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionContainer(
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        onTap: () {
          if (analyticsEventName != null) {
            AnalyticsService.logEvent(
              analyticsEventName!,
              parameters: analyticsEventParams,
            );
          }
          onTap?.call();
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _SectionTitle(label),
            const Spacer(),
            const Icon(Icons.chevron_right, color: ColorName.g3),
          ],
        ),
      ),
    );
  }
}

class _SectionContainer extends StatelessWidget {
  final Widget child;
  const _SectionContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: ColorName.g7, width: 1),
        ),
      ),
      alignment: Alignment.centerLeft,
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTexts.b8.copyWith(color: ColorName.g2),
    );
  }
}
