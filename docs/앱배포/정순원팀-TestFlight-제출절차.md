# 정순원 팀 TestFlight 외부 심사 제출

대상: Apple 팀 `sunwon jeong (8V3Q7P756A)` · 앱 `북스타 AI 독서 퀴즈` · 번들 ID `com.sunwon.bookstar` · 릴리스 브랜치 `release/testflight-sunwon`. 기존 `com.company.bookstar` 앱은 다른 팀의 앱이다.

| 순서 | 들어갈 곳 | 할 일 |
| --- | --- | --- |
| 1 | [Apple Developer · Identifiers](https://developer.apple.com/account/resources/identifiers/list) | 팀을 확인하고 Explicit App ID `com.sunwon.bookstar`를 등록한다. Push Notifications와 Sign In with Apple을 켠다. |
| 2 | [App Store Connect · 앱](https://appstoreconnect.apple.com/apps/6818694367/distribution) | iOS 앱 레코드를 만든다. 이름 `북스타 AI 독서 퀴즈`, 기본 언어 한국어, SKU `bookstar-sunwon-2026`, 번들 ID `com.sunwon.bookstar`. |
| 3 | [릴리스 브랜치](https://github.com/bookstarV2/clientv/tree/release/testflight-sunwon) | 팀·번들 ID가 바뀐 브랜치를 push한다. `main`의 기존 앱 배포 설정과 섞지 않는다. |
| 4 | [Xcode Cloud 워크플로](https://appstoreconnect.apple.com/teams/c988ecdf-0406-45d4-a9eb-4a42b7ea625b/xcode-cloud/products/904EC305-B8A0-45ED-81E5-BFAD7DE0ED80/workflows/F8D36573-94DC-4318-AC5E-A42CD5BD9936) | 첫 워크플로는 Xcode에서 `ios/Runner.xcworkspace`로 만든다. 브랜치 변경 시 iOS Archive, App Store Connect 배포 준비, Xcode 26.6을 선택한다. `BOOKSTAR_API_BASE_URL=https://bookstar.trade`를 넣는다. |
| 5 | [Xcode Cloud · 공유 환경 변수](https://appstoreconnect.apple.com/teams/c988ecdf-0406-45d4-a9eb-4a42b7ea625b/xcode-cloud/products/904EC305-B8A0-45ED-81E5-BFAD7DE0ED80/settings/shared-environment-variables) | `BOOKSTAR_IOS_CONFIG_JSON`을 **Secret**으로 넣고 워크플로에 연결한다. [설정 형식](https://github.com/bookstarV2/clientv/blob/release/testflight-sunwon/ios/ci_scripts/prepare_config.rb)에 적힌 네 파일을 경로별 Base64 값으로 담은 JSON이다. `.env`, Firebase, Google OAuth, Kakao iOS 키를 새 번들 ID에 맞춘다. 값을 저장소·문서·로그에 쓰지 않는다. |
| 6 | [Kakao Developers · BookStar 플랫폼 키](https://developers.kakao.com/console/app/1292181/config/platform-key) | 앱에서 실제 사용하는 네이티브 앱 키의 iOS 번들 ID를 `com.sunwon.bookstar`로 등록한다. 5번 설정의 키와 앱의 URL 스킴도 같은 키인지 확인한다. 기존 빌드가 예전 키를 쓰면 그 키에도 번들 ID를 등록한다. |
| 7 | [Firebase · BookStar 앱 설정](https://console.firebase.google.com/u/2/project/bookstar-32737/settings/general) | `bookstar816@gmail.com`으로 새 Apple 앱 `com.sunwon.bookstar`를 등록하고 `GoogleService-Info.plist`를 받아 5번 설정의 Firebase·Google OAuth 값에 반영한다. 푸시가 필요하면 새 Apple 팀의 APNs 키도 Firebase에 등록한다. |
| 8 | [Xcode Cloud · 빌드](https://appstoreconnect.apple.com/teams/c988ecdf-0406-45d4-a9eb-4a42b7ea625b/xcode-cloud/products/904EC305-B8A0-45ED-81E5-BFAD7DE0ED80/builds) | [빌드 번호](https://appstoreconnect.apple.com/teams/c988ecdf-0406-45d4-a9eb-4a42b7ea625b/xcode-cloud/products/904EC305-B8A0-45ED-81E5-BFAD7DE0ED80/settings/build-number)를 `406` 이상으로 두고 릴리스 브랜치를 push하거나 수동 시작한다. App Store Connect 배포 준비까지 성공하고 [TestFlight iOS 빌드](https://appstoreconnect.apple.com/teams/c988ecdf-0406-45d4-a9eb-4a42b7ea625b/apps/6818694367/testflight/ios)에 나타나는지 확인한다. 개발용·Ad Hoc 프로파일 오류가 나면 [테스트 기기](https://developer.apple.com/account/resources/devices/list)를 등록하고 다시 빌드한다. |
| 9 | [TestFlight · 테스트 정보](https://appstoreconnect.apple.com/teams/c988ecdf-0406-45d4-a9eb-4a42b7ea625b/apps/6818694367/testflight/test-info) | 베타 설명, 피드백 이메일, 심사 연락처, 심사자가 Apple ID로 로그인하는 방법을 저장한다. 빌드의 ‘테스트할 내용’에는 주요 화면과 퀴즈·복습 흐름을 적는다. |
| 10 | [TestFlight · 그룹](https://appstoreconnect.apple.com/teams/c988ecdf-0406-45d4-a9eb-4a42b7ea625b/apps/6818694367/testflight) | 내부 그룹을 먼저 만들고 [외부 베타 그룹](https://appstoreconnect.apple.com/teams/c988ecdf-0406-45d4-a9eb-4a42b7ea625b/apps/6818694367/testflight/groups/3ac0ab13-eced-4c07-b9a9-7fac06b4c85a)에 빌드와 테스터 이메일을 추가한다. **심사를 위해 제출**을 누르고 빌드가 `심사 대기 중`인지 확인한다. 심사가 통과되면 테스터의 초대·설치 상태를 확인한다. |

2026-10-03 진행 결과: `1.0.17 (408)` 빌드를 외부 베타 심사에 제출했고, 현재 `심사 대기 중`이다. 외부 테스터 1명을 그룹에 등록했다. 승인 전에는 테스터 목록에 `사용할 수 있는 빌드 없음`으로 표시된다.

서버 운영 설정의 Apple 로그인 audience에는 `com.sunwon.bookstar`가 포함되어 있어야 한다. 현재 기존 앱과 새 앱의 두 번들 ID가 설정돼 있다. 계정 삭제 시 Apple refresh token이 없어 실패할 수 있는 기존 서버 문제가 있으므로, 심사 전에 별도로 확인한다.

2026-10-05 로그인 확인: 구형 시뮬레이터 빌드 `1.0.17 (402)`는 예전 카카오 네이티브 앱 키를 사용했고, 그 키의 iOS 번들 ID가 `com.company.bookstar`여서 카카오 로그인에 `IOS bundleId validation failed`가 발생했다. `com.sunwon.bookstar`로 수정한 뒤 카카오 로그인과 내 서재 데이터 표시를 확인했다.

## App Store 정식 심사

TestFlight **외부 베타 심사**와 App Store **정식 앱 심사**는 별개다. 정식 심사에는 아래 순서로 진행한다.

| 순서 | 들어갈 곳 | 할 일 |
| --- | --- | --- |
| 11 | [App Store Connect · iOS 버전](https://appstoreconnect.apple.com/apps/6818694367/distribution/ios/version/inflight) | 업로드된 빌드의 앱 버전과 스토어 버전을 맞추고 빌드를 선택한다. `1.0.17 (410)`을 선택할 경우 스토어 버전도 `1.0.17`이어야 한다. |
| 12 | 같은 화면의 `미리보기 및 스크린샷` | iPhone 6.5형에 [실제 앱 캡처 4장](북스타-AppStore-스크린샷)을 순서대로 올린다. 각 이미지 크기는 `1284×2778` PNG다. 스크린샷은 시뮬레이터에서 앱을 열고 `xcrun simctl io <기기 UUID> screenshot <파일.png>`로 다시 만들 수 있다. |
| 13 | 같은 화면의 앱 설명 및 왼쪽 `앱 정보`, `앱 심사`, [`앱이 수집하는 개인정보`](https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy), `앱의 손쉬운 사용` | 설명·키워드·지원 URL·저작권·카테고리·연령 등급·공개 개인정보 처리방침 URL·데이터 수집 정보·심사 연락처를 실제 앱 동작에 맞게 입력한다. 계정 기능의 심사를 위해 [활성 데모 계정 또는 전체 기능 데모 모드](https://developer.apple.com/app-store/review/guidelines/)를 제공한다. |
| 14 | [App Store Connect · iOS 버전](https://appstoreconnect.apple.com/apps/6818694367/distribution/ios/version/inflight) | `저장` → `심사에 추가` → 제출 항목을 확인하고 `앱 심사에 제출`을 누른다. 제출 후 버전 상태가 `심사 대기 중`인지 확인한다. |

2026-10-04 현재 정식 App Store 심사는 아직 제출되지 않았다. 6.5형 스크린샷 4장은 준비됐고, App Store Connect 재로그인 후 업로드 완료 여부를 확인해야 한다. 스토어 버전은 `1.0.17`로 바꾸고 심사 승인 후 **수동 출시**를 선택했다. 공개 개인정보 처리방침 URL과 심사용 계정 정보도 확인이 필요하다.
