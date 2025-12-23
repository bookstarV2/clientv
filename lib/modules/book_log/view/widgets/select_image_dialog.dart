import 'dart:typed_data';

import 'package:bookstar/common/components/base_screen.dart';
import 'package:bookstar/common/theme/style/app_texts.dart';
import 'package:bookstar/gen/colors.gen.dart';
import 'package:bookstar/modules/book_log/view/widgets/gallery_permission_request_dialog.dart';
import 'package:bookstar/modules/book_log/view/widgets/thumbnail_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class SelectedImage {
  final Uint8List thumbnailData;
  final Uint8List originBytes;
  final String id;
  const SelectedImage({
    required this.thumbnailData,
    required this.originBytes,
    required this.id,
  });
}

const int PAGE_SIZE = 100;
const int MAX_COUNT = 10;

class SelectImageDialog extends BaseScreen {
  const SelectImageDialog({
    super.key,
    required this.maxCount,
  });
  final int maxCount;

  @override
  BaseScreenState<BaseScreen> createState() => _SelectImageDialogState();
}

class _SelectImageDialogState extends BaseScreenState<SelectImageDialog> {
  @override
  bool enableRefreshIndicator() => false;
  List<AssetPathEntity> _albums = [];
  int _selectedAlbumIndex = 0;
  int _currentPage = 0;
  List<AssetEntity> _images = [];
  List<SelectedImage> _selectedImages = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final result = await _requestPermission();
      if (result) {
        await _initAlbums();
        await _initImages();
      }
    });
  }

  Future<bool> _requestPermission() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (ps.hasAccess) {
      return true;
    } else if (!ps.hasAccess && mounted) {
      final response = await showModalBottomSheet(
          context: context,
          constraints: BoxConstraints.tight(Size.fromHeight(300)),
          builder: (_) {
            return GalleryPermissionRequestDialog();
          });

      if (response["result"]) {
        // パーミッションが拒否された場合の処理
        // 端末のアプリ権限を開く
        await PhotoManager.openSetting();
      } else {
        Navigator.pop(context);
      }
    }
    return false;
  }

  Future<void> _initAlbums() async {
    List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      onlyAll: true,
      type: RequestType.image,
    );
    setState(() {
      _albums = albums;
    });
  }

  Future<void> _initImages() async {
    List<AssetEntity> images = await _albums[_selectedAlbumIndex]
        .getAssetListPaged(page: _currentPage, size: PAGE_SIZE);
    setState(() {
      _images = images;
    });
  }

  @override
  void onScrollDown(double offset) async {
    setState(() {
      _currentPage++;
    });
    List<AssetEntity> images = await _albums[_selectedAlbumIndex]
        .getAssetListPaged(page: _currentPage, size: PAGE_SIZE);
    setState(() {
      _images.addAll(images);
    });
  }

  Future<void> _onTapImage(AssetEntity image, bool isSelected) async {
    if (isSelected) {
      setState(() {
        _selectedImages.removeWhere((x) => x.id == image.id);
      });
    } else {
      final thumbnailData = await image.thumbnailData;
      final originBytes = await image.originBytes;
      if (thumbnailData == null || originBytes == null) {
        return;
      }
      if (_selectedImages.length >= widget.maxCount) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("최대 ${widget.maxCount}장까지만 선택할 수 있습니다.")),
        );
        return;
      }
      setState(() {
        _selectedImages.add(
          SelectedImage(
            thumbnailData: thumbnailData,
            originBytes: originBytes,
            id: image.id,
          ),
        );
      });
    }
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('책로그'),
      automaticallyImplyLeading: false,
      actions: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(_selectedImages),
          child: Text("완료", style: AppTexts.b8.copyWith(color: ColorName.g1)),
        ),
        SizedBox(width: 16),
      ],
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageContainerSize =
        screenWidth - 32; // Account for horizontal padding

    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              SizedBox(
                  width: imageContainerSize,
                  height: imageContainerSize,
                  child: _selectedImages.isNotEmpty
                      ? PageView.builder(
                          itemCount: _selectedImages.length,
                          itemBuilder: (context, index) {
                            final image = _selectedImages[index];
                            return Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.memory(image.originBytes,
                                    fit: BoxFit.cover),
                                Positioned(
                                    top: 16,
                                    right: 16,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          color: ColorName.b1),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 13,
                                          vertical: 7.5,
                                        ),
                                        child: Text(
                                            "${index + 1}/${_selectedImages.length}"),
                                      ),
                                    ))
                              ],
                            );
                          },
                        )
                      : null),
              SizedBox(height: 12),
              _albums.isNotEmpty
                  ? PopupMenuButton<int>(
                      color: ColorName.dim3.withValues(alpha: 0.7),
                      offset: Offset(0, 25),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_albums[_selectedAlbumIndex].name),
                          Icon(Icons.arrow_drop_down),
                        ],
                      ),
                      onSelected: (int index) {
                        if (_selectedAlbumIndex != index) {
                          setState(() {
                            _selectedAlbumIndex = index;
                            _currentPage = 0;
                          });
                          _initImages();
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return _albums.asMap().entries.map((entry) {
                          int index = entry.key;
                          AssetPathEntity album = entry.value;
                          return PopupMenuItem<int>(
                            height: 32,
                            value: index,
                            child: Text(album.name),
                          );
                        }).toList();
                      },
                    )
                  : SizedBox.shrink(),
              SizedBox(height: 12),
              _images.isEmpty
                  ? SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()))
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 4.0,
                        mainAxisSpacing: 4.0,
                      ),
                      itemCount: _images.length,
                      itemBuilder: (context, index) {
                        final image = _images[index];
                        bool isSelected = false;
                        for (SelectedImage selectedImage in _selectedImages) {
                          if (selectedImage.id == image.id) {
                            isSelected = true;
                            break;
                          }
                        }
                        return ThumbnailImage(
                          image: image,
                          isSelected: isSelected,
                          onTap: () => _onTapImage(image, isSelected),
                        );
                      },
                    ),
            ]),
          ),
        ),
      ],
    );
  }
}
