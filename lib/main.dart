import 'dart:io';
import 'package:intl/date_symbol_data_local.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:splitex/domain/models/expense_model.dart';
import 'package:splitex/domain/models/group_model.dart';
import 'package:splitex/domain/models/member_model.dart';
import 'package:splitex/domain/models/transaction_model.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('es_ES');

  Intl.defaultLocale = 'es_ES';

  await Firebase.initializeApp();

  await MobileAds.instance.initialize();

  await FirebaseDatabase().setPersistenceEnabled(true);

  await FirebaseDatabase().setPersistenceCacheSizeBytes(10000000);

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
