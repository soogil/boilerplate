import 'package:boilerplate/feature/auth/data/models/user_model.dart';


abstract class AuthDataSource {
  Future<UserModel> login({
    required String email,
    required String password,
  });
}

/// 예제용 Fake 구현 (테스트/샘플용)
class FakeAuthDataSource implements AuthDataSource {
  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    // 네트워크 지연 시뮬레이션
    await Future.delayed(const Duration(seconds: 1));

    if (email == 'test@test.com' && password == '1234') {
      return UserModel(
        id: '1',
        email: email,
        name: 'Test User',
      );
    } else {
      throw Exception('Invalid email or password');
    }
  }
}