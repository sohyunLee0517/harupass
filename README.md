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
    └── app/                # 하루패스 앱 (관리자/관리대상 통합)
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
- Android Studio + Android SDK
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

### 4. 앱 실행

```bash
cd packages/app
flutter run
```

첫 화면에서 **관리자** 또는 **관리대상** 역할을 선택하여 진입합니다.

### 5. 테스트 실행

```bash
melos run test    # 전체 테스트 (shared + app)
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
- **models**: Firestore 데이터 모델 (User, Todo, Score, SelfLock, League 등)
- **constants**: 앱 상수, Firestore 경로
- **theme**: 컬러 시스템, 앱 테마

### app (하루패스)
단일 앱에서 역할 기반으로 분기:
- **관리자 모드**: 미션 등록/관리, 사진 인증 검수, 자녀 초대, 통계
- **관리대상 모드**: 미션 수행/사진 인증, 잠금 화면, 셀프 잠금, 리그 랭킹

## Firebase 설정 (TODO)

아직 Firebase 프로젝트가 연동되지 않았습니다. 추후 `flutterfire configure`로 설정 필요:

```bash
# Firebase CLI 설치
npm install -g firebase-tools

# FlutterFire CLI 설치
dart pub global activate flutterfire_cli

# Firebase 설정
cd packages/app
flutterfire configure
```

## 라이선스

Private - All rights reserved
