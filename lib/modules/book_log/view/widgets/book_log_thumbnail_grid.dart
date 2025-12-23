import 'package:bookstar/common/theme/style/app_texts.dart';
import 'package:bookstar/gen/assets.gen.dart';
import 'package:bookstar/modules/reading_diary/model/diary_thumbnail_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/components/grid/image_grid.dart';
import '../../../../gen/colors.gen.dart';

class BookLogThumbnailGrid extends ConsumerStatefulWidget {
  const BookLogThumbnailGrid({
    super.key,
    required this.thumbnails,
    required this.scrollController,
    required this.onClickThumbnail,
  });
  final List<DiaryThumbnail> thumbnails;
  final ScrollController scrollController;
  final Function(int) onClickThumbnail;

  @override
  ConsumerState<BookLogThumbnailGrid> createState() =>
      _BookLogThumbnailGridState();
}

class _BookLogThumbnailGridState extends ConsumerState<BookLogThumbnailGrid> {
  @override
  Widget build(BuildContext context) {
    final imageUrls = widget.thumbnails
        .map((d) => d.firstImage.imageUrl)
        .where((url) => url.isNotEmpty)
        .toList();

    return Expanded(
      child: ImageGrid(
        scrollController: widget.scrollController,
        imageUrls: imageUrls,
        crossAxisCount: 3,
        spacing: 0,
        onTap: (index) {
          widget.onClickThumbnail(index);
        },
        emptyWidget: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Assets.icons.icBooktalkSearchCharacter.svg(
                      width: 110,
                      height: 110,
                    ),
                    SizedBox(height: 18),
                    Text(
                      "아직 책로그가 없습니다.",
                      textAlign: TextAlign.center,
                      style: AppTexts.b7.copyWith(color: ColorName.w1),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
