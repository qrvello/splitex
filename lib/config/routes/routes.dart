import 'package:flutter/material.dart';

import 'package:splitex/ui/pages/home/home_page.dart';
import 'package:splitex/ui/pages/users/profile_page.dart';

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    if (settings.name == '/') {
      return MaterialPageRoute(builder: (_) => HomePage());
    }
    if (settings.name == '/profile') {
      return MaterialPageRoute(builder: (_) => ProfilePage());
    }

    return MaterialPageRoute(
      builder: (_) => Scaffold(
        body: Center(
          child: Text('No route defined for ${settings.name}'),
        ),
      ),
    );
  }
}
