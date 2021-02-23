import 'package:flutter/material.dart';
import 'package:gastos_grupales/models/group_model.dart';

class GroupDetailsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final GroupModel group = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(group.name),
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('No debés ninguna cuenta en este grupo.'),
          ],
        ),
      ),
    );
  }
}
