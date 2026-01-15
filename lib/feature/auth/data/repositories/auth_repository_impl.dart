import 'package:boilerplate/core/api/failure.dart';
import 'package:boilerplate/feature/auth/data/datasource/auth_datasource.dart';
import 'package:boilerplate/feature/auth/data/models/user_model.dart';
import 'package:boilerplate/feature/auth/domain/entities/user.dart';
import 'package:boilerplate/feature/auth/domain/repositories/auth_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_repository_impl.g.dart';

// 도메인과 data 연결 해주는 구현
class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _dataSource;

  AuthRepositoryImpl(this._dataSource);

  @override
  TaskEither<Failure, User> login({
    required String email,
    required String password,
  }) {
    // final model = await _dataSource.login(email: email, password: password);
    //
    // return model.toEntity();

    return TaskEither.tryCatch(() async {
      final model = await _dataSource.login(email: email, password: password);

      return model.toEntity();

    }, (error, stackTrace) {
      if (error is DioException) {
        return ServerFailure(error.response?.data['message'] ?? "로그인 실패");
      }
      return ServerFailure("알 수 없는 오류가 발생했습니다.");
    });
  }
}

@riverpod
AuthRepository authRepository(Ref ref) {
  final remote = ref.watch(authDataSourceProvider);
  return AuthRepositoryImpl(remote);
}