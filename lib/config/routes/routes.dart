import 'package:flutter/material.dart';

import 'package:repartapp/pages/groups/add_expense_page.dart';
import 'package:repartapp/pages/groups/balance_debts_page.dart';
import 'package:repartapp/pages/groups/details_group_page.dart';
import 'package:repartapp/pages/home/home_page.dart';
import 'package:repartapp/pages/users/log_in_page.dart';
import 'package:repartapp/pages/users/profile_page.dart';
import 'package:repartapp/pages/users/sign_up_page.dart';

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => HomePage());
      case '/profile':
        return MaterialPageRoute(builder: (_) => ProfilePage());
      case '/login':
        return MaterialPageRoute(builder: (_) => LoginPage());
      case '/signup':
        return MaterialPageRoute(builder: (_) => SignUpPage());
      case '/add_expense':
        return MaterialPageRoute(
          builder: (_) => AddExpensePage(group: args),
        );
      case '/group_details':
        return MaterialPageRoute(
          builder: (_) => DetailsGroupPage(group: args),
        );
      case '/balance_debts':
        return MaterialPageRoute(
          builder: (_) => BalanceDebtsPage(group: args),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
