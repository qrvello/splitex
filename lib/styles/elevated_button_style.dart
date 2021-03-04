import 'package:flutter/material.dart';

final elevatedButtonStyle = ButtonStyle(
  backgroundColor: MaterialStateProperty.resolveWith(
    (states) => (states.contains(MaterialState.pressed)
        ? Color(0xff2a9d8f)
        : Color(0xaa2a9d8f)),
  ),
  shape: MaterialStateProperty.resolveWith(
    (states) => RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18.0),
    ),
  ),
);
