import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gastos_grupales/provider/google_sign_in.dart';
import 'package:gastos_grupales/widgets/drawer_header_widget.dart';
import 'package:provider/provider.dart';

class SideMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          _drawer(context),
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

  Widget _drawer(context) {
    return ChangeNotifierProvider(
      create: (context) => GoogleSignInProvider(),
      child: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (FirebaseAuth.instance.currentUser == null) {
            return DrawerHeader(
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 50, horizontal: 40),
                child: OutlineButton(
                  padding: EdgeInsets.symmetric(),
                  onPressed: () => Navigator.of(context).pushNamed('login'),
                  child: Text('Iniciar sesión'),
                  shape: StadiumBorder(),
                  borderSide: BorderSide(color: Colors.black),
                  textColor: Colors.black,
                ),
              ),
            );
          } else {
            return DrawerHeaderWidget();
          }
        },
      ),
    );
  }
}
