import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:repartapp/config/themes/dark_theme.dart';
import 'package:repartapp/config/themes/light_theme.dart';
import 'package:repartapp/providers/authentication_provider.dart';
import 'package:repartapp/providers/google_sign_in_provider.dart';
import 'package:repartapp/config/routes/routes.dart' as router;
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
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
                context.read<AuthenticationProvider>().authStateChanges),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'RepartApp',
        initialRoute: '/home',
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.system,
        onGenerateRoute: router.Router.generateRoute,
        //darkTheme: ThemeData.dark(),
      ),
    );
  }
}
