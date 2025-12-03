enum AppPage {
  home,
  login;
  //...;

  String get path {
    switch (this) {
      case AppPage.home:
        return '/';
      case AppPage.login:
        return '/login';
      // case AppPage.settings:
      //   return '/settings';
    }
  }

  String get name => toString().split('.').last;
}