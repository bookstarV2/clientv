import 'package:bookstar/common/service/analytics_service.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../gen/colors.gen.dart';
import '../../theme/style/app_texts.dart';
import 'checkbox_1.dart';

class UserWithCheckbox extends StatelessWidget {
  final int id;
  final String nickname;
  final String profileImageUrl;
  final bool checked;
  final ValueChanged<bool> onChanged;
  final bool enabled;
  final VoidCallback? onViewProfile;

  const UserWithCheckbox({
    super.key,
    required this.id,
    required this.nickname,
    required this.profileImageUrl,
    required this.checked,
    required this.onChanged,
    this.enabled = true,
    this.onViewProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 88,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: ColorName.g7, width: 1),
        ),
      ),
      child: Padding(
        padding:
            const EdgeInsets.only(left: 17, top: 15.5, bottom: 15.5, right: 17),
        child: SizedBox(
          width: double.infinity,
          height: 58,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: ColorName.g7,
                      borderRadius: BorderRadius.circular(12.0833),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.0833),
                      child: profileImageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: profileImageUrl,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) => Container(
                                color: ColorName.g7,
                                child: const Icon(
                                  Icons.person,
                                  color: ColorName.g3,
                                  size: 24,
                                ),
                              ),
                            )
                          : Container(
                              color: ColorName.g7,
                              child: const Icon(
                                Icons.person,
                                color: ColorName.g3,
                                size: 24,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 180),
                    child: Text(
                      nickname,
                      style: AppTexts.b8.copyWith(color: ColorName.w1),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      if (onViewProfile != null) {
                        AnalyticsService.logEvent('click_view_profile',
                            parameters: {'member_id': id});
                        onViewProfile!();
                      }
                    },
                    child: Row(
                      children: [
                        SizedBox(
                          width: 54,
                          height: 19,
                          child: Text(
                            "책로그 보기",
                            style: AppTexts.b10.copyWith(color: ColorName.g3),
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(Icons.arrow_forward_ios,
                            color: ColorName.g3, size: 13),
                      ],
                    ),
                  ),
                ],
              ),
              // Checkbox
              CheckBox1(
                value: checked,
                onChanged: enabled ? onChanged : (_) {},
                enabled: enabled,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
