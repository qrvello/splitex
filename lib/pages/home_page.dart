import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gastos_grupales/widgets/groups_list_widget.dart';
import 'package:gastos_grupales/widgets/side_menu.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            isScrollable: false,
            tabs: [
              Tab(text: 'Amigos'),
              Tab(text: 'Grupos'),
              Tab(text: 'Actividad'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Icon(Icons.directions_car),
            GroupsLists(),
            Icon(Icons.directions_bike),
          ],
        ),
        drawer: SideMenu(),
        floatingActionButton: FloatingActionButton(
          onPressed: () => showDialog(
            context: context,
            builder: (BuildContext context) => _dialog(context),
          ),
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _dialog(context) {
    return CupertinoAlertDialog(
      actions: <Widget>[
        CupertinoDialogAction(
          onPressed: () {
            Navigator.of(context).pushNamed('/create_group');
          },
          child: Text("Crear grupo"),
        ),
        CupertinoDialogAction(
          child: Text("Añadir gasto"),
          onPressed: () {
            Navigator.of(context).pushNamed('/create_group');
          },
        ),
        CupertinoDialogAction(
          child: Text(
            "Cancelar",
            style: TextStyle(color: Colors.red),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
