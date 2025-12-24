import 'package:bookstar/common/service/analytics_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SocialLoginButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String assetName;
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final bool isGoogle;
  final String? analyticsEventName;
  final Map<String, dynamic>? analyticsEventParams;

  const SocialLoginButton({
    super.key,
    required this.onPressed,
    required this.assetName,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.isGoogle = false,
    this.analyticsEventName,
    this.analyticsEventParams,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (analyticsEventName != null) {
          AnalyticsService.logEvent(
            analyticsEventName!,
            parameters: analyticsEventParams,
          );
        }
        onPressed();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(12), // https://butsteadily.tistory.com/16
          side: isGoogle
              ? BorderSide(color: Colors.grey.shade300)
              : BorderSide.none,
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(assetName, width: 20, height: 20),
          const SizedBox(width: 10),
          Text(label,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ))
        ],
      ),
    );
  }
}
