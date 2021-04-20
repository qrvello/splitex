import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthState {
  AuthState();
}

class AuthLoading extends AuthState {}

class AuthInitial extends AuthState {}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);
}

class AuthLoggedOut extends AuthState {}

class AuthLoggedInWithGoogle extends AuthState {
  final User user;

  AuthLoggedInWithGoogle(this.user);
}

class AuthLoggedInAnonymously extends AuthState {
  final User user;

  AuthLoggedInAnonymously(this.user);
}
