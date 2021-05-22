import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:splitex/domain/models/expense_model.dart';
import 'package:splitex/domain/models/group_model.dart';
import 'package:splitex/domain/models/member_model.dart';
import 'package:splitex/domain/models/transaction_model.dart';
import 'app.dart';
import 'domain/simple_bloc_observer.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  Bloc.observer = SimpleBlocObserver();

  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null);
  Intl.defaultLocale = 'es_ES';

  await Firebase.initializeApp();

  await FirebaseDatabase().setPersistenceEnabled(true);

  await FirebaseDatabase().setPersistenceCacheSizeBytes(10000000);

  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

  //FirebaseFunctions.instance
  //    .useFunctionsEmulator(origin: 'http://localhost:5001');

  final Directory appDocumentDir = await getApplicationDocumentsDirectory();

  Hive.init(appDocumentDir.path);

  Hive.registerAdapter(GroupAdapter());
  Hive.registerAdapter(MemberAdapter());
  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(ExpenseAdapter());
  await Hive.openBox('theme');
  await Hive.openBox('user');
  await Hive.openBox<Group>('groups');

  runApp(MyApp());
}
