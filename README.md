# 하루패스 (HaruPass)

> 관리자가 등록한 일일 미션을 관리대상이 모두 완료해야 폰 잠금이 해제되는 안드로이드 앱

## 프로젝트 구조

```
harupass/
├── melos.yaml              # Melos 모노레포 설정
├── pubspec.yaml            # 워크스페이스 루트
├── analysis_options.yaml   # 공통 린트 설정
└── packages/
    ├── shared/             # 공통 모델, 상수, 테마, 유틸리티
    ├── admin_app/          # 관리자 앱 (com.harupass.admin)
    └── subject_app/        # 관리대상 앱 (com.harupass.subject)
```

## 기술 스택

- **Flutter** + **Kotlin** (네이티브 잠금 로직)
- **Firebase** (Auth, Firestore, Storage, Functions, FCM)
- **Riverpod** (상태관리)
- **go_router** (라우팅)
- **Melos** (모노레포 관리)

## 환경 요구사항

- Flutter SDK >= 3.10.0
- Dart SDK >= 3.11.5
- Melos >= 7.5.0
- Android Studio / VS Code
- Java 17+ (Android 빌드용)

## 설치 및 실행

### 1. 저장소 클론

```bash
git clone https://github.com/sohyunLee0517/harupass.git
cd harupass
```

### 2. Melos 설치

```bash
dart pub global activate melos
```

> PATH에 `$HOME/.pub-cache/bin`이 포함되어 있는지 확인하세요.
> 
> ```bash
> export PATH="$PATH":"$HOME/.pub-cache/bin"
> ```

### 3. Bootstrap (의존성 설치)

```bash
melos bootstrap
```

이 명령어가 세 패키지(shared, admin_app, subject_app)의 의존성을 모두 설치합니다.

### 4. 앱 실행

```bash
# 관리자 앱
cd packages/admin_app
flutter run

# 관리대상 앱
cd packages/subject_app
flutter run
```

## Melos 스크립트

```bash
melos run analyze    # 전체 프로젝트 정적 분석
melos run test       # 전체 테스트 실행
melos run clean      # 빌드 캐시 정리
```

## 패키지 설명

### shared
공통으로 사용되는 코드:
- **models**: Firestore 데이터 모델 (User, Todo, Score, League 등)
- **constants**: 앱 상수, Firestore 경로
- **theme**: 컬러 시스템, 앱 테마

### admin_app (관리자 앱 - 하루패스)
- 미션 등록 및 관리
- 사진 인증 검수 (통과/반려)
- 자녀 대시보드 및 통계
- 초대코드 발급

### subject_app (관리대상 앱 - 하루패스 미션)
- 미션 확인 및 사진 인증 업로드
- Custom Launcher + Lock Task Mode 잠금
- 셀프 잠금 (자기통제 훈련)
- 리그 랭킹

## Firebase 설정 (TODO)

아직 Firebase 프로젝트가 연동되지 않았습니다. 추후 `flutterfire configure`로 설정 필요:

```bash
# Firebase CLI 설치
npm install -g firebase-tools

# FlutterFire CLI 설치
dart pub global activate flutterfire_cli

# Firebase 설정 (각 앱 디렉토리에서)
flutterfire configure
```

## 라이선스

Private - All rights reserved
