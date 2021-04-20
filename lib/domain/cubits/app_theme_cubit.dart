import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

class AppThemeCubit extends Cubit<bool> {
  AppThemeCubit() : super(true);

  Box box = Hive.box('theme');

  void init() {
    bool isDark = box.get('isDark');

    if (isDark != null) {
      emit(isDark);
    }
  }

  void switchTheme(bool isDark) {
    box.put('isDark', isDark);

    emit(isDark);
  }
}
