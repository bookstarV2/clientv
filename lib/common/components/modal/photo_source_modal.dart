import 'package:bookstar/common/service/analytics_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bookstar/gen/colors.gen.dart';
import 'package:bookstar/common/theme/style/app_texts.dart';
import 'package:bookstar/gen/assets.gen.dart';

/// PhotoSourceModal
///
/// Shows a modal bottom sheet for selecting a photo source (camera/gallery).
///
/// Usage:
/// ```dart
/// await PhotoSourceModal.show(
///   context,
///   onPick: (source) async {
///     // Handle image picking
///   },
/// );
/// ```
class PhotoSourceModal extends StatelessWidget {
  const PhotoSourceModal({super.key, required this.onPick});

  final Future<void> Function(ImageSource source) onPick;

  static Future<void> show(
    BuildContext context, {
    required Future<void> Function(ImageSource source) onPick,
    Color? backgroundColor,
    ShapeBorder? shape,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: backgroundColor ?? ColorName.g6,
      shape: shape ??
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
      builder: (_) => PhotoSourceModal(onPick: onPick),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 234,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '사진 선택하기',
              style: AppTexts.b7.copyWith(color: ColorName.w1),
            ),
            const SizedBox(height: 24),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildOption(
                    context,
                    svg: Assets.icons.icCamera,
                    label: '카메라',
                    iconColor: ColorName.g3,
                    iconSize: 24.07421875,
                    onTap: () {
                      AnalyticsService.logEvent('click_photo_source',
                          parameters: {'source': 'camera'});
                      onPick(ImageSource.camera);
                    },
                  ),
                  const SizedBox(width: 22),
                  _buildOption(
                    context,
                    svg: Assets.icons.icPhotoLibrary,
                    label: '사진',
                    iconColor: ColorName.g3,
                    iconSize: 21.5703125,
                    onTap: () {
                      AnalyticsService.logEvent('click_photo_source',
                          parameters: {'source': 'gallery'});
                      onPick(ImageSource.gallery);
                    },
                  ),
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required SvgGenImage svg,
    required String label,
    required Color iconColor,
    required double iconSize,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        onTap();
      },
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: SizedBox(
          width: 77,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: ColorName.dim2,
                  borderRadius: BorderRadius.circular(38.5),
                ),
                child: Center(
                  child: svg.svg(
                    width: iconSize,
                    colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(label, style: AppTexts.b8.copyWith(color: ColorName.g2)),
            ],
          ),
        ),
      ),
    );
  }
}
