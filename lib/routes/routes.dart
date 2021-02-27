import 'package:flutter/material.dart';
import 'package:gastos_grupales/pages/add_expense_page.dart';
import 'package:gastos_grupales/pages/groups/create_group_page.dart';
import 'package:gastos_grupales/pages/groups/details_group_page.dart';
import 'package:gastos_grupales/pages/home/home_page.dart';
import 'package:gastos_grupales/pages/users/log_in_page.dart';
import 'package:gastos_grupales/pages/users/profile_page.dart';
import 'package:gastos_grupales/pages/users/sign_up_page.dart';

final routes = <String, WidgetBuilder>{
  '/home': (BuildContext context) => HomePage(),
  '/profile': (BuildContext context) => ProfilePage(),
  '/create_group': (BuildContext context) => CreateGroupPage(),
  '/login': (BuildContext context) => LoginPage(),
  '/signup': (BuildContext context) => SignUpPage(),
  '/group_details': (BuildContext context) => DetailsGroupPage(),
  '/add_expense': (BuildContext context) => AddExpensePage(),
};
