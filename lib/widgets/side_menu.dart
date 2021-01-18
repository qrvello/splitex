import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gastos_grupales/pages/profile_page.dart';
import 'package:gastos_grupales/widgets/drawer_header_widget.dart';

class SideMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      child: ListView(
        children: <Widget>[
          user != null
              ? DrawerHeaderWidget()
              : DrawerHeader(
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 50, horizontal: 40),
                    child: OutlineButton(
                      padding: EdgeInsets.symmetric(),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfilePage()),
                      ),
                      child: Text('Iniciar sesión'),
                      shape: StadiumBorder(),
                      borderSide: BorderSide(color: Colors.black),
                      textColor: Colors.black,
                    ),
                  ),
                ),
          ListTile(
            leading: Icon(Icons.share),
            title: Text('Invitar a un amigo'),
          ),
          ListTile(
            leading: Icon(Icons.star_rate),
            title: Text('Puntúanos'),
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('Términos y privacidad'),
          ),
        ],
      ),
    );
  }
}
