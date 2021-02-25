import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInProvider extends ChangeNotifier {
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
    final user = await googleSignIn.signIn();
    if (user == null) {
      isSigninIn = false;
      return;
    } else {
      final googleAuth = await user.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      DataSnapshot snapshot = await databaseReference
          .child('users/${FirebaseAuth.instance.currentUser.uid}')
          .once();

      if (snapshot.value == null) {
        databaseReference.child('users').set({
          FirebaseAuth.instance.currentUser.uid: {
            'name': user.displayName,
            'email': user.email,
          }
        });
      }

      isSigninIn = false;
    }
  }

  void logout() async {
    await googleSignIn.disconnect();
    FirebaseAuth.instance.signOut();
  }
}
