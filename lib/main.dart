import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gastos_grupales/bloc/provider.dart';
import 'package:gastos_grupales/pages/create_group_page.dart';
import 'package:gastos_grupales/pages/group_details_page.dart';
import 'package:gastos_grupales/pages/home_page.dart';
import 'package:gastos_grupales/pages/log_in_page.dart';
import 'package:gastos_grupales/pages/profile_page.dart';
import 'package:gastos_grupales/pages/sign_up_page.dart';
import 'package:gastos_grupales/user_preferences/user_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final prefs = new UserPreferences();
  await prefs.initPrefs();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return Provider(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        initialRoute: 'home',
        home: HomePage(),
        theme: ThemeData(
          primaryColor: Color(0xffE76F51),
          floatingActionButtonTheme:
              FloatingActionButtonThemeData(backgroundColor: Color(0xffE76F51)),
        ),
        routes: {
          'home': (BuildContext context) => HomePage(),
          'profile': (BuildContext context) => ProfilePage(),
          'create_group': (BuildContext context) => CreateGroupPage(),
          'login': (BuildContext context) => LoginPage(),
          'signup': (BuildContext context) => SignUpPage(),
          'group_details': (BuildContext context) => GroupDetailsPage(),
        },
        //darkTheme: ThemeData.dark(),
      ),
    );
  }
}
