import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DrawerHeaderWidget extends StatelessWidget {
  final User? user;

  const DrawerHeaderWidget(this.user);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        UserAccountsDrawerHeader(
          currentAccountPicture: CircleAvatar(
            backgroundImage: ((user!.photoURL != null)
                    ? (NetworkImage(user!.photoURL!))
                    : const AssetImage('assets/blank-profile.jpg'))
                as ImageProvider<Object>?,
          ),
          accountName: Text(user!.displayName!),
          accountEmail: Text(user!.email!),
        ),
      ],
    );
  }
}
