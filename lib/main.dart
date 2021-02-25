import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gastos_grupales/user_preferences/user_preferences.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final prefs = new UserPreferences();
  await prefs.initPrefs();

  runApp(MyApp());
}
