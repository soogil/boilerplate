# boilerplate-riverpod

Flutter Clean Architecture 보일러플레이트 — Riverpod + GoRouter + Freezed + fpdart

자세한 구조 설명은 [PROJECT_STRUCTURE.md](./PROJECT_STRUCTURE.md)를 참고하세요.

---

## 빠른 시작

### 1. 보일러플레이트 클론

```bash
git clone <repo-url> my_new_app
cd my_new_app
flutter pub get
```

### 2. 프로젝트 초기화 (앱 이름 / 번들 ID / 패키지명 일괄 변경)

```bash
dart run init_project.dart "My App" com.company.myapp my_app
```

| 파라미터 | 설명 | 예시 |
|---|---|---|
| `"앱 이름"` | 기기에 표시되는 앱 이름 | `"My App"` |
| `번들 ID` | Android 패키지명 / iOS 번들 ID | `com.company.myapp` |
| `pubspec 이름` | Dart 패키지명 (snake_case) | `my_app` |

### 3. 코드 생성

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. 실행

```bash
flutter run
```

---

## 기술 스택

| 분류 | 패키지 |
|---|---|
| 상태관리 / DI | flutter_riverpod, riverpod_annotation, riverpod_generator |
| 네트워크 | dio |
| 라우팅 | go_router |
| 불변 모델 | freezed, freezed_annotation |
| JSON 직렬화 | json_serializable, json_annotation |
| 함수형 에러처리 | fpdart (Either, TaskEither) |
| 코드 생성 | build_runner |

---

## 폴더 구조

```text
├── android/                  # Android native project
├── ios/                      # iOS native project
├── lib/                      
│   ├── core/                 # 공통 인프라 (라우터, 테마, 유틸 등)
│   │   ├── config/           # 환경설정, 상수, Env
│   │   ├── router/           # GoRouter 설정
│   │   ├── theme/            # 색상, 타이포, 위젯 테마
│   │   └── utils/            # 공통 유틸리티 함수
│   ├── feature/              # 기능(도메인) 단위 모듈
│   │   └── auth/             # 예시: 로그인/회원 관련 기능
│   │       ├── data/         # DTO, Repository 구현, Remote/DataSource
│   │       ├── domain/       # Entity, Repository interface, UseCase
│   │       └── presentation/ # ViewModel, State, Screen(UI)
│   └── main.dart             # 앱 엔트리 포인트
├── test/                     # 테스트 코드
│   └── feature/
│       └── auth/             # Auth 도메인 테스트 예시
├── pubspec.yaml
└── README.md
```