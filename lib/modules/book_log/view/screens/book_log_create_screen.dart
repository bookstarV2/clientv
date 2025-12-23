import 'dart:io';

import 'package:bookstar/common/components/base_screen.dart';
import 'package:bookstar/common/models/image_request.dart';
import 'package:bookstar/modules/auth/view_model/auth_state.dart';
import 'package:bookstar/modules/auth/view_model/auth_view_model.dart';
import 'package:bookstar/modules/book_log/view/widgets/select_image_dialog.dart';
import 'package:bookstar/modules/book_log/view_model/book_log_view_model.dart';
import 'package:bookstar/modules/reading_challenge/view_model/current_challenge_view_model.dart';
import 'package:bookstar/modules/reading_diary/model/diary_request.dart';
import 'package:bookstar/modules/reading_diary/view/widgets/reading_diary_edit_form.dart';
import 'package:bookstar/modules/reading_diary/view_model/challenge_diaries_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';

class BookLogCreateScreen extends BaseScreen {
  const BookLogCreateScreen({
    super.key,
  });

  @override
  BaseScreenState<BaseScreen> createState() => _BookLogCreateScreenState();
}

class _BookLogCreateScreenState extends BaseScreenState<BookLogCreateScreen> {
  @override
  bool enableRefreshIndicator() => false;
  int? _selectedBookId;
  final TextEditingController _textController = TextEditingController();
  List<ImageItem> _images = [];
  bool _disableSave = false;
  int _currentImageIndex = 0;
  bool _privacy = false;

  void _updateDisableSave(bool value) {
    setState(() {
      _disableSave = value;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openPhotoSelectDialog();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _openPhotoSelectDialog() async {
    final maxCount = MAX_COUNT - _images.length;
    final result = await showDialog(
      context: context,
      builder: (_) {
        return SelectImageDialog(maxCount: maxCount);
      },
    );
    if (result != null) {
      final r = result as List<SelectedImage>;
      setState(() {
        for (final item in r) {
          _images.add(GalleryImage(originBytes: item.originBytes));
        }
      });
    }
  }

  void _onImageIndexChanged(int index) {
    setState(() {
      _currentImageIndex = index;
    });
  }

  void _onUpdateSelectedBookId(int id) {
    setState(() {
      _selectedBookId = id;
    });
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('책로그'),
      leading: IconButton(
        icon: const BackButton(),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    return ReadingDiaryEditForm(
        isEdit: false,
        textController: _textController,
        images: _images,
        currentImageIndex: _currentImageIndex,
        onImageIndexChanged: _onImageIndexChanged,
        focusNode: focusNode,
        disabledSave: _disableSave,
        selectedBookId: _selectedBookId,
        onUpdateSelectedBookId: _onUpdateSelectedBookId,
        privacy: _privacy,
        onUpdatePrivacy: (value) {
          setState(() {
            _privacy = value;
          });
        },
        onUpdateDisabledSave: _updateDisableSave,
        onFocus: (show) {
          if (show) {
            focusNode.requestFocus();
          } else {
            focusNode.unfocus();
          }
        },
        onUpdateText: (text) {
          setState(() {
            _textController.text = text;
          });
        },
        onUpdateImage: (newImages) {
          setState(() {
            _images = [...newImages];
          });
        },
        onSave: () async {
          final List<ImageRequest> imageRequests =
              await Future.wait(_images.asMap().entries.map((entry) async {
            final index = entry.key;
            final item = entry.value;
            if (item is UrlImage) {
              return ImageRequest(
                imageUrl: item.imageRequest.imageUrl,
                sequence: index + 1,
              );
            } else if (item is GalleryImage) {
              // 임시 디렉토리 가져오기 (앱 종료 시 OS가 정리)
              final tempDir = await getTemporaryDirectory();
              final file = File(
                  '${tempDir.path}/bookstar_${DateTime.now().millisecondsSinceEpoch}.png');
              // 바이트 데이터 쓰기
              await file.writeAsBytes(item.originBytes);
              final imageRequest =
                  await ref.read(fileToImageRequestProvider(file).future);
              return ImageRequest(
                imageUrl: imageRequest.imageUrl,
                sequence: index + 1,
              );
            } else {
              throw Exception('Unknown image type');
            }
          }));
          if (_selectedBookId == null) return;

          final diaryRequest = DiaryRequest(
            bookId: _selectedBookId!,
            content: _textController.text,
            images: imageRequests,
            privacy: _privacy,
          );

          await ref.read(bookLogDiaryCreateProvider(diaryRequest).future);

          final authState = ref.read(authViewModelProvider);
          final int? memberId = authState.when(
            data: (data) => (data is AuthSuccess) ? data.memberId : null,
            loading: () => null,
            error: (e, st) => null,
          );
          final challengeId =
              ref.read(currentChallengeViewModelProvider).challengeId;
          if (memberId != null && challengeId != null) {
            ref.invalidate(challengeDiariesViewModelProvider(
              memberId: memberId,
              challengeId: challengeId,
            ));
          }
          if (context.mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go('/my-feed', extra: {
                "requiredRefresh": true,
              });
            });
          }
        },
        onPick: () {
          _openPhotoSelectDialog();
        });
  }
}
