import 'package:flutter/material.dart';

class BackgroundFormWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final purpleBackground = Container(
      height: size.height * 0.4,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            Color(0xaa0076ff).withOpacity(0.3),
            Color(0xff0076ff).withOpacity(0.6),
          ],
        ),
      ),
    );

    final circle = Container(
      width: 100.0,
      height: 100.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100.0),
        color: Color.fromRGBO(255, 255, 255, 0.05),
      ),
    );

    return Stack(
      children: [
        purpleBackground,
        Positioned(top: 90.0, left: 30.0, child: circle),
        Positioned(top: -40.0, right: -30.0, child: circle),
        Positioned(bottom: -50.0, right: -10.0, child: circle),
        Positioned(bottom: 100.0, right: 20.0, child: circle),
        Positioned(bottom: -50.0, left: -20.0, child: circle),
      ],
    );
  }
}
