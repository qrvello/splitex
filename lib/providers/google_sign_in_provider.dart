import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoogleSignInProvider with ChangeNotifier {
  final databaseReference = FirebaseDatabase.instance.reference();

  final googleSignIn = GoogleSignIn();
  bool _isSigninIn;

  GoogleSignInProvider() {
    _isSigninIn = false;
  }

  bool get isSigninIn => _isSigninIn;

  set isSigninIn(bool isSigninIn) {
    _isSigninIn = isSigninIn;
    notifyListeners();
  }

  Future login() async {
    isSigninIn = true;

    await googleSignIn.signIn();

    final user = googleSignIn.currentUser;

    if (user == null) {
      isSigninIn = false;
      return null;
    } else {
      final googleAuth = await user.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'displayName', FirebaseAuth.instance.currentUser.displayName);
      await prefs.setString('email', FirebaseAuth.instance.currentUser.email);
      await prefs.setString('uid', FirebaseAuth.instance.currentUser.uid);

      DataSnapshot snapshot = await databaseReference
          .child('users/${FirebaseAuth.instance.currentUser.uid}')
          .once();

      if (snapshot.value == null) {
        databaseReference.child('users').update({
          FirebaseAuth.instance.currentUser.uid: {
            'name': user.displayName,
            'email': user.email,
          }
        });
      }

      isSigninIn = false;
    }
  }

  logout() async {
    await googleSignIn.disconnect();
    await FirebaseAuth.instance.signOut();
  }
}
