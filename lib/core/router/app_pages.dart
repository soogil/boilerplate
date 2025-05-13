enum AppPage {
  home;
  //...;

  String get path {
    switch (this) {
      case AppPage.home:
        return '/';
      // case AppPage.settings:
      //   return '/settings';
    }
  }

  String get name => toString().split('.').last;
}