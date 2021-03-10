import 'package:flutter/material.dart';

import 'package:repartapp/pages/add_expense_page.dart';
import 'package:repartapp/pages/groups/create_group_page.dart';
import 'package:repartapp/pages/home/home_page.dart';
import 'package:repartapp/pages/users/log_in_page.dart';
import 'package:repartapp/pages/users/profile_page.dart';
import 'package:repartapp/pages/users/sign_up_page.dart';

final routes = <String, WidgetBuilder>{
  '/home': (BuildContext context) => HomePage(),
  '/profile': (BuildContext context) => ProfilePage(),
  '/create_group': (BuildContext context) => CreateGroupPage(),
  '/login': (BuildContext context) => LoginPage(),
  '/signup': (BuildContext context) => SignUpPage(),
  '/add_expense': (BuildContext context) => AddExpensePage(),
};
