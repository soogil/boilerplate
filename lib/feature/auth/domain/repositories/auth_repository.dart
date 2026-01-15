import 'package:boilerplate/core/api/failure.dart';
import 'package:boilerplate/feature/auth/domain/entities/user.dart';
import 'package:fpdart/fpdart.dart';

// 인터페이스만 구현 어떤 기능이 필요한지만
abstract class AuthRepository {
  TaskEither<Failure, User> login({
    required String email,
    required String password,
  });
}