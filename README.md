# boilerplate

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
## 기술 스택 & 패턴

- **Riverpod** — 상태관리 / DI
- **Freezed** — 모델 / 상태 정의
- **Dio** — REST API 통신
- **GoRouter** — 라우팅 구조
- **build_runner / json_serializable** — 코드 생성  
