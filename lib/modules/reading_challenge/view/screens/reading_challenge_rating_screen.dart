import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/components/button/cta_button_l1.dart';
import '../../../../common/components/button/cta_button_l2.dart';
import '../../../../common/theme/app_style.dart';
import '../../../../gen/colors.gen.dart';
import '../../../../gen/assets.gen.dart';
import '../../../book_pick/model/search_book_response.dart';
import '../../view_model/current_challenge_view_model.dart';
import '../../view_model/reading_challenge_rating_view_model.dart';
import '../widgets/challenge_book_info_widget.dart';
import '../widgets/step_progress_indicator.dart';

class ReadingChallengeRatingScreen extends ConsumerWidget {
  const ReadingChallengeRatingScreen({
    super.key,
    required this.book,
  });

  final SearchBookResponse book;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel =
        ref.read(readingChallengeRatingViewModelProvider.notifier);
    final state = ref.watch(readingChallengeRatingViewModelProvider);

    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context, ref, viewModel, state),
      bottomNavigationBar: _buildBottomNavigationBar(context, ref),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text("리딩 챌린지"),
      leading: BackButton(onPressed: context.pop),
      actions: [
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/reading-challenge'),
        ),
      ],
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    ReadingChallengeRatingViewModel viewModel,
    ReadingChallengeRatingState state,
  ) {
    return Padding(
      padding: AppPaddings.SCREEN_BODY_PADDING,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ChallengeBookInfoWidget(book: book),
          const SizedBox(height: 16),
          const StepProgressIndicator(
            totalSteps: 3,
            currentStep: 2,
          ),
          const SizedBox(height: 40),
          _buildRatingSection(viewModel, state),
        ],
      ),
    );
  }

  Widget _buildRatingSection(
    ReadingChallengeRatingViewModel viewModel,
    ReadingChallengeRatingState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '해당 도서를 읽은 별점 후기를 남겨보세요',
          style: AppTexts.b10.copyWith(color: ColorName.p1),
        ),
        const SizedBox(height: 20),
        _buildRatingBar(viewModel, state),
      ],
    );
  }

  Widget _buildRatingBar(
    ReadingChallengeRatingViewModel viewModel,
    ReadingChallengeRatingState state,
  ) {
    return RatingBar(
      initialRating: state.rating,
      minRating: 0.0,
      direction: Axis.horizontal,
      allowHalfRating: true,
      itemCount: 5,
      itemPadding: const EdgeInsets.symmetric(horizontal: 3.41),
      ratingWidget: _buildRatingWidget(),
      onRatingUpdate: viewModel.setRating,
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 54),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSaveButton(context, ref),
          const SizedBox(height: 8),
          _buildSkipButton(context, ref),
        ],
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context, WidgetRef ref) {
    final viewModel =
        ref.read(readingChallengeRatingViewModelProvider.notifier);
    final state = ref.watch(readingChallengeRatingViewModelProvider);

    return CtaButtonL1(
      text: '저장하기',
      enabled: viewModel.isButtonEnabled,
      analyticsEventName: 'click_save_rating',
      analyticsEventParams: {
        'screen_name': 'reading_challenge_rating',
        'rating': state.rating,
      },
      onPressed: () => _handleSaveButton(context, ref, state),
    );
  }

  Widget _buildSkipButton(BuildContext context, WidgetRef ref) {
    return CtaButtonL2(
      text: '나중에 남기기',
      analyticsEventName: 'click_skip_rating',
      analyticsEventParams: const {
        'screen_name': 'reading_challenge_rating',
      },
      onPressed: () => _handleSkipButton(context, ref),
    );
  }

  Future<void> _handleSaveButton(
    BuildContext context,
    WidgetRef ref,
    ReadingChallengeRatingState state,
  ) async {
    try {
      await ref
          .read(currentChallengeViewModelProvider.notifier)
          .saveBookRating(state.rating, ref);

      if (context.mounted) {
        context.push(
          '/reading-challenge/diary-encourage',
          extra: {
            'isChallengeCompleted': true,
            'bookId': book.bookId,
          },
        );
      }
    } catch (e) {
      debugPrint('Failed to save book rating: $e');
    }
  }

  Future<void> _handleSkipButton(BuildContext context, WidgetRef ref) async {
    if (context.mounted) {
      context.push(
        '/reading-challenge/diary-encourage',
        extra: {
          'isChallengeCompleted': true,
          'bookId': book.bookId,
        },
      );
    }
  }

  RatingWidget _buildRatingWidget() {
    return RatingWidget(
      full: _buildStarIcon(ColorName.p3),
      half: _buildStarIcon(ColorName.p3),
      empty: _buildStarIcon(ColorName.g3),
    );
  }

  Widget _buildStarIcon(Color color) {
    final isFilled = color == ColorName.p3;
    final icon =
        isFilled ? Assets.icons.icRatingStarFilled : Assets.icons.icRatingStar;

    return Center(
      child: icon.svg(
        width: 45.41427230834961,
        height: 43.522010803222656,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      ),
    );
  }

  // Widget _buildHalfStar() {
  //   return Stack(
  //     children: [
  //       _buildStarIcon(ColorName.g3),
  //       ClipRect(
  //         child: Align(
  //           alignment: Alignment.centerLeft,
  //           widthFactor: 0.5,
  //           child: _buildStarIcon(ColorName.p3),
  //         ),
  //       ),
  //     ],
  //   );
  // }
}
