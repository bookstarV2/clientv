#!/bin/sh
set -eu

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export COCOAPODS_DISABLE_STATS=true
export HOMEBREW_NO_AUTO_UPDATE=1

: "${CI_PRIMARY_REPOSITORY_PATH:?Run this script in Xcode Cloud}"
: "${CI_BUILD_NUMBER:?Xcode Cloud build number is required}"
: "${BOOKSTAR_API_BASE_URL:?Set the isolated TestFlight HTTPS origin}"

cd "$CI_PRIMARY_REPOSITORY_PATH"
ruby ios/ci_scripts/prepare_config.rb

bookstar_flutter_dir=$(mktemp -d "${TMPDIR:-/tmp}/bookstar-flutter.XXXXXX")
git clone --depth 1 --branch 3.32.6 https://github.com/flutter/flutter.git "$bookstar_flutter_dir/sdk"
export PATH="$bookstar_flutter_dir/sdk/bin:$PATH"
flutter config --no-analytics
flutter precache --ios
flutter pub get --enforce-lockfile
flutter build ios --release --no-codesign --config-only --no-pub \
  --target lib/main.dart \
  --build-number "$CI_BUILD_NUMBER" \
  --dart-define="API_BASE_URL=$BOOKSTAR_API_BASE_URL"

if ! command -v pod >/dev/null 2>&1; then
  brew install cocoapods
fi
cd ios
pod install --deployment
