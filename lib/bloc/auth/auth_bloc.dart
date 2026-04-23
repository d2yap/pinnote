import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinnote/bloc/auth/auth_event.dart';
import 'package:pinnote/bloc/auth/auth_state.dart';
import 'package:pinnote/models/profile.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<FetchUserProfile>(_onFetchUserProfile);
    on<UpdatePinUsage>(_onUpdatePinUsage);
    on<LogoutRequested>(_onLogoutRequested);
    on<ResetPinUsage>(_onResetPinUsage);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    await emit.forEach<User?>(
      FirebaseAuth.instance.userChanges(),
      onData: (user) {
        if (user == null) {
          return AuthUnauthenticated();
        } else {
          add(FetchUserProfile(user: user, uid: user.uid));
          return AuthLoading();
        }
      },
      onError: (error, _) => AuthError(error.toString()),
    );
  }

  Future<void> _onFetchUserProfile(
    FetchUserProfile event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(event.uid)
          .get();

      if (!doc.exists) {
        emit(AuthError('Profile not found for ${event.uid}'));
        return;
      }

      final profile = Profile.fromFirestore(doc);
      emit(AuthAuthenticated(user: event.user, profile: profile));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onUpdatePinUsage(
    UpdatePinUsage event,
    Emitter<AuthState> emit,
  ) async {
    final state = this.state;
    if (state is! AuthAuthenticated) return;

    final updatedProfile = state.profile.copyWith(
      lastPinDate: DateTime.now(),
      pinUsage: state.profile.pinUsage + 1,
    );

    // Update Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(state.profile.uid)
        .update({
          'lastPinDate': FieldValue.serverTimestamp(),
          'pinUsage': FieldValue.increment(1),
        });

    emit(AuthAuthenticated(user: state.user, profile: updatedProfile));
  }

  Future<void> _onResetPinUsage(
    ResetPinUsage event,
    Emitter<AuthState> emit,
  ) async {
    final state = this.state;
    if (state is! AuthAuthenticated) return;

    // Update firestore to 0 pins
    await FirebaseFirestore.instance
        .collection('users')
        .doc(state.profile.uid)
        .update({'pinUsage': 0});

    emit(
      AuthAuthenticated(
        user: state.user,
        profile: state.profile.copyWith(pinUsage: 0),
      ),
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await FirebaseAuth.instance.signOut();
  }
}
