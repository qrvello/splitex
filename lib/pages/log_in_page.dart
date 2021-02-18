import 'package:flutter/material.dart';
import 'package:gastos_grupales/widgets/background_form_widget.dart';
import 'package:gastos_grupales/widgets/form_log_in_widget.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          BackgroundForm(),
          FormLogIn(),
        ],
      ),
    );
  }
}
