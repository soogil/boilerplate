import 'package:boilerplate/feature/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'login_state.dart';

class LoginViewModel extends StateNotifier<LoginState> {
  final AuthRepository _authRepository;

  LoginViewModel(this._authRepository) : super(const LoginState());

  Future<void> login({
    required String email,
    required String password,
  }) async {
    // 로딩 상태
    state = state.copyWith(
      status: LoginStatus.loading,
      errorMessage: null,
    );

    try {
      final user = await _authRepository.login(
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
