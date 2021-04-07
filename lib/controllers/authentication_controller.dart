import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';

class AuthController extends GetxController {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.reference();

  Box box = Hive.box('user');

  Future<bool> signInWithGoogle() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
      return false;
    }
    final GoogleSignInAccount user = _googleSignIn.currentUser;

    if (user == null) {
      return false;
    }

    final GoogleSignInAuthentication googleAuth = await user.authentication;

    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);

    DataSnapshot snapshot = await _databaseReference
        .child('users/${_firebaseAuth.currentUser.uid}')
        .once();

    if (snapshot.value == null) {
      _databaseReference.child('users').update({
        _firebaseAuth.currentUser.uid: {
          'name': user.displayName,
          'email': user.email,
        }
      });
    }
    return true;
  }

  Future<bool> signOut() async {
    try {
      await _firebaseAuth.signOut();
      box.clear();
      return true;
    } catch (e) {
      print(e.message);
      return false;
    }
  }

  User getUserData() {
    return _firebaseAuth.currentUser;
  }
}
