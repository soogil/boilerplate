import 'package:boilerplate/feature/auth/data/repositories/auth_repository_impl.dart';
import 'package:boilerplate/feature/auth/domain/entities/user.dart';
import 'package:boilerplate/feature/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'login_usecase.g.dart';

// 지금은 전달만 하지만 할일이 많음
class LoginUseCase {
  final AuthRepository _authRepository;

  LoginUseCase(this._authRepository);

  Future<User> call({
    required String email,
    required String password,
  }) {
    // 1. 형식 검증이 추가 될 수 도있고(UI 검증이면 viewmodel에서 처리,
    // 비즈니스 규칙이면 usecase 처리 - 예를 들면 api사용해서 계정 확인을 해야할때
    // if (email.isEmpty || password.isEmpty) {
    //   throw DomainException('이메일과 비밀번호를 모두 입력해야 합니다.');
    // }
    //
    // // 이메일 형식 검증
    // if (!email.contains('@')) {
    //   throw DomainException('이메일 형식이 올바르지 않습니다.');
    // }

    // 2. 여러 리턴 값을 조합하는 경우
    // final profile = await _profileRepository.fetchProfile(user.id);
    //
    // return (user, profile);


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