# 하루패스 (HaruPass) 구현 계획

> 관리자가 등록한 일일 미션을 관리대상이 모두 완료해야 폰 잠금이 해제되는 안드로이드 앱.
> 자녀의 자기통제력 훈련을 위한 셀프 잠금 기능 포함.

---

## 1. 프로젝트 개요

### 컨셉
관리자(부모)가 등록한 그날의 미션을 관리대상(자녀)이 모두 수행하고 사진 인증을 통해 관리자 검수를 통과해야, 폰의 다른 앱 사용 잠금이 해제됨. 매일 자정에 미션 리셋. 게임화된 점수/리그 시스템으로 동기부여. 자녀가 스스로 잠금을 거는 셀프 통제 기능도 제공.

### 타겟
- **1차**: 부모 - 초등 고학년 이상 자녀
- **확장 가능**: 셀프 통제, 학습 관리

### 플랫폼
- **안드로이드 전용** (iOS는 시스템 정책상 잠금 구현 불가)
- 플러터 + 네이티브 Kotlin 혼합

### 앱 이름
- **하루패스 (HaruPass)**: 하루를 통과한다는 의미. "패스" 컨셉이 잠금 해제와 자연스럽게 연결.

---

## 2. 앱 구조

> **변경사항**: 원래 관리자/관리대상 분리형 2종이었으나, **단일 앱으로 통합** (역할 기반 분기)로 변경됨.

### 현재 모노레포 구조
```
harupass/
  packages/
    shared/        # 공통: 모델, 상수, 디자인 시스템
    app/           # 하루패스 앱 (관리자/관리대상 통합)
  pubspec.yaml     # Melos 설정
```

---

## 3. 기술 스택

### 프론트엔드
- **Flutter** (UI)
- **Kotlin** (관리대상 앱의 네이티브 잠금 로직)
- 상태관리: **Riverpod** (확정)
- 라우팅: go_router

### 백엔드 (Firebase)
- **Firebase Auth**: 관리자(이메일/카카오), 관리대상(익명 + 초대코드)
- **Firestore**: 사용자, 미션, 초대코드, 리그, 셀프 잠금
- **Cloud Storage**: 인증 사진
- **Cloud Functions**: 자정 처리, 주간 리그 처리, 초대코드 발급
- **FCM**: 검수 요청, 통과/반려, 완료 축하, 마일스톤 알림

---

## 4. 잠금 메커니즘

### 채택: Custom Launcher + Lock Task Mode 조합

| 우회 시도 | 차단 방식 |
|---|---|
| 홈 버튼 | Custom Launcher가 우리 앱 다시 띄움 |
| 최근 앱 | Lock Task가 막음 |
| 알림창 | Lock Task가 안 보이게 함 |
| 강제 종료 | Launcher가 다시 잡음 |
| 재부팅 | BootReceiver + Launcher가 자동 실행 |
| 기본 런처 변경 | 관리자에게 즉시 푸시 알림 |

### 잠금 종류

**1. 미션 잠금 (관리자 주도)**
- 매일 자정 자동 시작
- 미션 모두 통과 시 해제
- 일일 루틴 관리 목적

**2. 셀프 잠금 (관리대상 주도)**
- 자녀가 스스로 시작
- 자녀가 직접 해제 버튼 눌러서 종료
- 자기통제 훈련 목적

### 잠금 라이프사이클 (미션 잠금)
```
앱 켜짐
  → 오늘의 미션 표시
  → startLockTask()
  → 미션 수행 + 사진 업로드
  → 관리자 검수 → 모두 통과
  → 축하 화면 + stopLockTask()
  → 일반 모드 (다음 자정까지)
  → 자정 → 다시 잠금
```

---

## 5. 점수 시스템

### 누적 점수 (개인 기록, 영구 유지)
```
누적 점수 = 누적 도장 수 + 누적 마일스톤 보너스 + 누적 셀프 잠금 점수
```

