import 'package:flutter/material.dart';
import 'package:gastos_grupales/pages/profile_page.dart';

class SideMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Drawer(
      child: ListView(
        children: <Widget>[
          new UserAccountsDrawerHeader(
            accountName: Text('Santiago Curvello'),
            accountEmail: Text('santicurvello@gmail.com'),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.person),
              title: Text('Mi perfil'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.share),
              title: Text('Invitar a un amigo'),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.star_rate),
              title: Text('Puntúanos'),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.info),
              title: Text('Términos y privacidad'),
            ),
          ),
        ],
      ),
    );
  }
}
