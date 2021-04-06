import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:repartapp/locator.dart';

import 'app.dart';

Future<void> main() async {
  setup();

  WidgetsFlutterBinding.ensureInitialized();

  final Directory appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
  await Hive.openBox('theme');
  await Firebase.initializeApp();

  FirebaseDatabase().setPersistenceEnabled(true);
  FirebaseDatabase().setPersistenceCacheSizeBytes(10000000);

  runApp(MyApp());
}
