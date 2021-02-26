import 'package:flutter/material.dart';
import 'package:gastos_grupales/models/group_model.dart';

class GroupDetailsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final GroupModel group = ModalRoute.of(context).settings.arguments;

    return Container(
      child: Stack(
        children: [
          _background(),
          Scaffold(
            backgroundColor: Colors.transparent,
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: Text(group.name),
            ),
          ),
        ],
      ),
    );
  }

  Widget _background() {
    final gradient = Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: FractionalOffset(0.0, 0.1),
          end: FractionalOffset(0.0, 1.0),
          colors: [
            Color.fromRGBO(52, 54, 101, 1.0),
            Color.fromRGBO(35, 37, 57, 1.0),
          ],
        ),
      ),
    );

    final box = Transform.rotate(
      angle: -3.14 / 4.0,
      child: Container(
        height: 360,
        width: 360,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(90.0),
            gradient:
                LinearGradient(colors: [Color(0xff2a9d8f), Color(0xff264653)])),
      ),
    );

    return Stack(
      children: [
        gradient,
        Positioned(
          top: -100,
          left: -20,
          child: box,
        )
      ],
    );
  }
}