**미션 마일스톤 보너스 (해당 일수 도달 시 1회 적립)**
- 3일 연속: +3점
- 5일 연속: +5점
- 7일 연속: +7점
- (이후 마일스톤 없음. 리그 시스템이 장기 동기 담당)

**셀프 잠금 점수 (다음 섹션 참조)**
- 30분당 1점, 30분 단위 끊기

**연속 끊김 시**
- 연속 일수만 0으로 리셋
- 누적 점수, 마일스톤 보너스, 셀프 잠금 점수는 유지
- 다시 1일차부터 시작

### 주간 점수 (랭킹용, 매주 월요일 0시 리셋)
```
주간 점수 = 이번 주 도장 수 + 이번 주 마일스톤 보너스 + 이번 주 셀프 잠금 점수
```

---

## 6. 셀프 잠금 시스템 (자녀 자율)

### 두 가지 모드

**모드 1: 잠금 예약 (Schedule Lock)**
- 미래 특정 시각부터 잠금 시작
- 최소 30분 이후부터 예약 가능
- 활용: 공부 시작 시간 미리 정해두기

**모드 2: 즉시 잠금 (Instant Lock)**
- 지금부터 N분/시간 동안 잠금
- 활용: "이번 한 시간만 집중하자"

### 시간 룰
- **최소**: 30분
- **최대**: 2시간 (한 번 잠금당)
- **신청 단위**: 30분 (30분/1시간/1시간 30분/2시간)
- **마감**: 당일 자정까지만 (자정 넘기는 잠금 불가)
- **남은 시간 자동 조정**: 자정까지 시간이 부족하면 가능한 옵션만 표시
  - 예: 22:30 신청 시 → 30분/1시간/1시간 30분 (2시간은 불가)
  - 예: 23:30 신청 시 → 30분만 가능
  - 예: 23:31 이후 → 신청 불가

### 핵심 룰
- **잠금 해제 버튼 상시 노출**: 자녀가 원할 때 능동적으로 종료
- **횟수 무제한**: 하루에 여러 번 가능
- **부모 잠금 중에는 사용 불가**: 미션 통과 후 자유시간에만

### 보상 정책
```
점수 = 잠금 진행 시간(분) ÷ 30 × 1점 (30분 단위로 끊기)

진행 시간별 점수:
- 0~29분: 0점
- 30~59분: +1점
- 60~89분: +2점
- 90~119분: +3점
- 120분 (2시간 도달): +4점, 자동 해제
```

### 점수 시뮬레이션
| 시작 | 진행 시간 | 해제 시점 | 점수 |
|---|---|---|---|
| 19:00 | 1시간 50분 | 20:50 | +3점 (1시간 30분치) |
| 22:00 | 2시간 (자동) | 24:00 | +4점 |
| 22:30 | 1시간 | 23:30 | +2점 |
| 19:00 | 25분 (조기 해제) | 19:25 | 0점 |

---

## 7. 리그 시스템 (듀오링고 스타일)

### 리그 단계: 시간 계열 7단계
| 순서 | 리그 이름 | 영문 | 컨셉 |
|---|---|---|---|
| 1 | 새벽 | Dawn | 시작 단계 |
| 2 | 아침 | Morning | 본격 도전 |
| 3 | 정오 | Noon | 성장 |
| 4 | 노을 | Sunset | 숙련 |
| 5 | 별 | Star | 전문가 |
| 6 | 달 | Moon | 마스터 |
| 7 | 해 | Sun | 정점 |

### 리그 동작 방식
- **그룹 매칭**: 같은 리그 사용자 30명씩 무작위 그룹 (인원 부족 시 더 적은 인원)
- **경쟁 기간**: 매주 월요일 0시 ~ 일요일 24시
- **결과 처리** (일요일 자정):
  - 상위 7명: 다음 리그로 승급
  - 중위 16명: 같은 리그 유지
  - 하위 7명: 강등 (새벽 리그는 강등 없음)

