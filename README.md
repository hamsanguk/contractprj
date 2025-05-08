# Sample Hardhat Project

커뮤니티에서 동작할 수 있는 컨트랙트를 구현을 목표로 했습니다.
커뮤니티 구성원의 참여,기여,활동내역에 따라 "내부 유틸리티 토큰"의 기여 기반 보상 플랫폼 입니다.
사용처와 플랫폼 구조가 안정되면, 비거래형 내부 포인트 성격에서 거래가능한 가능성을 열어두었습니다.

커뮤니티 기반 활동에 따라 기여자에게 보상을 제공하는 탈중앙화 보상 플랫폼입니다.  
사용자는 게시글 작성, 댓글 참여, 투표 등 다양한 기여를 통해 플랫폼 토큰인 `CTK`를 획득하며,  
플랫폼이 성숙함에 따라 점진적으로 유틸리티를 확장하고 토큰의 유통 범위를 넓혀갑니다.
 
 
 ## 구성 및 상호작용
사용자의 활동 발생
예를 들어 사용자가 게시글을 작성하거나 댓글을 달면, 외부 시스템(프론트엔드 또는 백엔드)은 해당 활동 정보를 바탕으로 보상을 요청합니다.

보상 요청 전송
외부 시스템은 보상 요청을 위해 RewardManagerProxy 컨트랙트에 reward(user, activityType) 함수를 호출합니다.
여기서 user는 보상을 받을 사용자 주소, activityType은 활동 종류(예: 글쓰기, 댓글, 투표 등)를 나타냅니다.

로직 위임 (delegatecall)
RewardManagerProxy는 이 호출을 내부적으로 delegatecall을 통해 RewardManager 로직 컨트랙트에 위임합니다.
이때 실제 상태값은 Proxy에 저장되지만, 실행은 Logic 컨트랙트에서 수행됩니다.

보상 권한 검증
RewardManager는 먼저 AccessController를 조회해, 이 요청을 보낸 주체가 보상 권한이 있는 주소인지 확인합니다.
권한이 없다면 트랜잭션은 revert됩니다.

보상 금액 결정
권한이 확인되면, RewardManager는 RewardPolicy 컨트랙트를 조회해, 해당 활동(activityType)에 대해 얼마의 토큰을 지급해야 하는지 확인합니다.

토큰 민팅 요청
결정된 보상 금액을 기반으로, RewardManager는 CommunityTokenProxy 컨트랙트의 mint() 함수를 호출합니다.

토큰 발행 로직 실행
CommunityTokenProxy는 다시 delegatecall을 통해 실제 로직 컨트랙트인 CommunityToken에게 실행을 위임하고,
해당 사용자 주소에 보상 토큰(CTK)을 발행합니다.
커뮤니티에서 동작할 수 있는 컨트랙트를 구현을 목표로 했습니다.
커뮤니티 구성원의 참여,기여,활동내역에 따라 "내부 유틸리티 토큰"의 기여 기반 보상 플랫폼 입니다.
사용처와 플랫폼 구조가 안정되면, 비거래형 내부 포인트 성격에서 거래가능한 가능성을 열어두었습니다.

커뮤니티 기반 활동에 따라 기여자에게 보상을 제공하는 탈중앙화 보상 플랫폼입니다.  
사용자는 게시글 작성, 댓글 참여, 투표 등 다양한 기여를 통해 플랫폼 토큰인 `CTK`를 획득하며,  
플랫폼이 성숙함에 따라 점진적으로 유틸리티를 확장하고 토큰의 유통 범위를 넓혀갑니다.

---

## 토큰 이코노미 설계

| 항목 | 설명 |
|------|------|
| **토큰 명** | `Community Token` (`CTK`) |
| **토큰 유형** | 내부 유틸리티 토큰 (초기에는 외부 거래 불가) |
| **총 공급량** | 초기 공급량 고정 + 보상 기반 발행 (관리자 승인) |
| **보상 방식** | 게시물, 댓글, 투표 등 활동에 따라 차등 지급 |
| **사용처 예시** | 프리미엄 기능, 리워드 풀 참여, NFT 민팅, DAO 투표 등 |
| **토큰 정책** | 점진적 확장: 내부 포인트 → 외부 거래 가능 자산 |

---

## 업그레이더블 구조 도입 이유

| 이유 | 설명 |
|------|------|
투기성 유입 방지
| **보상 정책 변경 대응** | 활동별 리워드 기준은 유동적일 수 있음 |
| **기능 확장** | NFT, DAO, 프리미엄 기능 등 신규 기능 도입 |
| **보안 대응** | 취약점 또는 버그 발생 시 롤백 없이 로직 교체 |
| **토큰 정책 전환** | 거래 제한 → 점진적 유통 허용 구조로 확장 가능 |

---

## 아키텍처 구성

- **Proxy Contract**: 상태(state)를 저장하는 영구 주소
- **Logic (Implementation) Contract**: 실제 비즈니스 로직
- **Admin 권한**: 업그레이드 트리거 실행 (단일 계정 또는 멀티시그 가능)
- **Initialize() 방식**: constructor 대신 단 한 번 초기화 수행



---
## 테스트

- Hardhat 환경에서 자동화 테스트 포함
- `test/tokenHive.test.ts` 등에서 업그레이드 시 상태 보존 검증
- 보상 수령, 토큰 전송 등 주요 기능 유닛 테스트 포함 예정
beforeEach: 각 테스트 전 AccessController, RewardPolicy, CommunityToken, RewardManager 등 모든 컨트랙트를 배포합니다.
should allow admin to set and update Reward Manager: 관리자가 RewardManager를 설정하고 업데이트할 수 있는지 확인합니다.
should allow RewardManager to mint tokens: RewardManager가 사용자에게 보상으로 토큰을 민팅할 수 있는지 테스트합니다.
should not allow unauthorized users to mint tokens: 권한이 없는 사용자가 민팅을 시도할 때 오류가 발생하는지 확인합니다.
should allow RewardPolicy admin to set new reward amount: RewardPolicy의 관리자가 보상 금액을 설정할 수 있는지 테스트합니다.
should allow RewardManager to claim reward once: 사용자가 보상을 한 번만 클레임할 수 있는지 확인합니다.
should not allow double claiming of reward: 사용자가 보상을 두 번 이상 클레임하지 못하도록 방지하는지 테스트합니다.

---

## 향후 확장 계획

- 온체인 DAO 투표 기능
- 기여 내역 기반 NFT 발행
- 외부 지갑 및 DEX 연동 기능
- 프론트엔드 대시보드 및 사용자 기여 통계
