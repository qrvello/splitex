import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:repartapp/providers/google_sign_in_provider.dart';
import 'package:repartapp/styles/elevated_button_style.dart';
import 'package:repartapp/widgets/drawer_header_widget.dart';
import 'package:provider/provider.dart';

class SideMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          _drawer(context),
          ListTile(
            leading: Icon(Icons.share_rounded),
            title: Text('Invitar a un amigo'),
          ),
          ListTile(
            leading: Icon(Icons.star_rate_rounded),
            title: Text('Opiná de la aplicación'),
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
                child: ElevatedButton(
                  style: elevatedButtonStyle,
                  onPressed: () => Navigator.of(context).pushNamed('/login'),
                  child: Text(
                    'Iniciar sesión',
                    style: TextStyle(color: Colors.white),
                  ),
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
