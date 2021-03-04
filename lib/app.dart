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
            textTheme: GoogleFonts.workSansTextTheme(),
            primaryColor: Color(0xff2a9d8f),
            floatingActionButtonTheme: FloatingActionButtonThemeData(
                backgroundColor: Color(0xff2a9d8f)),
          ),
          routes: routes
          //darkTheme: ThemeData.dark(),
          ),
    );
  }
}
