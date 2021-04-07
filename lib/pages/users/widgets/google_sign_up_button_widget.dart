import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:repartapp/controllers/authentication_controller.dart';

class GoogleSignUpButtonWidget extends StatelessWidget {
  final AuthController authController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      padding: EdgeInsets.all(4),
      child: ElevatedButton.icon(
        onPressed: () async {
          await authController.signInWithGoogle();
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
