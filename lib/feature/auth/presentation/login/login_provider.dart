import 'package:boilerplate/feature/auth/data/datasource/auth_datasource.dart';
import 'package:boilerplate/feature/auth/data/repositories/auth_repository_impl.dart';
import 'package:boilerplate/feature/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'login_state.dart';
import 'login_view_model.dart';

/// DataSource Provider
final authDataSourceProvider = Provider<AuthDataSource>((ref) {
  // 실서비스에서는 Dio/http client를 주입
  return FakeAuthDataSource();
});

/// Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dataSource = ref.watch(authDataSourceProvider);
  return AuthRepositoryImpl(dataSource);
});

/// Login ViewModel Provider
final loginViewModelProvider =
StateNotifierProvider<LoginViewModel, LoginState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return LoginViewModel(repo);
});
