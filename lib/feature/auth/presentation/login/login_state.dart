import 'package:boilerplate/feature/auth/domain/entities/user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_state.freezed.dart';


enum LoginStatus {
  initial,
  loading,
  success,
  failure,
}

@freezed
abstract class LoginState with _$LoginState {
  const factory LoginState({
    @Default(LoginStatus.initial) LoginStatus status,
    User? user,
    String? errorMessage,
  }) = _LoginState;
}