import 'package:boilerplate/feature/auth/domain/entities/user.dart';
import 'package:boilerplate/feature/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/auth_repository_impl.dart';

part 'login_usecase.g.dart';

class LoginUseCase {
  final AuthRepository _authRepository;

  LoginUseCase(this._authRepository);

  Future<User> call({
    required String email,
    required String password,
  }) {
    return _authRepository.login(
      email: email,
      password: password,
    );
  }
}

@riverpod
LoginUseCase loginUseCase(Ref ref) {
  final repo = ref.watch(authRepositoryProvider);
  return LoginUseCase(repo);
}