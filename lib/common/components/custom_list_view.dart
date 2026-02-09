import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../common/theme/style/app_texts.dart';
import '../../../../gen/colors.gen.dart';

class CustomListView extends StatelessWidget {
  const CustomListView({
    super.key,
    required this.emptyIcon,
    required this.emptyText,
    this.emptyTextStyle,
    this.emptyDescription,
    this.emptyDescriptionStyle,
    required this.isEmpty,
    required this.itemCount,
    required this.itemBuilder,
    this.scrollDirection = Axis.vertical,
    this.scrollController,
    this.separatorBuilder,
    this.disableScroll = false,
  });

  final SvgPicture emptyIcon;
  final String emptyText;
  final TextStyle? emptyTextStyle;
  final String? emptyDescription;
  final TextStyle? emptyDescriptionStyle;
  final bool isEmpty;
  final int itemCount;
  final Widget? Function(BuildContext, int) itemBuilder;
  final Axis scrollDirection;
  final ScrollController? scrollController;
  final Widget Function(BuildContext, int)? separatorBuilder;
  final bool disableScroll;

  @override
  Widget build(BuildContext context) {
    return isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                emptyIcon,
                const SizedBox(height: 12),
                Text(
                  emptyText,
                  style: emptyTextStyle ??
                      AppTexts.b8.copyWith(color: ColorName.g3),
                ),
                if (emptyDescription != null)
                  Text(
                    emptyDescription!,
                    style: emptyDescriptionStyle ??
                        AppTexts.b8.copyWith(color: ColorName.g3),
                  ),
              ],
            ),
          )
        : ListView.separated(
            scrollDirection: scrollDirection,
            controller: scrollController,
            shrinkWrap: disableScroll,
            physics: disableScroll ? NeverScrollableScrollPhysics() : null,
            itemCount: itemCount,
            itemBuilder: itemBuilder,
            separatorBuilder: separatorBuilder ??
                (context, index) => const Divider(height: 1));
  }
}
