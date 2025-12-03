import 'package:boilerplate/feature/auth/presentation/login/login_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      // GoRoute(
      //   path: '/home',
      //   name: 'home',
      //   builder: (context, state) => const HomePage(),
      // ),
    ],
    // 추후 redirect, auth guard 등 추가 가능
  );
}