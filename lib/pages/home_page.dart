import 'package:flutter/material.dart';
import 'package:gastos_grupales/pages/create_group_page.dart';
import 'package:gastos_grupales/widgets/side_menu.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: SideMenu(),
      floatingActionButton: new FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CreateGroupPage()),
        ),
        child: Icon(Icons.add),
      ),
    );
  }
}
