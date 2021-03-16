import 'package:flutter/material.dart';

import 'package:repartapp/pages/add_expense_page.dart';
import 'package:repartapp/pages/groups/create_group_page.dart';
import 'package:repartapp/pages/home/home_page.dart';
import 'package:repartapp/pages/users/log_in_page.dart';
import 'package:repartapp/pages/users/notifications_page.dart';
import 'package:repartapp/pages/users/profile_page.dart';
import 'package:repartapp/pages/users/sign_up_page.dart';

final routes = <String, WidgetBuilder>{
  '/home': (_) => HomePage(),
  '/profile': (_) => ProfilePage(),
  '/create_group': (_) => CreateGroupPage(),
  '/login': (_) => LoginPage(),
  '/signup': (_) => SignUpPage(),
  '/add_expense': (_) => AddExpensePage(),
  '/notifications': (_) => NotificationsPage(),
};
