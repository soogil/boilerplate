import 'package:boilerplate/feature/auth/presentation/login/login_state.dart';
import 'package:boilerplate/feature/auth/presentation/login/login_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController(text: 'test@test.com');
  final _passwordController = TextEditingController(text: '1234');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLoginPressed() async {
    final vm = ref.read(loginViewModelProvider.notifier);
    await vm.login(
      email: _emailController.text,
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login (Riverpod + MVVM + Freezed)'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 이메일
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),
            const SizedBox(height: 12),

            // 비밀번호
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
            ),
            const SizedBox(height: 24),

            // 로그인 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: state.status == LoginStatus.loading
                    ? null
                    : _onLoginPressed,
                child: state.status == LoginStatus.loading
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text('Login'),
              ),
            ),

            const SizedBox(height: 16),

            // 에러 메시지
            if (state.status == LoginStatus.failure &&
                state.errorMessage != null)
              Text(
                state.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),

            // 성공 메시지
            if (state.status == LoginStatus.success && state.user != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  'Welcome, ${state.user!.name} (${state.user!.email})',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}