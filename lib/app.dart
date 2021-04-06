import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:repartapp/config/themes/dark_theme.dart';
import 'package:repartapp/config/themes/light_theme.dart';
import 'package:repartapp/providers/authentication_provider.dart';
import 'package:repartapp/config/routes/routes.dart' as router;
import 'package:provider/provider.dart';
import 'package:repartapp/providers/theme_provider.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
        ChangeNotifierProvider<AuthenticationProvider>(
            create: (_) => AuthenticationProvider(FirebaseAuth.instance)),
        StreamProvider(
            initialData: [],
            create: (context) =>
                context.read<AuthenticationProvider>().authStateChanges),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, theme, child) {
          return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'RepartApp',
            initialRoute: '/',
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: theme.isDark ? ThemeMode.dark : ThemeMode.light,
            onGenerateRoute: router.Router.generateRoute,
          );
        },
      ),
    );
  }
}
