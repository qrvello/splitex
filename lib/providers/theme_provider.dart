import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ThemeProvider extends ChangeNotifier {
  bool isDark = true;
  Box box = Hive.box('theme');

  ThemeProvider() {
    bool _isDark = box.get('isDark');

    if (_isDark != null) {
      isDark = _isDark;
    } else {
      isDark = true;
    }
  }

  void switchTheme(bool value) async {
    isDark = value;

    box.put('isDark', value);

    notifyListeners();
  }
}
