import 'package:boilerplate/feature/auth/data/datasource/auth_datasource.dart';
import 'package:boilerplate/feature/auth/data/models/user_model.dart';
import 'package:boilerplate/feature/auth/data/repositories/auth_repository_impl.dart';
import 'package:boilerplate/feature/auth/domain/entities/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthDataSource implements AuthDataSource {
  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    return UserModel(id: '999', email: email, name: 'Remote User');
  }
}

void main() {
  group('AuthRepositoryImpl', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          authDataSourceProvider.overrideWith((ref) => _FakeAuthDataSource()),
        ],
      );
      addTearDown(container.dispose);
    });

    test('DataSource UserModel을 User 엔티티로 변환한다', () async {
      final repo = container.read(authRepositoryProvider);
      final result = await repo.login(
        email: 'test@test.com',
        password: '1234',
      ).run();

      expect(result.isRight(), true);
      result.fold(
        (f) => fail('Expected Right but got Left: $f'),
        (user) {
          expect(user, isA<User>());
          expect(user.id, '999');
          expect(user.email, 'test@test.com');
          expect(user.name, 'Remote User');
        },
      );
    });
  });
}
