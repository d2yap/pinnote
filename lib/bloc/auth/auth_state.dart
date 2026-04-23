import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:pinnote/models/profile.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;
  final Profile profile;
  AuthAuthenticated({required this.user, required this.profile});
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
