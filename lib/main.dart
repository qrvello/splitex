import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'app.dart';
import 'domain/models/user_model.dart';
import 'domain/simple_bloc_observer.dart';

Future<void> main() async {
  Bloc.observer = SimpleBlocObserver();

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  FirebaseDatabase().setPersistenceEnabled(true);

  FirebaseDatabase().setPersistenceCacheSizeBytes(10000000);

  final Directory appDocumentDir = await getApplicationDocumentsDirectory();

  Hive.init(appDocumentDir.path);

  await Hive.openBox('theme');
  await Hive.openBox('user');

  Hive.registerAdapter(UserAdapter());

  runApp(MyApp());
}
