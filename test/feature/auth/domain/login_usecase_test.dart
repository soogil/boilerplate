import 'package:boilerplate/feature/auth/data/repositories/auth_repository_impl.dart';
import 'package:boilerplate/feature/auth/domain/entities/user.dart';
import 'package:boilerplate/feature/auth/domain/repositories/auth_repository.dart';
import 'package:boilerplate/feature/auth/domain/usecase/login_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';


class FakeAuthRepository implements AuthRepository {
  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    return User(
      id: '123',
      email: email,
      name: 'Test User',
    );
  }
}

void main() {
  group('LoginUseCase', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          // 도메인 레이어의 authRepositoryProvider를 Fake로 교체
          authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
        ],
      );
      addTearDown(container.dispose);
    });

    test('이메일/비밀번호로 로그인하면 User를 반환한다', () async {
      // given
      final useCase = container.read(loginUseCaseProvider);

      // when
      final user = await useCase(
        email: 'test@test.com',
        password: '1234',
      );

      // then
      expect(user.id, '123');
      expect(user.email, 'test@test.com');
      expect(user.name, 'Test User');
    });

    test('이메일이 비어 있으면 예외를 던진다 (비즈니스 검증 예시)', () async {
      final useCase = container.read(loginUseCaseProvider);

      expect(
            () => useCase(email: '', password: '1234'),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}