### 신규 사용자
- 모두 **새벽 리그**부터 시작
- 점수에 따라 자연스럽게 단계 형성

---

## 8. 데이터 모델 (Firestore)

```
users/{userId}
  - role: 'admin' | 'subject'
  - email, name, createdAt
  - subjectIds: string[]   # 관리자 전용
  - adminId: string        # 관리대상 전용
  - nickname: string       # 랭킹 표시용
  - profileEmoji: string

users/{userId}/score
  # 누적 (영구)
  - totalStamps: number
  - bonusPoints: number
  - selfLockPoints: number       # 셀프 잠금 누적 점수
  - totalScore: number
  - currentStreak: number
  - maxStreak: number
  - lastCompletedDate: string
  - achievedMilestones: number[]

    # 이번 주 (매주 리셋)
  - weeklyStamps: number
  - weeklyBonus: number
  - weeklySelfLockPoints: number # 이번 주 셀프 잠금 점수
  - weeklyScore: number

    # 리그 정보
  - currentLeague: 'dawn' | 'morning' | 'noon' | 'sunset' | 'star' | 'moon' | 'sun'
  - currentGroupId: string
  - bestLeague: string
  - leagueHistory: [{week, league, rank, result}]

selfLocks/{userId}/{lockId}
  - type: 'instant' | 'scheduled'
  - scheduledStart: timestamp     # 예약 잠금만
  - actualStart: timestamp
  - actualEnd: timestamp
  - plannedDuration: number       # 분 단위
  - actualDuration: number        # 실제 진행 시간
  - status: 'scheduled' | 'active' | 'completed' | 'cancelled'
  - earnedPoints: number          # 30분 단위 끊은 점수
  - createdAt: timestamp

inviteCodes/{code}
  - adminId, createdAt, expiresAt
  - usedBy, status

todos/{userId}/daily/{date}/items/{todoId}
  - title, description
  - status: 'pending' | 'submitted' | 'approved' | 'rejected'
  - photoUrl, submittedAt, reviewedAt, rejectReason
  - createdBy: 'admin' | 'subject'

templates/{userId}/{templateId}
  - name, items[], days[]

dailyState/{userId}/{date}
  - allCompleted: bool
  - lockReleasedAt: timestamp
  - stampType: 'normal' | 'milestone'

missionProposals/{userId}/{proposalId}
  - title, description
  - proposedAt, reviewedAt
  - status: 'pending' | 'approved' | 'modified_approved' | 'rejected'
  - rejectReason, modifiedTitle
  - resultTodoId

leagues/{yearWeek}/groups/{groupId}
  - league, userIds[], createdAt, finalizedAt

leagues/{yearWeek}/groups/{groupId}/rankings/{userId}
  - rank, weeklyScore, nickname, profileEmoji
  - result: 'promoted' | 'stayed' | 'demoted' | null
```

---

## 9. 사용자 플로우

### 관리자 가입 + 자녀 추가
1. 관리자 앱 설치 → 회원가입 (이메일/카카오)
2. 자녀 정보 입력 (이름, 나이)
3. 6자리 초대코드 생성
4. 코드를 자녀에게 전달

### 관리대상 연결
1. 관리대상 앱 설치
2. 초대코드 입력
3. "○○님이 보낸 초대예요" 확인 + 동의
4. 잠금 기능 동의 (필수)
5. 기본 런처 설정 안내
6. 닉네임 + 프로필 이모지 설정 (랭킹용)
7. 첫 미션 화면 진입

### 일일 사용 흐름

**관리대상**
1. 폰 켜면 잠금 모드 + 오늘 미션 표시
2. 미션 1개 수행 → 사진 찍기 → 업로드
3. 관리자 검수 대기
4. 통과 시: 다음 미션 / 반려 시: 다시 시도
5. 모두 통과 → 축하 화면 + 잠금 해제 + 도장 적립
6. (선택) 자유시간에 셀프 잠금 활용

