# boilerplate

# 폴더 구조

lib/
  core/
    router/
    theme/
    utils/
  feature/
    auth/           //ex
      data/
      domain/
      presentation/
  main.dart

# 기술스택 & 패턴
Riverpod(State 관리 / DI)
Freezed(모델, 상태)
Dio(REST)
GoRouter(라우팅)
build_runner, json_serializable 등

# init 스크립트 사용법
./init_project.sh "My App" com.mycompany.myapp my_app
