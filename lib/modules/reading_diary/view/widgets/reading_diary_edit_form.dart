import 'dart:typed_data';

import 'package:bookstar/common/components/base_screen.dart';
import 'package:bookstar/common/components/button/cta_button_l1.dart';
import 'package:bookstar/common/components/custom_switch.dart';
import 'package:bookstar/common/models/image_request.dart';
import 'package:bookstar/common/theme/style/app_texts.dart';
import 'package:bookstar/gen/assets.gen.dart';
import 'package:bookstar/gen/colors.gen.dart';
import 'package:bookstar/modules/book/model/book_overview_response.dart';
import 'package:bookstar/modules/book_log/view/widgets/select_book_dialog.dart';
import 'package:bookstar/modules/book_log/view_model/book_log_view_model.dart';
import 'package:bookstar/modules/reading_diary/view/widgets/text_input_sheet.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

const int IMAGE_LIMIT = 10;

abstract class ImageItem {
  ImageItem();
}

class UrlImage extends ImageItem {
  final ImageRequest imageRequest;

  UrlImage({required this.imageRequest});
}

class GalleryImage extends ImageItem {
  final Uint8List originBytes;

  GalleryImage({required this.originBytes});
}

class ReadingDiaryEditForm extends BaseScreen {
  const ReadingDiaryEditForm({
    super.key,
    required this.isEdit,
    required this.textController,
    required this.images,
    required this.currentImageIndex,
    required this.focusNode,
    required this.disabledSave,
    required this.selectedBookId,
    required this.privacy,
    required this.onUpdatePrivacy,
    required this.onFocus,
    required this.onUpdateText,
    required this.onUpdateImage,
    required this.onSave,
    required this.onUpdateDisabledSave,
    required this.onPick,
    required this.onImageIndexChanged,
    required this.onUpdateSelectedBookId,
  });

  final bool isEdit;
  final TextEditingController textController;
  final List<ImageItem> images;
  final int currentImageIndex;
  final FocusNode focusNode;
  final bool disabledSave;
  final int? selectedBookId;
  final bool privacy;
  final Function(bool) onUpdatePrivacy;
  final Function(bool) onFocus;
  final Function(String) onUpdateText;
  final Function(List<ImageItem>) onUpdateImage;
  final Function() onSave;
  final Function(bool) onUpdateDisabledSave;
  final Function() onPick;
  final Function(int) onImageIndexChanged;
  final Function(int) onUpdateSelectedBookId;

  @override
  BaseScreenState<BaseScreen> createState() => _ReadingDiaryEditFormState();
}

class _ReadingDiaryEditFormState extends BaseScreenState<ReadingDiaryEditForm> {
  @override
  bool enableRefreshIndicator() => false;

