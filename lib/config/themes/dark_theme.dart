import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  textTheme: GoogleFonts.workSansTextTheme(
    TextTheme().apply(
      bodyColor: Colors.white.withOpacity(0.87),
      displayColor: Colors.white.withOpacity(0.87),
    ),
  ),
  snackBarTheme: SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    backgroundColor: Color(0xff284B63),
    contentTextStyle: TextStyle(color: Colors.white.withOpacity(0.87)),
    actionTextColor: Colors.white.withOpacity(0.87),
  ),
  appBarTheme: AppBarTheme(
    centerTitle: true,
  ),
  cardTheme: CardTheme(
    color: Color(0xff001d3d),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
  fixTextFieldOutlineLabel: true,
  scaffoldBackgroundColor: Color(0xff121212),
  primaryColor: Color(0xff001d3d),
  accentColor: Color(0xffd9d9d9),
  textSelectionTheme:
      TextSelectionThemeData(cursorColor: Colors.white.withOpacity(0.87)),
  inputDecorationTheme: InputDecorationTheme(
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(24.0),
      borderSide: BorderSide(
        color: Color(0xff284b63),
        width: 3,
      ),
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(24.0),
      borderSide: BorderSide(
        color: Colors.white.withOpacity(0.87),
        width: 1,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(24.0),
      borderSide: BorderSide(
        color: Colors.white.withOpacity(0.87),
        width: 1,
      ),
    ),
    labelStyle: TextStyle(color: Colors.white.withOpacity(0.87)),
    contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 12),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.resolveWith(
        (states) => (states.contains(MaterialState.pressed)
            ? Color(0xffd9d9d9)
            : Color(0xff001d3d)),
      ),
      shape: MaterialStateProperty.resolveWith(
        (states) => RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    ),
  ),
);
