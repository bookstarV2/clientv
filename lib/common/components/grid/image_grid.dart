import 'package:bookstar/common/theme/app_style.dart';
import 'package:bookstar/gen/colors.gen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageGrid extends StatelessWidget {
  final List<String> imageUrls;
  final double spacing;
  final int crossAxisCount;
  final Widget? emptyWidget;
  final Function(int)? onTap;
  final ScrollController? scrollController;

  const ImageGrid({
    Key? key,
    required this.imageUrls,
    this.spacing = 0,
    this.crossAxisCount = 3,
    this.emptyWidget,
    this.onTap,
    this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) {
      return emptyWidget ??
          Center(
              child: Text('이미지가 없습니다.',
                  style: AppTexts.b8.copyWith(color: ColorName.g3)));
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final double gridWidth = constraints.maxWidth;
        final double cellSize = gridWidth / crossAxisCount;
        final int totalRows = (imageUrls.length / crossAxisCount).ceil();
        return GridView.builder(
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 0,
            mainAxisSpacing: 0,
            childAspectRatio: 1,
          ),
          itemCount: imageUrls.length,
          itemBuilder: (context, idx) {
            final row = idx ~/ crossAxisCount;
            final col = idx % crossAxisCount;
            BorderSide borderSide =
                const BorderSide(color: ColorName.b2, width: 1);
            // 내부 경계선 + 외곽선 모두: 마지막 열이 아니면 오른쪽, 마지막 행이 아니면 아래쪽, 첫 열이면 왼쪽, 첫 행이면 위쪽
            Border border = Border(
              right: col != crossAxisCount - 1 ? borderSide : BorderSide.none,
              bottom: row != totalRows - 1 ? borderSide : BorderSide.none,
              left: col == 0 ? borderSide : BorderSide.none,
              top: row == 0 ? borderSide : BorderSide.none,
            );
            final imageUrl = imageUrls[idx];
            return GestureDetector(
              onTap: () {
                onTap?.call(idx);
              },
              child: Container(
                width: cellSize,
                height: cellSize,
                decoration: BoxDecoration(
                  color: ColorName.g7,
                  border: border,
                ),
                child: imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        placeholder: (context, url) => const Center(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(ColorName.g5),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => const Center(
                          child: Icon(Icons.image_not_supported_outlined,
                              color: ColorName.g5, size: 28),
                        ),
                      )
                    : const Center(
                        child: Icon(Icons.image_not_supported_outlined,
                            color: ColorName.g5, size: 28),
                      ),
              ),
            );
          },
        );
      },
    );
  }
}
// TODO: grid width/cell size를 유동적으로 바꿀 수 있도록 개선
