import 'package:boilerplate/feature/auth/data/datasource/auth_datasource.dart';
import 'package:boilerplate/feature/auth/data/models/user_model.dart';
import 'package:boilerplate/feature/auth/data/repositories/auth_repository_impl.dart';
import 'package:boilerplate/feature/auth/domain/entities/user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


/// RemoteDataSource Fake: 실제 Dio 호출 대신 고정된 DTO 반환
class FakeAuthRemoteDataSource implements AuthDataSource {
  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    return UserModel(
      id: '999',
      email: email,
      name: 'Remote User',
    );
  }
}

void main() {
  group('AuthRepositoryImpl', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          // data layer의 authRemoteDataSourceProvider를 Fake로 교체
          authDataSourceProvider
              .overrideWithValue(FakeAuthRemoteDataSource()),
        ],
      );
      addTearDown(container.dispose);
    });

    test('RemoteDataSource의 UserDto를 User 엔티티로 변환한다', () async {
      // given
      final repo = container.read(authRepositoryProvider);

      // when
      final user = await repo.login(
        email: 'test@test.com',
        password: '1234',
      );

      // then
      expect(user, isA<User>());
      expect(user.id, '999'); // DTO의 id가 그대로 매핑되었는지
      expect(user.email, 'test@test.com');
      expect(user.name, 'Remote User');
    });
  });
}