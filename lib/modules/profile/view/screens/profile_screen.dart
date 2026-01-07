import 'dart:io';

import 'package:bookstar/common/service/analytics_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import "package:image_picker/image_picker.dart";

import '../../../../common/theme/style/app_texts.dart';
import '../../../../common/components/button/cta_button_l1.dart';
import '../../../../common/components/modal/photo_source_modal.dart';
import '../../../../gen/colors.gen.dart';
import '../../../auth/view_model/auth_state.dart';
import '../../../auth/view_model/auth_view_model.dart';
import '../../../book_log/view_model/book_log_view_model.dart';
import '../../../image/repository/image_repository.dart';
import '../../../image/repository/s3_repository.dart';
import '../../../image/model/presigned_url_request.dart';
import '../../model/update_profile_request.dart';
import '../../repository/profile_repository.dart';
import '../../view_model/profile_view_model.dart';
import '../widgets/profile_name_and_introduction_field.dart';
import '../widgets/profile_image_section.dart';

void invalidateMyProfileProviders(WidgetRef ref, int myMemberId) {
  ref.invalidate(profileProvider(null));
  ref.invalidate(profileProvider(myMemberId));
  ref.invalidate(bookLogProfileProvider(myMemberId));
}

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late TextEditingController _nicknameController;
  late TextEditingController _introductionController;

  String? _originalNickname;
  String? _originalIntroduction;
  bool _isEdited = false;

  String? _localProfileImageUrl; // for preview and upload
  XFile? _pickedImageFile; // for upload

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController();
    _introductionController = TextEditingController();
    _nicknameController.addListener(_onEdit);
    _introductionController.addListener(_onEdit);
  }

  void _onEdit() {
    setState(() {
      _isEdited =
          (_nicknameController.text.trim() != (_originalNickname ?? '')) ||
              (_introductionController.text.trim() !=
                  (_originalIntroduction ?? '')) ||
              (_localProfileImageUrl != null); // image changed
    });
  }

  Future<void> _onTapProfileImage() async {
    AnalyticsService.logEvent('click_profile_image',
        parameters: {'screen_name': 'profile_edit'});
    await PhotoSourceModal.show(
      context,
      onPick: (source) async {
        final picker = ImagePicker();
        final XFile? picked =
            await picker.pickImage(source: source, imageQuality: 90);
        if (picked != null) {
          setState(() {
            _pickedImageFile = picked;
            _localProfileImageUrl = picked.path; // local preview
            _onEdit();
          });
        }
      },
    );
  }

  Future<String?> _uploadProfileImage(XFile file) async {
    final imageRepo = ref.read(imageRepositoryProvider);
    final s3Repo = ref.read(s3RepositoryProvider);
    final fileName = file.name;
    final presigned = await imageRepo.getPresignedUrl(
        'MEMBER_PROFILE', PresignedUrlRequest(fileName: fileName));
    final presignedData = presigned.data;
    await s3Repo.uploadFileToS3(
        presignedUrl: presignedData.presignedUrl, file: File(file.path));
    return presignedData.imageUrl;
  }

  @override
  void dispose() {
    _nicknameController.removeListener(_onEdit);
    _introductionController.removeListener(_onEdit);
    _nicknameController.dispose();
    _introductionController.dispose();
    super.dispose();
  }

  void _onSaveProfile(
      WidgetRef ref, BuildContext context, AsyncValue profileAsync) async {
    final nickname = _nicknameController.text.trim();
    final introduction = _introductionController.text.trim();
    if (nickname.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('닉네임을 입력해주세요.')),
      );
      return;
    }
    final profile = profileAsync.value;
    if (profile == null) return;
    String imageUrl = profile.profileImageUrl;
    if (_pickedImageFile != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
      try {
        final uploadedUrl = await _uploadProfileImage(_pickedImageFile!);
        imageUrl = uploadedUrl ?? imageUrl;
      } catch (e) {
        if (!context.mounted) return;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미지 업로드 실패: $e')),
        );
        return;
      }
      if (!context.mounted) return;
      Navigator.of(context).pop();
    }
    final request = UpdateProfileRequest(
      nickName: nickname,
      profileImageUrl: imageUrl,
      introduction: introduction,
    );
    final repository = ref.read(profileRepositoryProvider);
    try {
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
      await repository.updateMyProfile(request);
      if (context.mounted) {
        final authState = ref.read(authViewModelProvider).value;
        final myMemberId =
            (authState is AuthSuccess) ? authState.memberId : null;
        if (myMemberId != null) {
          invalidateMyProfileProviders(ref, myMemberId);
        } else {
          ref.invalidate(profileProvider(null));
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('프로필이 저장되었습니다.')),
        );

        if (myMemberId != null) {
          ref.read(bookLogViewModelProvider(myMemberId).notifier).initState(myMemberId);
        }
        context.pop();
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 실패: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider(null));
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필 편집'),
        titleTextStyle: AppTexts.b5.copyWith(color: ColorName.w1),
        leading: IconButton(
          icon: const BackButton(),
          onPressed: () => context.pop(),
        ),
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('에러 발생: $e')),
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('프로필 정보가 없습니다.'));
          }
          if (_originalNickname != profile.nickName ||
              _originalIntroduction != profile.introduction) {
            _originalNickname = profile.nickName;
            _originalIntroduction = profile.introduction;
            _nicknameController.text = profile.nickName;
            _introductionController.text = profile.introduction;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() => _isEdited = false);
            });
          }
          final displayImageUrl =
              _localProfileImageUrl ?? profile.profileImageUrl;
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  ProfileImageSection(
                    imageUrl: displayImageUrl,
                    onTap: _onTapProfileImage,
                  ),
                  const SizedBox(height: 24),
                  ProfileNameAndIntroductionField(
                    nicknameController: _nicknameController,
                    introductionController: _introductionController,
                  ),
                  const Spacer(),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 54),
        child: CtaButtonL1(
          text: '저장하기',
          enabled: _isEdited,
          analyticsEventName: 'click_save_profile',
          analyticsEventParams: const {
            'screen_name': 'profile_edit',
          },
          onPressed: () => _onSaveProfile(ref, context, profileAsync),
        ),
      ),
    );
  }
}
