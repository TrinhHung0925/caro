import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'screen/home/home_view.dart';
import 'screen/caro/caro_view.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  GetPageRoute page(RouteSettings settings, Widget Function() genPage,
      [Bindings? bindings]) {
    var page = GetPage(
      name: settings.name!,
      page: genPage,
      arguments: settings.arguments,
      binding: bindings,
    );
    return PageRedirect(route: page, unknownRoute: page).page();
  }

  switch (settings.name) {
    case '/home':
      return page(settings, () => HomeView());
    case '/caro':
      return page(settings, () => CaroView());
    default:
      return page(
        settings,
        () => Scaffold(
          appBar: AppBar(title: const Text('404')),
          body: Center(child: Text('No route defined for ${settings.name}')),
        ),
      );
  }
}

enum AppPage {
  home,
  caro,
}

extension AppPageExtension on AppPage {
  String get routeName {
    switch (this) {
      case AppPage.home:
        return '/${AppPage.home.name}';
      case AppPage.caro:
        return '/${AppPage.caro.name}';
    }
  }
}
