import 'package:flutter/material.dart';

import 'package:repartapp/pages/groups/add_expense_page.dart';
import 'package:repartapp/pages/groups/balance_debts_page.dart';
import 'package:repartapp/pages/groups/create_group_page.dart';
import 'package:repartapp/pages/groups/details_group_page.dart';
import 'package:repartapp/pages/home/home_page.dart';
import 'package:repartapp/pages/users/log_in_page.dart';
import 'package:repartapp/pages/users/notifications_page.dart';
import 'package:repartapp/pages/users/profile_page.dart';
import 'package:repartapp/pages/users/sign_up_page.dart';

//final routes = <String, WidgetBuilder>{
//  '/home': (_) => HomePage(),
//  '/profile': (_) => ProfilePage(),
//  '/create_group': (_) => CreateGroupPage(),
//  '/login': (_) => LoginPage(),
//  '/signup': (_) => SignUpPage(),
//  '/add_expense': (_) => AddExpensePage(),
//  '/notifications': (_) => NotificationsPage(),
//  '/group_details': (_) => DetailsGroupPage(GroupModel group, List<Member> members),
//  '/balance_debts': (_) => BalanceDebtsPage(),
//};

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case '/home':
        return MaterialPageRoute(builder: (_) => HomePage());
      case '/profile':
        return MaterialPageRoute(builder: (_) => ProfilePage());
      case '/create_group':
        return MaterialPageRoute(builder: (_) => CreateGroupPage());
      case '/login':
        return MaterialPageRoute(builder: (_) => LoginPage());
      case '/signup':
        return MaterialPageRoute(builder: (_) => SignUpPage());
      case '/add_expense':
        return MaterialPageRoute(builder: (_) => AddExpensePage(group: args));
      case '/notifications':
        return MaterialPageRoute(builder: (_) => NotificationsPage());
      case '/group_details':
        return MaterialPageRoute(builder: (_) => DetailsGroupPage(group: args));
      case '/balance_debts':
        return MaterialPageRoute(builder: (_) => BalanceDebtsPage(group: args));
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
