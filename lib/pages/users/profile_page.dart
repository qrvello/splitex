import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:repartapp/providers/authentication_provider.dart';
import 'package:repartapp/providers/google_sign_in_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
    final googleProvider =
        Provider.of<GoogleSignInProvider>(context, listen: false);
    final authProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil'),
      ),
      body: ChangeNotifierProvider(
        create: (context) => GoogleSignInProvider(),
        child: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            return Container(
              alignment: Alignment.center,
              color: Color(0xff264653),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                      maxRadius: 25,
                      backgroundImage: (user.photoURL != null
                          ? (NetworkImage(user.photoURL))
                          : AssetImage('assets/blank-profile.jpg'))),
                  SizedBox(height: 8),
                  Text(
                    'Nombre: ' + displayName,
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Correo electrónico: ' + email,
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () async {
                      if (googleProvider.googleSignIn.currentUser != null) {
                        googleProvider.logout();
                      }

                      authProvider.signOut();

                      Navigator.of(context).pushNamed('/home');
                    },
                    child: Text('Cerrar sesión'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
