import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gastos_grupales/pages/home/tabs/friends_list_tab.dart';
import 'package:gastos_grupales/pages/home/tabs/groups_list_tab.dart';
import 'package:gastos_grupales/widgets/side_menu.dart';
import 'package:google_fonts/google_fonts.dart';

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
              Tab(
                child: Text(
                  'Amigos',
                  style: GoogleFonts.workSans(fontWeight: FontWeight.w600),
                ),
              ),
              Tab(
                child: Text(
                  'Grupos',
                  style: GoogleFonts.workSans(fontWeight: FontWeight.w600),
                ),
              ),
              Tab(
                child: Text(
                  'Actividad',
                  style: GoogleFonts.workSans(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            FriendsListTab(),
            GroupsListTab(),
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
    return AlertDialog(
      actions: <Widget>[
        TextButton(
          child: Text("Crear grupo"),
          onPressed: () {
            Navigator.of(context).pushNamed('/create_group');
          },
        ),
        TextButton(
          child: Text("Añadir gasto"),
          onPressed: () {
            Navigator.of(context).pushNamed('/create_group');
          },
        ),
        TextButton(
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
