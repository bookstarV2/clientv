import 'package:bookstar/modules/learning/view/learning_design.dart';
import 'package:bookstar/modules/auth/model/policy.dart';
import 'package:flutter/material.dart' hide IconAlignment;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PolicyDetailScreen extends ConsumerWidget {
  const PolicyDetailScreen({super.key, required this.policyType});

  final PolicyType policyType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LearningPage(
      title: getTitle(policyType),
      child: getTargetWidget(policyType: policyType),
    );
  }

  String getTitle(PolicyType type) {
    switch (type) {
      case PolicyType.serviceUsing:
        return '서비스 이용약관';
      case PolicyType.personalInformation:
        return '개인정보 수집 및 이용';
      case PolicyType.marketing:
        return '마케팅 정보 수신 동의';
    }
  }

  Widget getTargetWidget({required PolicyType policyType}) {
    switch (policyType) {
      case PolicyType.serviceUsing:
        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Text(
            '''북스타(Bookstar) 서비스 이용 약관

제1조 (목적)
본 약관은 북스타(Bookstar) 팀(이하 "회사")가 제공하는 독서 습관 형성 플랫폼 '북스타' 및 관련 제반 서비스(이하 "서비스")의 이용과 관련하여 회사와 회원 간의 권리, 의무 및 책임사항, 기타 필요한 사항을 규정함을 목적으로 합니다.

제2조 (용어의 정의)
"서비스"라 함은 회사가 제공하는 북스타 앱의 모든 기능과 데이터를 의미하며, 여기에는 회원의 독서 활동을 기록하고 공유하는 '독서 일지', 집중 독서를 위한 '딥타임 타이머', 다른 회원의 활동을 구독하는 소셜 기능 등이 포함됩니다.

"회원"이라 함은 서비스에 접속하여 본 약관에 따라 회사와 이용계약을 체결하고 회사가 제공하는 서비스를 이용하는 고객을 말합니다.

"게시물"이라 함은 회원이 서비스 상에 게시한 독서 일지, 사진, 텍스트, 도서 정보, 댓글 등 모든 콘텐츠를 의미합니다.

"딥타임 타이머"는 설정된 시간 동안 다른 앱의 사용을 제한하여 독서에 집중할 수 있도록 돕는 기능입니다. 본 기능의 원활한 사용을 위해 기기 접근 권한이 필요할 수 있습니다.

제3조 (회원의 의무 및 위반 시 조치)
1. 회원은 다음 각 호에 해당하는 행위를 하여서는 안 됩니다.
   - 타인의 정보를 도용하거나, 저작권 등 제3자의 권리를 침해하는 게시물을 작성하는 행위
   - 타 회원의 독서 일지에 대해 욕설, 비방, 성희롱 등 불쾌감을 유발하는 댓글을 작성하는 행위
   - 음란물, 사행성 정보 등 공서양속에 반하는 정보를 게시하는 행위 (이하 "불쾌감을 주는 콘텐츠")
   - 회사의 동의 없이 서비스를 영리 목적으로 이용하는 행위
   - 서비스의 안정적인 운영을 방해하는 모든 행위

2. 회사는 회원이 제3조 1항을 위반하는 경우, 해당 게시물을 사전 통지 없이 삭제하거나 회원의 서비스 이용을 제한 또는 영구 정지할 수 있습니다.

3. 회사는 불쾌감을 주는 콘텐츠에 대한 신고가 접수될 경우, 신고 시점으로부터 24시간 이내에 해당 콘텐츠를 검토하고 삭제 및 게시자 계정 제재 조치를 취할 의무가 있습니다.

제4조 (게시물의 저작권)
1. 회원이 서비스 내에 게시한 게시물의 저작권은 해당 게시물의 저작자에게 귀속됩니다.

2. 회원이 서비스 내에 게시하는 게시물은 서비스 및 관련 프로모션 등에 노출될 수 있으며, 해당 노출을 위해 필요한 범위 내에서는 일부 수정, 복제, 편집되어 게시될 수 있습니다.

제5조 (면책조항)
1. 회사는 천재지변 또는 이에 준하는 불가항력으로 인하여 서비스를 제공할 수 없는 경우에는 서비스 제공에 관한 책임이 면제됩니다.

2. 회사는 회원이 서비스와 관련하여 게재한 정보, 자료, 사실의 신뢰도, 정확성 등의 내용에 관하여는 책임을 지지 않습니다.

제6조 (준거법 및 재판관할)
본 약관에 관하여 분쟁이 발생하는 경우 대한민국 법을 준거법으로 하며, 관련 소송은 민사소송법상의 관할 법원에 제기합니다.

공고일자: 2025년 8월 14일
시행일자: 2025년 8월 14일''',
            style: learningBodyStyle,
          ),
        );
      case PolicyType.personalInformation:
        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Text(
            '''개인정보 수집 및 이용 동의

북스타(Bookstar)는 개인정보보호법 등 관련 법령에 따라 이용자의 개인정보를 보호하고, 이와 관련한 고충을 신속하게 처리할 수 있도록 다음과 같이 개인정보 처리방침을 수립합니다.

1. 개인정보의 수집·이용 목적 및 항목

수집·이용 목적:
- 회원 식별, 서비스 제공(독서 일지 기록/공유, 딥타임 타이머 기능, 채팅 등)
- 고객 문의 응대 및 지원
- 서비스 개선 및 부정 이용 방지

수집·이용 항목:
- 이메일, 닉네임, 소셜로그인 제공사 고유 식별 정보
- 게시물 정보 (사진, 텍스트, 도서 정보, 댓글 등)
- 채팅 정보
- 딥타임 타이머 이용 기록 (집중 시간 등)
- 서비스 이용 기록, 접속 로그, 기기 정보(OS, 기기 종류)

2. 개인정보의 보유 및 이용 기간
회사는 법령에 따른 개인정보 보유·이용기간 또는 정보 주체로부터 동의받은 보유·이용기간 내에서 개인정보를 처리합니다. 원칙적으로 회원 탈퇴 시 지체 없이 해당 개인정보를 파기합니다.

3. 정보주체의 권리
이용자는 언제든지 등록되어 있는 자신의 개인정보를 조회·수정하거나 회원 탈퇴를 통해 개인정보 이용 동의를 철회할 수 있습니다.

공고일자: 2025년 8월 14일
시행일자: 2025년 8월 14일''',
            style: learningBodyStyle,
          ),
        );
      case PolicyType.marketing:
        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Text(
            '''이벤트 및 마케팅 정보 수신 동의 (선택)

북스타(Bookstar)가 제공하는 새로운 소식, 이벤트, 유용한 독서 정보 등을 수신하는 것에 동의합니다.

수신 목적:
- 신규 기능(독서 챌린지 등) 안내
- 추천 도서 및 이벤트 정보 제공
- 제휴 혜택 및 광고성 정보 전송

수신 방법:
- 앱 푸시 알림
- 카카오톡
- 이메일

보유 및 이용 기간: 동의 철회 시 또는 회원 탈퇴 시까지

※ 본 동의는 선택 사항이며, 동의하지 않으셔도 북스타의 모든 기본 서비스를 정상적으로 이용하실 수 있습니다.

※ 수신 동의 여부는 언제든지 [앱 내 설정 > 알림 설정] 메뉴에서 변경하거나 철회할 수 있습니다.

공고일자: 2025년 8월 14일
시행일자: 2025년 8월 14일''',
            style: learningBodyStyle,
          ),
        );
    }
  }
}
