import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:pinnote/pages/new_pin_screen.dart';
import 'package:pinnote/pages/pin_screen.dart';
import 'package:pinnote/pages/sign_in_screen.dart';
import 'package:pinnote/pages/sign_up_screen.dart';
import 'package:pinnote/pages/start_screen.dart';
import 'package:pinnote/pages/home_screen.dart';
import 'package:pinnote/pages/pin_detail_screen.dart';
import 'package:pinnote/pages/settings_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;

import 'package:pinnote/bloc/auth/auth_bloc.dart';
import 'package:pinnote/bloc/auth/auth_event.dart';
import 'package:pinnote/bloc/auth/auth_state.dart';

import 'package:pinnote/bloc/pin/pin_bloc.dart';
import 'package:pinnote/bloc/pin/pin_event.dart';
import 'package:pinnote/bloc/pin/pin_state.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc()..add(AppStarted())),
        BlocProvider(create: (_) => PinBloc()),
      ],
      child: MaterialApp(
        home: AuthCheck(),
        routes: {
          '/start': (context) => StartScreen(),
          '/home': (context) => HomeScreen(),
          '/sign-in': (context) => SignInScreen(),
          '/register': (context) => SignUpScreen(),
          '/pins': (context) => PinScreen(),
          '/new-pin': (context) => NewPinScreen(),
          '/pin-detail': (context) => PinDetailScreen(),
          '/settings': (context) => SettingsScreen(),
        },
      ),
    );
  }
}

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    //https://pub.dev/documentation/flutter_bloc/latest/flutter_bloc/BlocConsumer-class.html
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            context.read<AuthBloc>().add(
              FetchUserProfile(user: user, uid: user.uid),
            );
          }
        }
      },
      builder: (context, state) {
        if (state is AuthLoading || state is AuthInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is AuthAuthenticated) {
          return const HomeScreen();
        }
        return const StartScreen();
      },
    );
  }
}
