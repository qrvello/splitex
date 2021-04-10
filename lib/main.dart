import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:repartapp/controllers/authentication_controller.dart';
import 'package:repartapp/locator.dart';
import 'package:repartapp/models/user_model.dart';
import 'package:repartapp/providers/groups_provider.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseDatabase().setPersistenceEnabled(true);

  FirebaseDatabase().setPersistenceCacheSizeBytes(10000000);
  setup();

  final Directory appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
  await Hive.openBox('theme');
  await Hive.openBox('user');
  Hive.registerAdapter(UserAdapter());

  Get.put(AuthController());
  Get.put(GroupsProvider());

  runApp(MyApp());
}
