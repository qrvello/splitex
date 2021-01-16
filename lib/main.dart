import 'package:flutter/material.dart';

import 'package:gastos_grupales/pages/home_page.dart';

void main() {
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
      darkTheme: ThemeData.dark(),
    );
  }
}
