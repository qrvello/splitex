import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gastos_grupales/providers/google_sign_in_provider.dart';
import 'package:provider/provider.dart';

class GoogleSignUpButtonWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.all(4),
        child: OutlineButton.icon(
          onPressed: () async {
            final provider =
                Provider.of<GoogleSignInProvider>(context, listen: false);
            await provider
                .login()
                .then((value) => Navigator.of(context).pushNamed('/home'));

            //Navigator.of(context).pushNamed('home');
          },
          icon: FaIcon(FontAwesomeIcons.google, color: Colors.red),
          label: Text(
            'Inicia sesión con Google',
            style: TextStyle(color: Colors.black87),
          ),
          shape: StadiumBorder(),
          borderSide: BorderSide(color: Colors.black54),
          padding: EdgeInsets.symmetric(horizontal: 20),
          textColor: Colors.black,
        ),
      );
}
