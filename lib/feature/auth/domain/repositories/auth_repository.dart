import 'package:boilerplate/feature/auth/domain/entities/user.dart';


abstract class AuthRepository {
  Future<User> login({
    required String email,
    required String password,
  });
}