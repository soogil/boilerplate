import 'package:boilerplate/feature/auth/domain/entities/user.dart';

// 인터페이스만 구현 어떤 기능이 필요한지만
abstract class AuthRepository {
  Future<User> login({
    required String email,
    required String password,
  });
}