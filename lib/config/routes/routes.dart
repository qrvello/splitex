import 'package:flutter/material.dart';

//import 'package:repartapp/ui/pages/groups/add_expense_page.dart';
import 'package:repartapp/ui/pages/groups/balance_debts_page.dart';
import 'package:repartapp/ui/pages/home/home_page.dart';
import 'package:repartapp/ui/pages/users/profile_page.dart';

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    if (settings.name == '/') {
      return MaterialPageRoute(builder: (_) => HomePage());
    }
    if (settings.name == '/profile') {
      return MaterialPageRoute(builder: (_) => ProfilePage());
    }
    //if (settings.name == '/add_expense') {
    //  final args = settings.arguments as AddExpensePage;

    //  return MaterialPageRoute(
    //    builder: (_) => AddExpensePage(group: args.group, online: args.online),
    //  );
    //}
    if (settings.name == '/balance_debts') {
      final args = settings.arguments;

      return MaterialPageRoute(
        builder: (_) => BalanceDebtsPage(group: args),
      );
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
