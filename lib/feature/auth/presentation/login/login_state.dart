import 'package:boilerplate/feature/auth/domain/entities/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    @Default(AsyncValue.data(null)) AsyncValue<User?> authState,
  }) = _LoginState;
}