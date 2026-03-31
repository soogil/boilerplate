import 'package:boilerplate/feature/auth/domain/usecase/login_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'login_state.dart';
part 'login_view_model.g.dart';

@riverpod
class LoginViewModel extends _$LoginViewModel {
  @override
  LoginState build() {
    return const LoginState();
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    // 1. 로딩 상태로 변경 (UI 반응: 로딩 인디케이터 표시)
    state = state.copyWith(authState: const AsyncValue.loading());

    // 2. UseCase 실행 (TaskEither 실행)
    final result = await ref.read(loginUseCaseProvider).call(
        email: email,
        password: password
    ).run();

    // 3. 결과 처리 (Fold)
    state = result.fold(
      // 실패 시: 에러 상태로 변경 (UI 반응: 팝업)
          (failure) => state.copyWith(
        authState: AsyncValue.error(failure, StackTrace.current),
      ),
      // 성공 시: 데이터 상태로 변경 (UI 반응: 페이지 이동)
          (user) => state.copyWith(
        authState: AsyncValue.data(user),
      ),
    );
  }

  void reset() {
    state = const LoginState();
  }
}