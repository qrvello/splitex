import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:repartapp/providers/google_sign_in_provider.dart';
import 'package:provider/provider.dart';

class GoogleSignUpButtonWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GoogleSignInProvider>(context, listen: false);

    return Container(
      width: 250,
      padding: EdgeInsets.all(4),
      child: OutlinedButton.icon(
        onPressed: () async {
          await provider
              .login()
              .then((value) => Navigator.of(context).pushNamed('/'))
              .catchError((onError) {
            print(onError);
          });
        },
        icon: FaIcon(
          FontAwesomeIcons.google,
          color: Color(0xffe76f51),
          size: 18,
        ),
        label: Text(
          'Inicia sesión con Google',
          style: TextStyle(color: Colors.black87),
        ),
        style: ButtonStyle(
          shape: MaterialStateProperty.resolveWith(
            (Set<MaterialState> states) => StadiumBorder(),
          ),
          side: MaterialStateProperty.resolveWith(
            (Set<MaterialState> states) => BorderSide(color: Colors.black38),
          ),
        ),
      ),
    );
  }
}
