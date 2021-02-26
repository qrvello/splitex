import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DrawerHeaderWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Column(
      children: <Widget>[
        UserAccountsDrawerHeader(
          currentAccountPicture: CircleAvatar(
            backgroundImage: (user.photoURL != null
                ? (NetworkImage(user.photoURL))
                : AssetImage('assets/blank-profile.jpg')),
          ),
          accountName: Text((user.displayName) != null ? user.displayName : ''),
          accountEmail: Text(user.email),
        ),
        ListTile(
          leading: Icon(Icons.person),
          title: Text('Mi perfil'),
          onTap: () => Navigator.of(context).pushNamed('/profile'),
        ),
      ],
    );
  }
}
