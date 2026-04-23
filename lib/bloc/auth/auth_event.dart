import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;

abstract class AuthEvent {}

class AppStarted extends AuthEvent {}

class LogoutRequested extends AuthEvent {}

class FetchUserProfile extends AuthEvent {
  final User user;
  final String uid;
  FetchUserProfile({required this.user, required this.uid});
}

class UpdatePinUsage extends AuthEvent {}

class ResetPinUsage extends AuthEvent {}
