import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  textTheme: GoogleFonts.montserratTextTheme().apply(
    bodyColor: Colors.white.withOpacity(0.87),
    displayColor: Colors.white.withOpacity(0.87),
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: Color(0xff0076ff),
    behavior: SnackBarBehavior.fixed,
    contentTextStyle: TextStyle(color: Colors.white.withOpacity(0.87)),
    actionTextColor: Colors.white.withOpacity(0.87),
  ),
  appBarTheme: AppBarTheme(
    shadowColor: Colors.transparent,
    backgroundColor: Color(0xff212529),
    textTheme: GoogleFonts.montserratTextTheme(
      TextTheme(
        headline6: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      ),
    ).apply(
      bodyColor: Colors.white.withOpacity(0.87),
      displayColor: Colors.white.withOpacity(0.87),
    ),
    centerTitle: true,
  ),
  cardTheme: CardTheme(
    color: Color(0xff212529),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
  fixTextFieldOutlineLabel: true,
  scaffoldBackgroundColor: Color(0xff262e36),
  primaryColor: Color(0xff0076ff),
  focusColor: Color(0xff0076ff),
  accentColor: Color(0xff0076ff),
  textSelectionTheme: TextSelectionThemeData(cursorColor: Color(0xff0076ff)),
  inputDecorationTheme: InputDecorationTheme(
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16.0),
      borderSide: BorderSide(
        color: Color(0xff0076ff),
        width: 2,
      ),
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16.0),
      borderSide: BorderSide(
        color: Colors.white.withOpacity(0.87),
        width: 1,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16.0),
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
            ? Color(0xff0076ff).withOpacity(0.3)
            : Color(0xff0076ff)),
      ),
      shape: MaterialStateProperty.resolveWith(
        (states) => RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    ),
  ),
  dialogTheme: DialogTheme(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(12.0),
      ),
    ),
    backgroundColor: Color(0xff212529),
  ),
);
