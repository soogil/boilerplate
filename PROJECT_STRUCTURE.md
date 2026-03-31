# 프로젝트 구조 정의서

## 아키텍처 개요

**Clean Architecture** 기반으로 각 Feature를 독립 모듈로 관리합니다.
의존 방향: `Presentation → Domain ← Data`

```
Presentation  (UI, ViewModel, State)
     ↓
  Domain       (Entity, Repository Interface, UseCase)
     ↑
   Data        (Model, Repository 구현, DataSource)
```

---

## 전체 폴더 구조

```
lib/
├── core/                          # 앱 전역 공통 인프라
│   ├── api/
│   │   ├── dio.dart               # Dio 인스턴스 Provider (riverpod_generator)
│   │   ├── dio.g.dart             # [generated]
│   │   └── failure.dart           # 도메인 에러 클래스 (Failure, ServerFailure, NetworkFailure)
│   ├── config/                    # 환경설정, 상수, Flavor/Env 값
│   ├── router/
│   │   ├── app_router.dart        # GoRouter Provider
│   │   ├── app_router.g.dart      # [generated]
│   │   └── app_pages.dart         # 라우트 경로 상수
│   ├── theme/
│   │   └── app_color.dart         # 색상 팔레트 상수
│   └── util/                      # 공통 유틸리티 함수
│
├── feature/                       # 기능(도메인) 단위 모듈
│   └── {feature_name}/            # 예: auth, home, profile
│       ├── data/
│       │   ├── datasource/
│       │   │   ├── {name}_datasource.dart      # 추상 클래스 + 구현체
│       │   │   └── {name}_datasource.g.dart    # [generated]
│       │   ├── models/
│       │   │   ├── {name}_model.dart           # JSON ↔ Dart (json_serializable + freezed)
│       │   │   ├── {name}_model.freezed.dart   # [generated]
│       │   │   └── {name}_model.g.dart         # [generated]
│       │   └── repositories/
│       │       ├── {name}_repository_impl.dart # Repository 인터페이스 구현체
│       │       └── {name}_repository_impl.g.dart # [generated]
│       │
│       ├── domain/
│       │   ├── entities/
│       │   │   └── {name}.dart                 # 순수 도메인 엔티티 (비즈니스 객체)
│       │   ├── repositories/
│       │   │   └── {name}_repository.dart      # Repository 추상 인터페이스
│       │   └── usecase/
│       │       ├── {action}_usecase.dart       # 단일 책임 UseCase (TaskEither 반환)
│       │       └── {action}_usecase.g.dart     # [generated]
│       │
│       └── presentation/
│           └── {screen}/
│               ├── {screen}_page.dart          # StatelessWidget / ConsumerWidget (UI)
│               ├── {screen}_state.dart         # freezed 상태 클래스
│               ├── {screen}_state.freezed.dart # [generated]
│               ├── {screen}_view_model.dart    # Notifier (riverpod_generator)
│               └── {screen}_view_model.g.dart  # [generated]
│
└── main.dart                      # 앱 엔트리 포인트 (ProviderScope 래핑)
```

---

## 계층별 역할

### core/

| 경로 | 역할 |
|---|---|
| `core/api/dio.dart` | Dio 인스턴스를 Riverpod Provider로 노출. BaseUrl, 타임아웃, 헤더, Interceptor 설정 |
| `core/api/failure.dart` | 도메인 계층에서 사용하는 에러 타입 정의 (`Failure`, `ServerFailure`, `NetworkFailure`) |
| `core/router/` | GoRouter 설정 및 라우트 경로 상수 관리 |
| `core/theme/` | 앱 전역 색상, 타이포그래피, 위젯 테마 |
| `core/config/` | API Base URL, 앱 환경(dev/staging/prod) 설정값 |
| `core/util/` | 날짜 포맷, 입력 유효성 검사 등 공통 헬퍼 함수 |

### feature/{name}/data/

| 경로 | 역할 |
|---|---|
| `datasource/` | 서버/로컬 API 호출 담당. 추상 클래스 + Riverpod Provider로 제공되는 구현체 |
| `models/` | JSON 직렬화 DTO. `freezed` + `json_serializable`로 생성. Domain Entity와 분리 |
| `repositories/` | Domain의 Repository 인터페이스 구현. DataSource 호출 → Entity 변환 → fpdart `Either` 반환 |

### feature/{name}/domain/

