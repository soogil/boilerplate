import 'package:boilerplate/feature/auth/domain/usecase/login_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    // 상태: 로딩
    state = state.copyWith(
      status: LoginStatus.loading,
      errorMessage: null,
    );

    try {
      final useCase = ref.read(loginUseCaseProvider);
      final user = await useCase(
        email: email,
        password: password,
      );

      state = state.copyWith(
        status: LoginStatus.success,
        user: user,
      );
    } catch (e) {
      state = state.copyWith(
        status: LoginStatus.failure,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() {
    state = const LoginState();
  }
}