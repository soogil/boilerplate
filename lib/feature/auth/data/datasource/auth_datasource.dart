import 'package:boilerplate/core/api/dio.dart';
import 'package:boilerplate/feature/auth/data/models/user_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_datasource.g.dart';

abstract class AuthDataSource {
  Future<UserModel> login({
    required String email,
    required String password,
  });
}

/// 예제용 Fake 구현 (테스트/샘플용)
class AuthDatasourceImpl implements AuthDataSource {
  AuthDatasourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );

    final data = response.data as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }
}

@riverpod
AuthDataSource authDataSource(Ref ref) {
  final dio = ref.watch(dioClientProvider);
  return AuthDatasourceImpl(dio);
}