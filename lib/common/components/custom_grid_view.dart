import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../common/theme/app_style.dart';
import '../../../../gen/colors.gen.dart';

class CustomGridView extends StatelessWidget {
  const CustomGridView({
    super.key,
    required this.emptyIcon,
    required this.emptyText,
    this.emptyTextStyle,
    this.emptyDescription,
    this.emptyDescriptionStyle,
    required this.isEmpty,
    required this.itemCount,
    required this.itemBuilder,
    this.separatorBuilder,
    required this.hasNext,
    this.scrollController,
    this.crossAxisCount = 3,
    this.gridPadding = const EdgeInsets.only(top: 20),
    this.itemPadding = const EdgeInsets.symmetric(horizontal: 5),
    this.crossAxisSpacing = 16,
    this.mainAxisSpacing = 0,
    this.childAspectRatio = 0.65,
  });

  final SvgPicture emptyIcon;
  final String emptyText;
  final TextStyle? emptyTextStyle;
  final String? emptyDescription;
  final TextStyle? emptyDescriptionStyle;
  final bool isEmpty;
  final int itemCount;
  final Widget? Function(BuildContext, int) itemBuilder;
  final Widget Function(BuildContext, int)? separatorBuilder;
  final bool hasNext;
  final ScrollController? scrollController;
  final int crossAxisCount;
  final EdgeInsets gridPadding;
  final EdgeInsets itemPadding;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    final rowCount = (itemCount / crossAxisCount).ceil();

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
        : Padding(
            padding: gridPadding,
            child: CustomScrollView(
              controller: scrollController,
              slivers: [
                for (int row = 0; row < rowCount; row++) ...[
                  SliverPadding(
                    padding: itemPadding,
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final itemIndex = row * crossAxisCount + index;
                          if (itemIndex >= itemCount) return const SizedBox();
                          return itemBuilder(context, itemIndex);
                        },
                        childCount: crossAxisCount,
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: crossAxisSpacing,
                        mainAxisSpacing: mainAxisSpacing,
                        childAspectRatio: childAspectRatio,
                      ),
                    ),
                  ),
                  if (row < rowCount || hasNext)
                    SliverToBoxAdapter(
                      child: separatorBuilder?.call(context, row) ??
                          Padding(
                            padding: EdgeInsets.only(top: 4.0, bottom: 30),
                            child: Divider(
                              thickness: 7,
                              color: AppColors.DIVIDER_COLOR,
                              radius: BorderRadius.circular(5.0),
                            ),
                          ),
                    ),
                ],
              ],
            ),
          );
  }
}
