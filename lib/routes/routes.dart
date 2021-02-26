import 'package:flutter/material.dart';
import 'package:gastos_grupales/pages/create_group_page.dart';
import 'package:gastos_grupales/pages/group_details_page.dart';
import 'package:gastos_grupales/pages/home_page.dart';
import 'package:gastos_grupales/pages/log_in_page.dart';
import 'package:gastos_grupales/pages/profile_page.dart';
import 'package:gastos_grupales/pages/sign_up_page.dart';

final routes = <String, WidgetBuilder>{
  '/home': (BuildContext context) => HomePage(),
  '/profile': (BuildContext context) => ProfilePage(),
  '/create_group': (BuildContext context) => CreateGroupPage(),
  '/login': (BuildContext context) => LoginPage(),
  '/signup': (BuildContext context) => SignUpPage(),
  '/group_details': (BuildContext context) => GroupDetailsPage()
};
