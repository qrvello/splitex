import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gastos_grupales/provider/google_sign_in.dart';
import 'package:provider/provider.dart';

class GoogleSignUpButtonWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.all(4),
        child: OutlineButton.icon(
          onPressed: () {
            final provider =
                Provider.of<GoogleSignInProvider>(context, listen: false);
            provider.login();
          },
          icon: FaIcon(FontAwesomeIcons.google, color: Colors.red),
          label: Text('Inicia sesión con Google'),
          shape: StadiumBorder(),
          borderSide: BorderSide(color: Colors.black),
          padding: EdgeInsets.symmetric(horizontal: 20),
          textColor: Colors.black,
        ),
      );
}