**관리자**
1. 푸시 알림 ("○○이 검수 요청")
2. 앱에서 사진 + 미션 확인
3. 통과 / 반려(사유 입력)
4. 모두 완료 시 자녀에게 자동 축하 알림 발송

### 미션 등록 (번거로움 최소화)
1. **템플릿 기능**: "평일 루틴", "주말 루틴" 미리 만들고 원클릭 적용
2. **요일별 반복**: 자동 생성
3. **전날 복사**: "어제와 동일하게" 버튼
4. **빠른 추가**: 자주 쓰는 항목 카테고리화
5. **미션 제안 검토**: 자녀가 제안한 미션 승인/수정/반려

### 관리대상 → 관리자 미션 제안 플로우

**관리대상**
1. "오늘의 미션" 화면에서 "+ 미션 제안하기"
2. 제안 작성 (제목, 설명, 인증 방법, 예상 시간)
3. 관리자에게 전송

**관리자**
4. 푸시 알림: "○○이 미션을 제안했어요"
5. 검토 → 승인 / 수정 후 승인 / 반려

**관리대상**
6. 결과 알림 받음
7. 승인 시: 미션 리스트에 추가 (자녀가 만든 표시)

**제한 사항**
- 일일 제안 한도: 3개 (관리자 설정 가능)
- 승인 후에만 수행 가능
- 모든 제안은 관리자 검토 필수

---

## 10. 개발 단계

### Phase 0: 기획 확정 ✅ 완료
- ~~와이어프레임 작성~~
- ✅ Firebase 프로젝트 생성
- ✅ 모노레포 셋업 (Melos)
- ✅ 디자인 시스템 기초 잡기
- ~~로고/아이콘 디자인~~

### Phase 0.5: 기반 코드 ✅ 완료 (추가)
- ✅ 전체 Firestore 데이터 모델 구현 (shared 패키지)
- ✅ Firestore 경로 상수 정의
- ✅ Firebase 설정 (Auth, Firestore, Storage, Messaging)
- ✅ 온보딩 플로우 UI (역할 선택, 관리자 가입, 관리대상 참여)
- ✅ 라우팅 (go_router + 인증 기반 리다이렉트)
- ✅ 상태관리 셋업 (Riverpod)
- ✅ 관리자/관리대상 홈 화면 (기본 구조)
- ✅ 테스트 62개 작성
- ✅ 앱 구조 변경: 분리형 → 단일 앱 통합

### Phase 1: 앱 MVP (진행 중)
- ❌ Firebase Auth 실제 연동 (현재 mock)
- ❌ Firestore CRUD 연동
- ❌ Kotlin 네이티브 채널 셋업 (Lock Task, Launcher, BootReceiver)
- ❌ 잠금 화면 + 미션 표시 UI (실제 데이터 연동)
- ❌ 사진 촬영/업로드
- ❌ 관리자: 미션 등록/관리, 검수 화면
- ❌ 관리대상: 미션 수행/제출

### Phase 2: 초대코드 + 연결 (미시작)
- ❌ 초대코드 발급/검증
- ❌ 양방향 데이터 흐름 검증
- ❌ 검수 → 잠금 해제 end-to-end 테스트

### Phase 3: 점수/도장 시스템 (미시작)
- ❌ 도장 데이터 모델 + 자정 처리 로직
- ❌ 마일스톤 보너스 (3, 5, 7일)
- ❌ 연속 일수 추적 + 끊김 처리
- ❌ 출석 캘린더 화면
- ❌ 마이페이지 (개인 기록)

### Phase 4: 셀프 잠금 시스템 (미시작)
- ❌ 셀프 잠금 데이터 모델
- ❌ 즉시 잠금 / 예약 잠금 UI
- ❌ 잠금 진행 중 화면 (실시간 점수 표시)
- ❌ 잠금 해제 버튼 + 확인 다이얼로그
- ❌ 자정 자동 종료 처리
- ❌ 부모 잠금 중 비활성화 로직
- ❌ 점수 적립 (30분 단위 끊기)

