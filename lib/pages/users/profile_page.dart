import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:repartapp/providers/authentication_provider.dart';
import 'package:repartapp/providers/google_sign_in_provider.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final googleProvider =
        Provider.of<GoogleSignInProvider>(context, listen: false);
    final authProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(),
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
                  (user.displayName != null
                      ? Text(
                          'Nombre: ' + user.displayName,
                          style: TextStyle(color: Colors.white),
                        )
                      : SizedBox.shrink()),
                  SizedBox(height: 8),
                  Text(
                    'Correo electrónico: ' + user.email,
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          if (states.contains(MaterialState.pressed))
                            return Color(0x00264653);
                          return Color(
                              0xff2a9d8f); // Use the component's default.
                        },
                      ),
                    ),
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

  Widget buildLoading() => Center(child: CircularProgressIndicator());
}