| 경로 | 역할 |
|---|---|
| `entities/` | 비즈니스 로직에서 사용하는 순수 Dart 객체. 외부 의존성 없음 |
| `repositories/` | Data 계층에 대한 추상 인터페이스. Domain이 Data를 직접 의존하지 않도록 역전 |
| `usecase/` | 단일 비즈니스 동작 캡슐화. `TaskEither<Failure, T>`를 반환해 에러를 타입 안전하게 전달 |

### feature/{name}/presentation/

| 경로 | 역할 |
|---|---|
| `{screen}_page.dart` | 순수 UI. `ConsumerWidget` 또는 `StatelessWidget`. ViewModel 구독 후 렌더링 |
| `{screen}_state.dart` | `freezed` 불변 상태 객체. UI에 필요한 모든 상태 포함 |
| `{screen}_view_model.dart` | `@riverpod` Notifier. UseCase 호출, 상태 업데이트, UI 이벤트 처리 |

---

## 데이터 흐름

```
[UI Event]
    ↓
ViewModel.someAction()
    ↓
UseCase.call()          → TaskEither<Failure, Entity>
    ↓
Repository (interface)
    ↓
RepositoryImpl          → DataSource 호출
    ↓
DataSource              → Dio HTTP 요청
    ↓
Model.fromJson()        → Entity 변환
    ↑
fold(failure, success)  → State 업데이트
    ↑
[UI 리렌더링]
```

---

## 기술 스택

| 분류 | 패키지 | 용도 |
|---|---|---|
| 상태관리 / DI | `flutter_riverpod`, `riverpod_annotation`, `riverpod_generator` | Provider, Notifier, 코드 생성 |
| 네트워크 | `dio` | REST API HTTP 클라이언트 |
| 라우팅 | `go_router` | 선언적 페이지 라우팅 |
| 불변 모델 | `freezed`, `freezed_annotation` | 불변 데이터 클래스, Union 타입 |
| JSON 직렬화 | `json_serializable`, `json_annotation` | fromJson / toJson 코드 생성 |
| 함수형 에러처리 | `fpdart` | `Either`, `TaskEither` |
| 코드 생성 | `build_runner` | `.g.dart`, `.freezed.dart` 생성 실행기 |
| 린트 | `flutter_lints` | Dart/Flutter 정적 분석 규칙 |

---

## 새 Feature 추가 방법

1. `lib/feature/{name}/` 디렉터리 생성
2. **Domain 먼저**: Entity → Repository 인터페이스 → UseCase 작성
3. **Data**: Model(freezed+json) → DataSource → RepositoryImpl 작성
4. **Presentation**: State(freezed) → ViewModel → Page 작성
5. `flutter pub run build_runner build --delete-conflicting-outputs` 실행
6. `core/router/app_router.dart`에 라우트 추가

---

## 코드 생성

```bash
# 전체 생성 (기존 파일 덮어쓰기)
flutter pub run build_runner build --delete-conflicting-outputs

# 파일 변경 감지 자동 생성
dart run build_runner watch --delete-conflicting-outputs
```

생성 대상 파일 (`[generated]` 표시):
- `*.g.dart` — riverpod_generator, json_serializable
- `*.freezed.dart` — freezed

> 이 파일들은 직접 편집하지 말 것. `.gitignore`에 추가하거나 커밋할 경우 항상 재생성 후 커밋.

---

## 프로젝트 초기화 (새 프로젝트 시작)

보일러플레이트를 복사한 뒤 아래 스크립트로 패키지명, 앱 이름, 번들 ID를 일괄 변경합니다.

### Windows (PowerShell)
```powershell
./init_project.ps1 "My App Name" com.company.myapp my_app
```

### macOS / Linux (Bash)
```bash
chmod +x init_project.sh
./init_project.sh "My App Name" com.company.myapp my_app
```

파라미터 순서: `"앱 표시 이름"` `번들ID(패키지명)` `pubspec_name(스네이크케이스)`

스크립트가 처리하는 항목:
- `pubspec.yaml` name / description 변경
- 모든 Dart 파일의 `package:boilerplate/` import 경로 변경
- Android `AndroidManifest.xml` / `build.gradle` 패키지명 변경
- Android `MainActivity.kt` 패키지 선언 변경 및 파일 이동
- iOS 앱 이름 / 번들 ID 변경 (rename 패키지)
- `flutter clean && flutter pub get` 실행
