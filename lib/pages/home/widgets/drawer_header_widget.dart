import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DrawerHeaderWidget extends StatefulWidget {
  @override
  _DrawerHeaderWidgetState createState() => _DrawerHeaderWidgetState();
}

class _DrawerHeaderWidgetState extends State<DrawerHeaderWidget> {
  String displayName = '';

  String email = '';

  @override
  void initState() {
    _getUserData();
    super.initState();
  }

  _getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    displayName = prefs.getString('displayName');
    email = prefs.getString('email');
  }

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
          accountName: Text(displayName),
          accountEmail: Text(email),
        ),
        ListTile(
          leading: Icon(Icons.person_rounded),
          title: Text('Mi perfil'),
          onTap: () => Navigator.of(context).pushNamed('/profile'),
        ),
      ],
    );
  }
}
