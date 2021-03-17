import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  textTheme: GoogleFonts.workSansTextTheme(),
  primaryColor: Color(0xff83C5BE),
  accentColor: Color(0xff83C5BE),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Color(0xff83C5BE),
  ),
);
