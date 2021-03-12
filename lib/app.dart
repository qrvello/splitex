import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:repartapp/providers/authentication_provider.dart';
import 'package:repartapp/providers/google_sign_in_provider.dart';
import 'package:repartapp/routes/routes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<GoogleSignInProvider>(
            create: (_) => GoogleSignInProvider()),
        ChangeNotifierProvider<AuthenticationProvider>(
            create: (_) => AuthenticationProvider(FirebaseAuth.instance)),
        StreamProvider(
            initialData: [],
            create: (context) =>
                context.read<AuthenticationProvider>().authStateChanges)
      ],
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'DivideGastos',
          initialRoute: '/home',
          theme: ThemeData(
            brightness: Brightness.light,
            textTheme: GoogleFonts.workSansTextTheme(),
            primaryColor: Color(0xff83C5BE),
            accentColor: Color(0xff83C5BE),
            floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: Color(0xff83C5BE),
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            textTheme: GoogleFonts.workSansTextTheme(TextTheme().apply(
              bodyColor: Colors.white,
              displayColor: Colors.white,
            )),
            primaryColor: Color(0xff006D77),
            accentColor: Color(0xff83C5BE),
          ),
          themeMode: ThemeMode.dark,
          routes: routes
          //darkTheme: ThemeData.dark(),
          ),
    );
  }
}