### Phase 5: 리그 시스템 (미시작)
- ❌ 시간 계열 7단계 리그
- ❌ 30명 그룹 매칭 로직
- ❌ 주간 리그 화면 UI
- ❌ 승급/강등 처리 Cloud Function
- ❌ 리그 결과 알림
- ❌ 지난 주 결과 화면

### Phase 6: 미션 제안 기능 (미시작)
- ❌ 자녀 제안 화면
- ❌ 부모 검토 UI
- ❌ 승인/수정/반려 플로우
- ❌ 일일 제안 한도 설정

### Phase 7: 편의 기능 + 안정화 (미시작)
- ❌ 미션 템플릿 기능
- ❌ 요일별 반복
- ❌ 전날 복사
- ❌ 통계 화면
- ❌ 우회 시도 감지 (런처 변경 등)
- ❌ 비상 전화 UX
- ❌ 마일스톤 다가올 때 알림

### Phase 8: 출시 준비 (미시작)
- ❌ Play Store 정책 문서
- ❌ 개인정보처리방침
- ❌ 이용약관
- ❌ 베타 테스트
- ❌ 버그 수정 및 안정화

---

## 11. 주요 리스크 & 대응

| 리스크 | 대응 |
|---|---|
| Play Store 자녀 앱 정책 거절 | Family 정책 사전 학습, 명확한 동의 흐름 |
| 사용자가 기본 런처 변경 | 관리자에게 즉시 푸시 알림 |
| 관리자 검수 늦음 | 빠른 검수 위젯, 알림 강도 조절 |
| 사진 위변조/재사용 | 메타데이터 체크, 매일 다른 컨텍스트 요구 |
| 비상 상황 (긴급 전화) | 잠금 화면에 긴급 전화 버튼 노출 |
| 폰 초기화로 우회 | 막을 수 없음. 동기 부여 측면이라 OK |
| 리그 사용자 부족 (초기) | 30명 안 채워도 비율로 처리 |
| 자녀 닉네임 욕설/부적절 | 욕설 필터 + 부모 검수 |
| 셀프 잠금 자정 도달 처리 | 자동 해제 + 점수 적립 |

---

## 12. 핵심 결정사항 요약

- 앱 이름: **하루패스**
- 플랫폼: 안드로이드 전용
- 앱 구조: **단일 앱 (역할 기반 분기)** ← 변경됨
- 잠금: Custom Launcher + Lock Task Mode
- 상태관리: **Riverpod** ← 확정

**미션 시스템**
- 매일 자정 자동 잠금 시작
- 사진 인증 + 관리자 검수
- 모두 통과 시 잠금 해제 + 도장 적립

**점수 시스템**
- 누적 점수: 도장 + 마일스톤 + 셀프 잠금 점수
- 마일스톤: 3일(+3), 5일(+5), 7일(+7)
- 연속 끊김 시: 연속 일수만 0 리셋, 점수는 유지

**셀프 잠금 시스템**
- 두 가지 모드: 잠금 예약 / 즉시 잠금
- 시간: 최소 30분, 최대 2시간, 30분 단위
- 마감: 당일 자정까지만
- 잠금 해제 버튼 상시 노출
- 점수: 30분 단위 끊기

**랭킹/리그**
- 주간 리셋 (월요일 0시)
- 시간 계열 7단계 리그 (새벽 → 해)
- 30명 그룹, 상위 7명 승급, 하위 7명 강등

---

## 13. 부록: 기술 키워드

- Android Lock Task Mode (`startLockTask()`)
- DevicePolicyManager / DeviceAdminReceiver
- Custom Launcher (`category.HOME`, `category.DEFAULT`)
- BootReceiver (`BOOT_COMPLETED`)
- Flutter MethodChannel
- Firebase (Auth, Firestore, Storage, Functions, FCM)
- Cloud Functions Pub/Sub Scheduler (자정 리셋, 주간 리그 처리, 셀프 잠금 종료 처리)
- Melos (Flutter 모노레포)
