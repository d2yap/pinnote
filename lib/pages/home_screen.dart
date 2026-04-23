import 'package:flutter/material.dart';
import 'package:pinnote/widgets/image_banner.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinnote/bloc/auth/auth_bloc.dart';
import 'package:pinnote/bloc/auth/auth_event.dart';
import 'package:pinnote/bloc/auth/auth_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _onStartup();
  }

  // startup routines
  void _onStartup() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    final lastPinDate = authState.profile.lastPinDate;

    final now = DateTime.now();
    final isNewDay =
        lastPinDate.year != now.year ||
        lastPinDate.month != now.month ||
        lastPinDate.day != now.day;

    if (isNewDay) {
      context.read<AuthBloc>().add(ResetPinUsage());
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            Navigator.pushNamed(context, '/start');
          }
        },
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            final profile = state.profile;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: deviceWidth * 0.05),
                  child: Center(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Welcome',
                              style: TextStyle(
                                fontFamily: 'Clash',
                                fontSize: deviceWidth * 0.13,
                                fontWeight: FontWeight(800),
                              ),
                            ),
                            if (profile.profilePicturePath != null)
                              Container(
                                width: deviceWidth * 0.2,
                                height: deviceWidth * 0.2,
                                margin: EdgeInsets.only(left: 16),
                                decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Color(0xFFFFFFFF),
                                    width: 4,
                                  ),

                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.2,
                                      ),
                                      blurRadius: 1,
                                      spreadRadius: 2,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.asset(
                                    profile.profilePicturePath!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                          ],
                        ),

                        // Pins
                        SizedBox(height: deviceHeight * 0.016),
                        SizedBox(
                          width: double.infinity,
                          height: deviceHeight * 0.18,

                          child: ElevatedButton(
                            onPressed: () {
                              // to pins
                              Navigator.pushNamed(context, '/pins');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF61F6BE),
                              foregroundColor: Colors.black,

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: Color(0xFF149C21),
                                  width: 2,
                                ),
                              ),
                            ),
                            child: Align(
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                'Pins',
                                style: TextStyle(
                                  fontFamily: 'Clash',
                                  fontSize: deviceWidth * 0.13,
                                  fontWeight: FontWeight(800),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Settings
                        SizedBox(height: deviceHeight * 0.016),
                        SizedBox(
                          width: double.infinity,
                          height: deviceHeight * 0.054,
                          child: ElevatedButton(
                            onPressed: () => {
                              Navigator.pushNamed(context, '/settings'),
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black,
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(color: Colors.black, width: 2),
                              ),
                            ),
                            child: Text(
                              'Settings',
                              style: TextStyle(
                                fontFamily: 'Clash',
                                fontSize: deviceWidth * 0.049,
                                fontWeight: FontWeight(500),
                              ),
                            ),
                          ),
                        ),

                        // Log out
                        SizedBox(height: deviceHeight * 0.016),
                        SizedBox(
                          width: double.infinity,
                          height: deviceHeight * 0.054,
                          child: ElevatedButton(
                            onPressed: () =>
                                context.read<AuthBloc>().add(LogoutRequested()),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.red,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(color: Colors.black, width: 2),
                              ),
                            ),
                            child: Text(
                              'Log out',
                              style: TextStyle(
                                fontFamily: 'Clash',
                                fontSize: deviceWidth * 0.049,
                                fontWeight: FontWeight(500),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ImageBanner(),
              ],
            );
          }

          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
