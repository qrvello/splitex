import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:repartapp/pages/home/tabs/groups_list_tab.dart';
import 'package:repartapp/widgets/side_menu.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Grupos'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_rounded),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
        ],
      ),
      body: GroupsListTab(),
      drawer: SideMenu(),
      floatingActionButton: SpeedDial(
        backgroundColor: Color(0xff006D77),
        overlayColor: Colors.black12,
        icon: Icons.add_rounded,
        activeIcon: Icons.add_rounded,
        visible: true,
        children: [
          SpeedDialChild(
            child: Icon(Icons.group_rounded),
            backgroundColor: Colors.white10,
            labelWidget: Text(
              'Crear grupo',
              style: TextStyle(fontSize: 18),
            ),
            onTap: () => Navigator.pushNamed(context, '/create_group'),
          ),
          SpeedDialChild(
            child: Icon(Icons.keyboard_arrow_right_rounded),
            backgroundColor: Colors.white10,
            labelWidget: Text(
              'Unirse a un grupo',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
