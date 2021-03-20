import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationProvider with ChangeNotifier {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final databaseReference = FirebaseDatabase.instance.reference();

  AuthenticationProvider(this._firebaseAuth);

  Stream<User> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<bool> signIn(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      print(e.message);
      return false;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final userData = await FirebaseDatabase.instance
        .reference()
        .child('/users/${_firebaseAuth.currentUser.uid}')
        .once();

    await prefs.setString('displayName', userData.value['name']);
    await prefs.setString('email', email);
    await prefs.setString('uid', _firebaseAuth.currentUser.uid);
    return true;
  }

  Future<bool> signUp(String email, String password, String name) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      print(e.message);
      return false;
    }

    databaseReference.child('users/${_firebaseAuth.currentUser.uid}').set({
      'name': name,
      'email': email,
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('displayName', name);
    await prefs.setString('email', email);
    await prefs.setString('uid', _firebaseAuth.currentUser.uid);

    return true;
  }

  Future<bool> signOut() async {
    try {
      await _firebaseAuth.signOut();
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.clear();
      return true;
    } catch (e) {
      print(e.message);
      return false;
    }
  }
}
