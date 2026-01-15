import 'package:boilerplate/feature/auth/domain/entities/user.dart';
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

  void _registerAuth() {
    ref.listen<AsyncValue<User?>>(
      loginViewModelProvider.select((s) => s.authState),
          (previous, next) {
        next.whenOrNull(
          error: (error, stackTrace) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Error'),
                content: Text(error.toString()),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          },
          // 성공 시 화면 이동
          data: (user) {
            if (user != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Welcome ${user.name}!')),
              );
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _registerAuth();
    final state = ref.watch(loginViewModelProvider);
    final authState = state.authState;

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
                // 로딩 중이면 버튼 비활성화 (null)
                onPressed: authState.isLoading ? null : _onLoginPressed,
                child: authState.isLoading
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text('Login'),
              ),
            ),

            // const SizedBox(height: 16),
            // if (authState.hasError)
            //   Text(
            //     authState.error.toString(),
            //     style: const TextStyle(color: Colors.red),
            //   ),
            //
            // // 성공 메시지
            // if (state.status == LoginStatus.success && state.user != null)
            //   Padding(
            //     padding: const EdgeInsets.only(top: 16),
            //     child: Text(
            //       'Welcome, ${state.user!.name} (${state.user!.email})',
            //       style: const TextStyle(fontWeight: FontWeight.bold),
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }
}