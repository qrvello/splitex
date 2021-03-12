import 'package:flutter/material.dart';

final elevatedButtonStyle = ButtonStyle(
  backgroundColor: MaterialStateProperty.resolveWith(
    (states) => (states.contains(MaterialState.pressed)
        ? Color(0xff83C5BE)
        : Color(0xff006D77)),
  ),
  shape: MaterialStateProperty.resolveWith(
    (states) => RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18.0),
    ),
  ),
);
