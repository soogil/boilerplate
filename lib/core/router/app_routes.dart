import 'package:boilerplate/core/router/app_pages.dart';
import 'package:boilerplate/feature/auth/presentation/login/login_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';


// final authProvider = StateProvider<bool>((ref) => false);

final routerProvider = Provider<GoRouter>((ref) {
  // final isLoggedIn = ref.watch(authProvider);

  return GoRouter(
    initialLocation: AppPage.home.path,
    redirect: (context, state) {
      if (state.uri.path == AppPage.home.path) {
        return AppPage.home.path;
      }
      return null;
    },
    routes: [
      // GoRoute(
      //   path: AppPage.home.path,
      //   name: AppPage.home.name,
      //   builder: (context, state) => const HomePage(),
      // ),
      GoRoute(
        path: AppPage.login.path,
        name: AppPage.login.name,
        builder: (context, state) => const LoginPage(),
      ),
    ],
  );
});