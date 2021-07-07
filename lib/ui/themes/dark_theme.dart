import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  textTheme: GoogleFonts.montserratTextTheme().apply(
    bodyColor: Colors.white.withOpacity(0.87),
    displayColor: Colors.white.withOpacity(0.87),
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: const Color(0xff0076ff),
    behavior: SnackBarBehavior.fixed,
    contentTextStyle: TextStyle(color: Colors.white.withOpacity(0.87)),
    actionTextColor: Colors.white.withOpacity(0.87),
  ),
  appBarTheme: AppBarTheme(
    shadowColor: Colors.transparent,
    backgroundColor: const Color(0xff212529),
    textTheme: GoogleFonts.montserratTextTheme(
      const TextTheme(
        headline6: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      ),
    ).apply(
      bodyColor: Colors.white.withOpacity(0.87),
      displayColor: Colors.white.withOpacity(0.87),
    ),
    centerTitle: true,
  ),
  cardTheme: CardTheme(
    color: const Color(0xff212529),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
  fixTextFieldOutlineLabel: true,
  scaffoldBackgroundColor: const Color(0xff262e36),
  primaryColor: const Color(0xff0076ff),
  focusColor: const Color(0xff0076ff),
  accentColor: const Color(0xff0076ff),
  textSelectionTheme:
      const TextSelectionThemeData(cursorColor: Color(0xff0076ff)),
  inputDecorationTheme: InputDecorationTheme(
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16.0),
      borderSide: const BorderSide(
        color: Color(0xff0076ff),
        width: 2,
      ),
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16.0),
      borderSide: BorderSide(
        color: Colors.white.withOpacity(0.87),
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16.0),
      borderSide: BorderSide(
        color: Colors.white.withOpacity(0.87),
      ),
    ),
    labelStyle: TextStyle(color: Colors.white.withOpacity(0.87)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.resolveWith(
        (states) => states.contains(MaterialState.pressed)
            ? const Color(0xff0076ff).withOpacity(0.3)
            : const Color(0xff0076ff),
      ),
      shape: MaterialStateProperty.resolveWith(
        (states) => RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    ),
  ),
  dialogTheme: const DialogTheme(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(12.0),
      ),
    ),
    backgroundColor: Color(0xff212529),
  ),
);
