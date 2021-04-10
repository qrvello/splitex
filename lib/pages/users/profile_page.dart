import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:repartapp/controllers/authentication_controller.dart';
import 'package:repartapp/pages/home/home_page.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthController authController = Get.find();
  @override
  Widget build(BuildContext context) {
    final User user = authController.getUserData();

    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil'),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              maxRadius: 25,
              backgroundImage: (user.photoURL != '')
                  ? (NetworkImage(user.photoURL))
                  : AssetImage('assets/blank-profile.jpg'),
            ),
            SizedBox(height: 8),
            Text('Nombre: ' + user.displayName),
            SizedBox(height: 8),
            Text('Correo electrónico: ' + user.email),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                await authController.signOut().then((value) {
                  Get.to(() => HomePage());
                });
              },
              child: Text('Cerrar sesión'),
            ),
          ],
        ),
      ),
    );
  }
}