  void _onTabText() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return TextInputSheet(
              initialText: widget.textController.text,
              focusNode: widget.focusNode,
              onTextChanged: widget.onUpdateText,
              onFocus: widget.onFocus,
            );
          },
        );
      },
    ).then((_) {
      setState(
        () {},
      );
    });
  }

  void _onImageIndexChanged(int index) {
    int newIndex = index;
    if (newIndex < 0) newIndex = 0;
    widget.onImageIndexChanged(newIndex);
  }

  void _removeImage(int index) {
    final images = widget.images;
    final totalImageCount = images.length;
    final isLastIndex = index == totalImageCount - 1;
    images.removeAt(index);
    if (isLastIndex) {
      _onImageIndexChanged(index - 1);
    }
    widget.onUpdateImage(images);
  }

  Future<void> _openSelectBookDialog() async {
    final result = await showDialog(
      context: context,
      builder: (context) {
        return SelectBookDialog();
      },
    );
    if (result != null) {
      widget.onUpdateSelectedBookId(result);
    }
  }

  @override
  Widget buildBody(BuildContext context) {
    final isNotEmptyText = widget.textController.text.isNotEmpty;
    final isOver10Texts = widget.textController.text.length >= 10;
    final state = ref.watch(bookLogBookOverviewProvider(widget.selectedBookId));

    return GestureDetector(
      onTap: () {
        widget.onFocus(false);
      },
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _buildImageSection(
                        images: widget.images,
                        onPick: widget.onPick,
                        onRemove: _removeImage,
                        currentImageIndex: widget.currentImageIndex,
                        onImageIndexChanged: _onImageIndexChanged),
                  ),
                  SliverToBoxAdapter(
                    child: _buildDescriptionSection(
                      isNotEmptyText: isNotEmptyText,
                      isOver10Texts: isOver10Texts,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: GestureDetector(
                        onTap: _onTabText,
                        child: SizedBox(
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(),
                            child: isNotEmptyText
                                ? _buildTextSection(
                                    text: widget.textController.text)
                                : _buildEmptyTextSection(),
                          ),
                        )),
                  ),
                ],
              ),
            ),
            _buildRegisterBookButton(
              selectedBookId: widget.selectedBookId,
              bookOverview: state.value,
              onPressed: () {
                if (!widget.isEdit) {
                  _openSelectBookDialog();
                }
              },
            ),
            SizedBox(height: 12),
            _buildPrivacyButton(
              privacy: widget.privacy,
              onPressed: () {
                widget.onUpdatePrivacy(!widget.privacy);
              },
            ),
            _buildSubmitButton(
                disabled: widget.disabledSave ||
                    !isNotEmptyText ||
                    !isOver10Texts ||
                    widget.selectedBookId == null,
                onSave: () async {
                  widget.onUpdateDisabledSave(true);
                  await widget.onSave();
                  widget.onUpdateDisabledSave(false);
                }),
            SizedBox(
              height: 16,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(
      {required List<ImageItem> images,
      required Function() onPick,
      required Function(int) onRemove,
      required int currentImageIndex,
      required Function(int) onImageIndexChanged}) {
    final totalImageLength = images.length;

    if (totalImageLength == 0) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () => onPick(),
              child: Icon(Icons.add_photo_alternate,
                  size: 24, color: ColorName.g1),
            ),
          ],
        ),
      );
    } else {
      return Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () => onPick(),
                        child: const Center(
                          child: Icon(Icons.add_photo_alternate,
                              size: 24, color: ColorName.g1),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Expanded(
                    child: PageView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: totalImageLength,
                      onPageChanged: onImageIndexChanged,
                      itemBuilder: (context, index) {
                        final item = images[index];
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            if (item is UrlImage)
                              _urlImageWidget(item: item)
                            else if (item is GalleryImage)
                              _galleryImageWidget(item: item)
                            else
                              Container(),
                            Positioned(
                                top: 16,
                                right: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      color: ColorName.b1),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 13,
                                      vertical: 7.5,
                                    ),
                                    child: Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () =>
                                              onRemove(currentImageIndex),
                                          child: const Center(
                                            child: Icon(Icons.close,
                                                size: 24, color: ColorName.g1),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 4,
                                        ),
                                        Text("${index + 1}/$totalImageLength"),
                                      ],
                                    ),
                                  ),
                                ))
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              totalImageLength,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: currentImageIndex == index ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: currentImageIndex == index
                      ? ColorName.p1 // 활성화된 인디케이터 색상
                      : ColorName.g7, // 비활성화된 인디케이터 색상
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildDescriptionSection({
    required bool isNotEmptyText,
    required bool isOver10Texts,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: isNotEmptyText && !isOver10Texts
            ? [
                Row(
                  children: [
                    Text("최소 10글자 이상",
                        style: AppTexts.b1.copyWith(color: ColorName.e0)),
                    Text("의", style: AppTexts.b1.copyWith(color: ColorName.w1)),
                  ],
                ),
                Text("감상평을 입력해 주세요.",
                    style: AppTexts.b1.copyWith(color: ColorName.w1)),
              ]
            : [
                Text("책을 덮은 지금,",
                    style: AppTexts.b1.copyWith(color: ColorName.w1)),
                Row(
                  children: [
                    Text("어떤 생각",
                        style: AppTexts.b1.copyWith(color: ColorName.p1)),
                    Text("이 드시나요?",
                        style: AppTexts.b1.copyWith(color: ColorName.w1)),
                  ],
                ),
              ],
      ),
    );
  }

  Widget _buildEmptyTextSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Text(
        '감상평을 입력해 보세요.',
        style: AppTexts.b8.copyWith(
          color: ColorName.g4,
          fontFamily: 'BookkMyungjo',
        ),
      ),
    );
  }

  Widget _buildTextSection({required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Text(
        text,
        style: AppTexts.b8.copyWith(
          color: ColorName.w1,
          fontFamily: 'BookkMyungjo',
        ),
      ),
    );
  }

  Widget _buildRegisterBookButton({
    required int? selectedBookId,
    required BookOverviewResponse? bookOverview,
    required Function() onPressed,
  }) {
    if (selectedBookId == null) {
      return GestureDetector(
        onTap: onPressed,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: ColorName.g7,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ColorName.e0),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                        child: Row(
                      children: [
                        Assets.icons.icBook.svg(),
                        SizedBox(width: 8),
                        Text("읽은 책 등록하기",
                            style: AppTexts.b7.copyWith(color: ColorName.w1)),
                        SizedBox(width: 4),
                        Text("필수*",
                            style: AppTexts.b10.copyWith(color: ColorName.g2)),
                      ],
                    )),
                    Icon(
                      Icons.chevron_right,
                      size: 24,
                      color: ColorName.g3,
                    )
                  ],
                ),
              )),
        ),
      );
    } else if (bookOverview != null) {
      return GestureDetector(
        onTap: onPressed,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: ColorName.g7,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                        child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 78,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: bookOverview.cover,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(
                          width: 12,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 210,
                                  child: Text(bookOverview.title,
                                      style: AppTexts.b5
                                          .copyWith(color: ColorName.w1),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 210,
                                  child: Text(
                                      "${bookOverview.author}・${bookOverview.publisher}",
                                      style: AppTexts.b8
                                          .copyWith(color: ColorName.g2),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1),
                                ),
                              ],
                            )
                          ],
                        )
                      ],
                    )),
                    Icon(
                      Icons.chevron_right,
                      size: 24,
                      color: ColorName.w1,
                    )
                  ],
                ),
              )),
        ),
      );
    } else {
      return SizedBox();
    }
  }

  Widget _buildPrivacyButton({
    required bool privacy,
    required Function() onPressed,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: ColorName.g7,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Assets.icons.icBookSearch.svg(),
                    SizedBox(width: 8),
                    Text("나만 보기",
                        style: AppTexts.b7.copyWith(color: ColorName.g3)),
                  ],
                ),
              ),
              CustomSwitch(
                  value: privacy,
                  onChanged: (_) {
                    onPressed();
                  })
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(
      {required Function() onSave, required bool disabled}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: CtaButtonL1(
        text: '게시하기',
        enabled: !disabled,
        onPressed: onSave,
      ),
    );
  }

  Widget _urlImageWidget({required UrlImage item}) {
    return CachedNetworkImage(
        imageUrl: item.imageRequest.imageUrl,
        fit: BoxFit.contain,
        errorWidget: (context, url, error) => Container());
  }

  Widget _galleryImageWidget({required GalleryImage item}) {
    return Image.memory(
      item.originBytes,
      fit: BoxFit.contain,
    );
  }
}
