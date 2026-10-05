# 북스타 App Store 정식 심사 직접 제출

대상은 Apple 팀 **sunwon jeong (8V3Q7P756A)**, 앱 **북스타 AI 독서 퀴즈** (Apple ID `6818694367`, 번들 ID `com.sunwon.bookstar`)이다. TestFlight 외부 베타와 App Store 정식 심사는 별개다. 2026-10-05 기준 `1.0.17 (413)`은 [외부 베타 그룹](https://appstoreconnect.apple.com/teams/c988ecdf-0406-45d4-a9eb-4a42b7ea625b/apps/6818694367/testflight/groups/3ac0ab13-eced-4c07-b9a9-7fac06b4c85a/builds)에서 **테스트 중**이다. App Store 정식 심사는 **아직 제출되지 않았다**.

## 이미 저장한 것

- [iOS 버전 1.0.17](https://appstoreconnect.apple.com/apps/6818694367/distribution/ios/version/inflight)에 빌드 **413**을 연결하고, iPhone 6.5형 스크린샷 7장을 올렸다. 첫 세 장은 로그인 → 문장 읽기 → 퀴즈 순이다.
- 앱 설명, 키워드, 지원 URL, 저작권, 심사 연락처 이름·성·이메일, 심사 메모를 저장했다. 심사 후 **수동 출시**를 선택했다.
- 왼쪽 **앱 정보**에서 기본 카테고리 **도서**와 콘텐츠 권한을 저장했다. 타사 도서 데이터를 표시하므로 콘텐츠 권한은 **예**로 설정했다.
- [앱이 수집하는 개인정보](https://appstoreconnect.apple.com/apps/6818694367/distribution/privacy)에 공개 [개인정보 처리방침](https://github.com/bookstarV2/clientv/blob/main/docs/%EA%B0%9C%EC%9D%B8%EC%A0%95%EB%B3%B4-%EC%B2%98%EB%A6%AC%EB%B0%A9%EC%B9%A8.md) URL과 데이터 수집 **예**를 저장했다. 데이터 유형 9개를 선택했지만 각 유형의 세부 설정과 **게시**는 아직 끝나지 않았다.

## 직접 마무리할 순서

| 순서 | 화면과 위치 | 입력하거나 누를 것 |
| --- | --- | --- |
| 1 | [iOS 버전 1.0.17](https://appstoreconnect.apple.com/apps/6818694367/distribution/ios/version/inflight) → `미리보기 및 스크린샷` → **iPad** 탭 → `13 iPad 디스플레이` | [08-ipad-login.png](북스타-AppStore-스크린샷/08-ipad-login.png)를 올리고 저장한다. 실제 13형 iPad Pro 캡처이며 `2064×2752` PNG다. 앱이 iPad 중앙에 세로로 표시되어 좌우 여백이 보인다. |
| 2 | 같은 페이지 → `앱 심사 정보` | 연락처 **전화번호**에 본인 번호를 `+82...` 형식으로 입력한다. `로그인 필요`가 켜져 있으므로 전체 기능을 확인할 **심사용 계정 ID·비밀번호**를 넣거나, Apple 심사자가 로그인할 수 있는 별도 전체 기능 데모 방법을 준비한다. 현재 ID·비밀번호는 비어 있다. |
| 3 | 왼쪽 **앱 정보** → `연령 등급 설정` | 현재 미설정이다. 앱 내 제어와 제공 기능, 콘텐츠 빈도 질문에 **현행 UI v2** 기준으로 답하고 완료한다. 현행 UI에는 자유 웹 탐색·소셜 피드·광고가 없으며 책 검색·AI 퀴즈가 있다. |
| 4 | [앱이 수집하는 개인정보](https://appstoreconnect.apple.com/apps/6818694367/distribution/privacy) → 각 데이터 유형 카드의 파란 `설정` | 데이터 유형마다 사용 목적, 사용자와 연결 여부, 추적 여부를 답한다. 완료되면 우측 위 **게시**를 누른다. 아래 `개인정보 유형 확인`을 먼저 읽는다. |
| 5 | [iOS 버전 1.0.17](https://appstoreconnect.apple.com/apps/6818694367/distribution/ios/version/inflight) → 우측 위 `심사에 추가` | 누른 뒤 표시되는 누락 항목을 모두 채운다. |
| 6 | 왼쪽 **앱 심사** | 제출 항목에서 버전 **1.0.17 / 빌드 413**을 확인하고 **앱 심사에 제출**을 누른다. 이후 상태가 **심사 대기 중**인지 확인한다. |

### 개인정보 유형 확인

현재 선택된 유형은 **이메일 주소, 이름, 사진 또는 비디오, 기타 사용자 콘텐츠, 검색 기록, 사용자 ID, 기기 ID, 제품 상호 작용, 기타 사용 데이터**다. 현행 UI v2의 [라우터](https://github.com/bookstarV2/clientv/blob/release/testflight-sunwon/lib/common/router/router.dart)는 이전 사진 업로드·소셜 화면을 열지 않는다. **사진 또는 비디오**는 현행 버전에서 실제 업로드가 가능한지 확인하고 불가능하면 `데이터 유형 → 편집`에서 해제한다. **기타 사용자 콘텐츠**도 자유 입력·업로드가 실제 가능한지 확인한다. 책 검색은 서버 API를 사용하고, 퀴즈 응답은 서버에 저장되며, Firebase Analytics는 화면·클릭 이벤트를 전송한다.

실제로 수집하는 유형의 목적은 로그인·서재·퀴즈·알림 데이터라면 **앱 기능**, 화면·클릭 이벤트라면 **분석**을 선택한다. 계정 및 퀴즈 데이터는 사용자와 연결된다. 현재 코드에는 광고 SDK나 `FirebaseAnalytics.setUserId` 호출이 없지만, SDK·서버에서 다른 목적으로 사용하는 데이터가 없는지는 운영자가 확인해야 한다. 확인하지 않은 항목을 임의로 **추적 안 함** 또는 **사용자와 연결 안 됨**으로 확정하지 않는다.

### 이미 입력된 문구 확인용

| 필드 | 값 |
| --- | --- |
| 설명 | 북스타는 읽은 책을 오래 기억하도록 돕는 독서 앱입니다. 책을 내 서재에 담고 목차별 AI 퀴즈를 풀어보세요. 틀린 문제는 복습하고, 독서 지도에서 책과 퀴즈로 쌓인 생각을 한눈에 살펴볼 수 있습니다. 로그인 없이 한 문제를 먼저 체험할 수도 있습니다. |
| 키워드 | `독서,책,AI퀴즈,책퀴즈,복습,독서지도,독서습관,독서기록,내서재` |
| 지원 URL | https://github.com/bookstarV2/clientv/issues |
| 저작권 | `2026 sunwon jeong` |
| 심사 연락처 | 이름 `순원`, 성 `정`, 이메일 `bookstar816@gmail.com`, **전화번호 미입력** |
| 심사 메모 | 로그인 화면에서 로그인 없이 한 문제 풀어보기로 비회원 체험을 할 수 있습니다. 전체 기능은 Apple로 시작하기를 사용해 심사자의 Apple ID로 가입한 뒤 확인해 주세요. 내 서재에서 책을 추가하고 AI 퀴즈, 복습, 독서 지도 탭을 확인할 수 있습니다. 문의: bookstar816@gmail.com |
| 개인정보 처리방침 URL | https://github.com/bookstarV2/clientv/blob/main/docs/%EA%B0%9C%EC%9D%B8%EC%A0%95%EB%B3%B4-%EC%B2%98%EB%A6%AC%EB%B0%A9%EC%B9%A8.md |

**심사 메모는 심사용 계정을 마련한 뒤 로그인 방법에 맞게 수정한다.** 비회원 체험은 한 문제만 제공하므로 전체 기능 데모를 대신하지 않는다. [Apple의 제출 안내](https://developer.apple.com/help/app-store-connect/manage-submissions-to-app-review/submit-an-app/)에 따라 `심사에 추가`와 `앱 심사에 제출`을 모두 해야 한다.

## 스크린샷 파일

[iPhone 6.5형 파일 7장과 iPad 13형 파일 1장](북스타-AppStore-스크린샷). iPhone 파일은 모두 `1284×2778` PNG이고 이미 업로드됐다. iPad 파일은 아직 업로드되지 않았다.
