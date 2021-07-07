import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:splitex/domain/cubits/auth/auth_cubit.dart';
import 'package:splitex/ui/pages/home/home_page.dart';

class GoogleSignUpButtonWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(4),
      child: ElevatedButton.icon(
        onPressed: () async {
          BlocProvider.of<AuthCubit>(context).signInWithGoogle().then(
                (_) => Get.offAll(() => HomePage()),
              );
        },
        icon: const FaIcon(
          FontAwesomeIcons.google,
          color: Colors.white,
          size: 18,
        ),
        label: const Text(
          'Inicia sesión con Google',
          style: TextStyle(color: Colors.white),
        ),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith(
            (states) => states.contains(MaterialState.pressed)
                ? const Color(0xffef233c).withOpacity(0.3)
                : const Color(0xffef233c).withOpacity(0.87),
          ),
        ),
      ),
    );
  }
}
