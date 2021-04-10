import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:repartapp/controllers/authentication_controller.dart';

class DrawerHeaderWidget extends StatefulWidget {
  @override
  _DrawerHeaderWidgetState createState() => _DrawerHeaderWidgetState();
}

class _DrawerHeaderWidgetState extends State<DrawerHeaderWidget> {
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    User user = authController.getUserData();

    return Column(
      children: <Widget>[
        UserAccountsDrawerHeader(
          currentAccountPicture: CircleAvatar(
            backgroundImage: (user.photoURL != null)
                ? (NetworkImage(user.photoURL))
                : AssetImage('assets/blank-profile.jpg'),
          ),
          accountName: Text(user.displayName),
          accountEmail: Text(user.email),
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
