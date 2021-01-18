import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:gastos_grupales/pages/profile_page.dart';

class DrawerHeaderWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Column(
      children: <Widget>[
        UserAccountsDrawerHeader(
          currentAccountPicture: CircleAvatar(
            backgroundImage: NetworkImage(user.photoURL),
          ),
          accountName: Text('Santiago Curvello'),
          accountEmail: Text('santicurvello@gmail.com'),
        ),
        ListTile(
          leading: Icon(Icons.person),
          title: Text('Mi perfil'),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfilePage()),
          ),
        ),
      ],
    );
  }
}
