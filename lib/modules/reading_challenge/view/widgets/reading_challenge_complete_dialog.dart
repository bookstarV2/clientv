import 'package:bookstar/common/components/base_screen.dart';
import 'package:bookstar/common/components/button/cta_button_l1.dart';
import 'package:bookstar/common/theme/style/app_texts.dart';
import 'package:bookstar/gen/assets.gen.dart';
import 'package:bookstar/gen/colors.gen.dart';
import 'package:bookstar/modules/reading_challenge/view_model/challenge_complete_view_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ReadingChallengeCompleteDialog extends BaseScreen {
  const ReadingChallengeCompleteDialog({
    super.key,
    required this.challengeId,
  });

  final int challengeId;
  @override
  BaseScreenState<BaseScreen> createState() =>
      _ReadingChallengeCompleteDialogState();
}

class _ReadingChallengeCompleteDialogState
    extends BaseScreenState<ReadingChallengeCompleteDialog> {
  @override
  bool canPop() {
    return false;
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    final state =
        ref.watch(challengeCompleteViewModelProvider(widget.challengeId));
    return AppBar(
      title: Text("리딩 챌린지"),
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      flexibleSpace: state.maybeWhen(
        data: (data) => Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: CachedNetworkImageProvider(data.detail.bookCover),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  ColorName.b1.withValues(alpha: 0.7),
                  ColorName.b1.withValues(alpha: 0.9),
                ],
              ),
            ),
          ),
        ),
        orElse: () => null,
      ),
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    final state =
        ref.watch(challengeCompleteViewModelProvider(widget.challengeId));
    return state.when(
        data: (data) {
          // data.detail.totalTime(int) to HH:MM:SS
          final totalTime = Duration(seconds: data.detail.totalTime);
          final hours = totalTime.inHours;
          final minutes = totalTime.inMinutes.remainder(60);
          final seconds = totalTime.inSeconds.remainder(60);
          final totalTimeString =
              "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
          // data.detail.bookCover
          return Stack(
            children: [
              // 배경 이미지
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: data.detail.bookCover,
                  fit: BoxFit.cover,
                ),
              ),
              // 어두운 오버레이
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        ColorName.b1.withValues(alpha: 0.85),
                        ColorName.b1.withValues(alpha: 0.95),
                      ],
                    ),
                  ),
                ),
              ),
              // 컨텐츠
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Column(
                  children: [
                    SizedBox(
                      height: 27,
                    ),
                    // Text("그저 하루치의 낙담",
                    Text(data.detail.bookTitle,
                        style: AppTexts.b1.copyWith(color: ColorName.w1)),
                    Text(
                        "${data.detail.bookAuthor}・${data.detail.bookPublisher}",
                        style: AppTexts.b10.copyWith(color: ColorName.g2)),
                  ],
                ),
                Column(
                  children: [
                    Row(
                      spacing: 10,
                      children: [
                        _buildSection(
                          Assets.images.icReadingChallengeChallengeTime.image(),
                          "챌린지 시간",
                          Text(
                            totalTimeString,
                            style: AppTexts.b3.copyWith(color: ColorName.w1),
                          ),
                        ),
                        _buildSection(
                          Assets.images.icReadingChallengeCollectQuiz.image(),
                          "맞춘 퀴즈 수",
                          Text(
                            "${data.detail.totalCollect}개",
                            style: AppTexts.b3.copyWith(color: ColorName.w1),
                          ),
                        ),
                        _buildSection(
                          Assets.images.icReadingChallengeReadingSpeed.image(),
                          "읽는 속도",
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: "장당",
                                  style: AppTexts.b10
                                      .copyWith(color: ColorName.g3),
                                ),
                                TextSpan(
                                  text: "${data.detail.readingSpeedPerMinute}초",
                                  style:
                                      AppTexts.b3.copyWith(color: ColorName.w1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 36),
                    CtaButtonL1(
                      onPressed: () {
                        context.pop(true);
                      },
                      text: "메인으로 이동하기",
                    ),
                    SizedBox(height: 20),
                  ],
                )
                  ],
                ),
              ),
            ],
          );
        },
        error: error(""),
        loading: loading);
  }

  Widget _buildSection(Image icon, String title, Widget child) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18), color: ColorName.dim2),
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 38, height: 38, child: icon),
                  Text(
                    title,
                    style: AppTexts.b6.copyWith(color: ColorName.g2),
                  )
                ],
              ),
              SizedBox(
                height: 16,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
