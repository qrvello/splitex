import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:repartapp/providers/authentication_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String displayName = '';
  String email = '';
  String photoURL = '';

  final user = FirebaseAuth.instance.currentUser;
  @override
  void initState() {
    _getUserData();
    super.initState();
  }

  void _getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    displayName = prefs.getString('displayName');
    email = prefs.getString('email');
    if (user.photoURL != null) {
      photoURL = user.photoURL;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthenticationProvider authProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil'),
      ),
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          return Container(
            alignment: Alignment.center,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  maxRadius: 25,
                  backgroundImage: (photoURL != '')
                      ? (NetworkImage(photoURL))
                      : AssetImage('assets/blank-profile.jpg'),
                ),
                SizedBox(height: 8),
                Text('Nombre: ' + displayName),
                SizedBox(height: 8),
                Text('Correo electrónico: ' + email),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                    await authProvider.signOut();

                    Navigator.of(context).pushNamed('/');
                  },
                  child: Text('Cerrar sesión'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
