import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gastos_grupales/pages/create_group_page.dart';
import 'package:gastos_grupales/pages/home_page.dart';
import 'package:gastos_grupales/pages/log_in_page.dart';
import 'package:gastos_grupales/pages/profile_page.dart';
import 'package:gastos_grupales/pages/sign_up_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      initialRoute: 'home',
      home: HomePage(),
      theme: ThemeData(
        primaryColor: Color(0xff1d3557),
        floatingActionButtonTheme:
            FloatingActionButtonThemeData(backgroundColor: Color(0xff457b9d)),
      ),
      routes: {
        'home': (BuildContext context) => HomePage(),
        'profile': (BuildContext context) => ProfilePage(),
        'create_group': (BuildContext context) => CreateGroupPage(),
        'login': (BuildContext context) => LoginPage(),
        'signup': (BuildContext context) => SignUpPage(),
      },
      //darkTheme: ThemeData.dark(),
    );
  }
}
