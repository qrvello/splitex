import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  textTheme: GoogleFonts.workSansTextTheme(
    TextTheme().apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
  ),
  snackBarTheme: SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    backgroundColor: Color(0xff284B63),
    contentTextStyle: TextStyle(color: Colors.white),
    actionTextColor: Colors.white,
  ),
  appBarTheme: AppBarTheme(
    centerTitle: true,
  ),
  cardTheme: CardTheme(
    color: Colors.black,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
  fixTextFieldOutlineLabel: true,
  scaffoldBackgroundColor: Color(0xff000000),
  primaryColor: Color(0xff284b63),
  accentColor: Color(0xffd9d9d9),
  textSelectionTheme: TextSelectionThemeData(cursorColor: Color(0xff284B63)),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18.0),
      borderSide: BorderSide(
        color: Colors.white,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18.0),
      borderSide: BorderSide(
        color: Colors.white,
      ),
    ),
    labelStyle: TextStyle(color: Colors.white70),
    contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 12),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.resolveWith(
        (states) => (states.contains(MaterialState.pressed)
            ? Color(0xffd9d9d9)
            : Color(0xff284b63)),
      ),
      shape: MaterialStateProperty.resolveWith(
        (states) => RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    ),
  ),
);
