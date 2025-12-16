import 'package:flutter/cupertino.dart';

import '../../../gen/assets.gen.dart';

enum HomeBottomNavMenu {
  bookPick,
  readingData,
  readingChallenge,
  bookLog,
  myFeed;

  String get label {
    switch (this) {
      case HomeBottomNavMenu.bookPick:
        return '책픽';
      case HomeBottomNavMenu.readingData:
        return '리딩 데이터';
      case HomeBottomNavMenu.readingChallenge:
        return '리딩 챌린지';
      case HomeBottomNavMenu.bookLog:
        return '책로그';
      case HomeBottomNavMenu.myFeed:
        return '마이피드';
    }
  }

  Widget get icon {
    switch (this) {
      case HomeBottomNavMenu.bookPick:
        return Assets.images.navBookPickUnselected3x.image(scale: 3);
      case HomeBottomNavMenu.readingData:
        return Assets.images.navReadingDataUnselected3x.image(scale: 3);
      case HomeBottomNavMenu.readingChallenge:
        return Assets.images.navReadingChallengeUnselected3x.image(scale: 3);
      case HomeBottomNavMenu.bookLog:
        return Assets.images.navBookLogUnselected3x.image(scale: 3);
      case HomeBottomNavMenu.myFeed:
        return Assets.images.navMyFeedUnselected3x.image(scale: 3);
    }
  }

  Widget get activeIcon {
    switch (this) {
      case HomeBottomNavMenu.bookPick:
        return Assets.images.navBookPickSelected3x.image(scale: 3);
      case HomeBottomNavMenu.readingData:
        return Assets.images.navReadingDataSelected3x.image(scale: 3);
      case HomeBottomNavMenu.readingChallenge:
        return Assets.images.navReadingChallengeSelected3x.image(scale: 3);
      case HomeBottomNavMenu.bookLog:
        return Assets.images.navBookLogSelected3x.image(scale: 3);
      case HomeBottomNavMenu.myFeed:
        return Assets.images.navMyFeedSelected3x.image(scale: 3);
    }
  }
}
