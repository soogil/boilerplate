import 'package:boilerplate/core/api/failure.dart';
import 'package:boilerplate/feature/auth/data/repositories/auth_repository_impl.dart';
import 'package:boilerplate/feature/auth/domain/entities/user.dart';
import 'package:boilerplate/feature/auth/domain/repositories/auth_repository.dart';
import 'package:boilerplate/feature/auth/domain/usecase/login_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

class _SuccessAuthRepository implements AuthRepository {
  @override
  TaskEither<Failure, User> login({
    required String email,
    required String password,
  }) =>
      TaskEither.right(User(id: '123', email: email, name: 'Test User'));
}

class _FailureAuthRepository implements AuthRepository {
  @override
  TaskEither<Failure, User> login({
    required String email,
    required String password,
  }) =>
      TaskEither.left(ServerFailure('로그인 실패'));
}

void main() {
  group('LoginUseCase', () {
    test('성공 시 User를 반환한다', () async {
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWith((ref) => _SuccessAuthRepository()),
        ],
      );
      addTearDown(container.dispose);

      final useCase = container.read(loginUseCaseProvider);
      final result = await useCase(
        email: 'test@test.com',
        password: '1234',
      ).run();

      expect(result.isRight(), true);
      result.fold(
        (f) => fail('Expected Right but got Left: $f'),
        (user) {
          expect(user.id, '123');
          expect(user.email, 'test@test.com');
          expect(user.name, 'Test User');
        },
      );
    });

    test('실패 시 Failure를 반환한다', () async {
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWith((ref) => _FailureAuthRepository()),
        ],
      );
      addTearDown(container.dispose);

      final useCase = container.read(loginUseCaseProvider);
      final result = await useCase(
        email: 'test@test.com',
        password: '1234',
      ).run();

      expect(result.isLeft(), true);
      result.fold(
        (f) => expect(f, isA<ServerFailure>()),
        (_) => fail('Expected Left but got Right'),
      );
    });
  });
}
