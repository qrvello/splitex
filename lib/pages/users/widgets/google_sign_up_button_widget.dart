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
      child: ElevatedButton.icon(
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
          color: Colors.white,
          size: 18,
        ),
        label: Text(
          'Inicia sesión con Google',
          style: TextStyle(color: Colors.white),
        ),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith(
            (states) => (states.contains(MaterialState.pressed)
                ? Color(0xffef233c).withOpacity(0.3)
                : Color(0xffef233c).withOpacity(0.87)),
          ),
        ),
      ),
    );
  }
}
