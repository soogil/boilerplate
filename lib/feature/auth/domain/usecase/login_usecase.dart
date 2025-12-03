import 'package:boilerplate/feature/auth/domain/entities/user.dart';
import 'package:boilerplate/feature/auth/domain/repositories/auth_repository.dart';


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
