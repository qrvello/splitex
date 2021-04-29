import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';

import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.reference();

  final Box box = Hive.box('user');

  Future<void> init() async {
    if (_firebaseAuth.currentUser != null) {
      if (_firebaseAuth.currentUser.displayName != null &&
          _firebaseAuth.currentUser.displayName != '') {
        emit(AuthLoggedInWithGoogle(_firebaseAuth.currentUser));
      } else {
        emit(AuthLoggedInAnonymously(_firebaseAuth.currentUser));
      }
    } else {
      emit(AuthLoggedOut());
      await signInAnonymously();
    }
  }

  Future<void> signInWithGoogle() async {
    emit(AuthLoading());

    await _firebaseAuth.signOut();

    try {
      await _googleSignIn.signIn();

      final GoogleSignInAccount user = _googleSignIn.currentUser;

      if (user == null) {
        emit(AuthError('Error al conectarse con Google'));
        return;
      }

      final GoogleSignInAuthentication googleAuth = await user.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      await _databaseReference.child('users').update({
        _firebaseAuth.currentUser.uid: {
          'name': user.displayName,
          'email': user.email,
        }
      });

      box.put('name', user.displayName);
    } catch (_) {
      emit(AuthError('Error al conectarse con Google'));
      return;
    }

    emit(AuthLoggedInWithGoogle(_firebaseAuth.currentUser));
  }

  Future<void> signOut() async {
    emit(AuthLoading());
    try {
      await _firebaseAuth.signOut();
      await box.delete('name');
      emit(AuthLoggedOut());
    } catch (e) {
      emit(AuthError(e.message));
    }
  }

  Future<void> signInAnonymously() async {
    emit(AuthLoading());

    if (_firebaseAuth.currentUser == null) {
      try {
        await _firebaseAuth.signInAnonymously();
      } catch (e) {
        emit(AuthError(e.message));
      }
    }

    emit(AuthLoggedInAnonymously(_firebaseAuth.currentUser));
  }
}
