import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gastos_grupales/provider/google_sign_in.dart';
import 'package:gastos_grupales/widgets/background_form_widget.dart';
import 'package:gastos_grupales/widgets/form_sign_up_widget.dart';
import 'package:provider/provider.dart';

class SignUpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider(
        create: (context) => GoogleSignInProvider(),
        child: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            return Stack(
              children: <Widget>[
                BackgroundForm(),
                FormSignUp(),
              ],
            );
          },
        ),
      ),
    );
  }
}
