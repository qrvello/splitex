import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:repartapp/widgets/background_form_widget.dart';
import 'package:repartapp/widgets/form_sign_up_widget.dart';

class SignUpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          return Stack(
            children: <Widget>[
              BackgroundFormWidget(),
              FormSignUp(),
            ],
          );
        },
      ),
    );
  }
}
