import 'package:flutter/material.dart';
import 'package:pinnote/widgets/image_banner.dart';
import 'package:pinnote/widgets/confirm_action_dialog.dart';
import 'package:pinnote/models/profile.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinnote/bloc/auth/auth_bloc.dart';
import 'package:pinnote/bloc/auth/auth_event.dart';
import 'package:pinnote/bloc/auth/auth_state.dart';

import 'package:pinnote/bloc/pin/pin_bloc.dart';
import 'package:pinnote/bloc/pin/pin_event.dart';
import 'package:pinnote/bloc/pin/pin_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

void _showClearPinsDialog(BuildContext context, Profile profile) {
  showDialog(
    context: context,
    builder: (context) => ConfirmActionDialog(
      title: 'Clear all pins?',
      content:
          'This will permanently delete all your saved pins. This action cannot be undone. \nNote: Currently if you are near a found pin that you recently deleted, it will come back.',
      confirmLabel: 'Clear all',
      onConfirm: () =>
          context.read<PinBloc>().add(ClearAllPins(uid: profile.uid)),
    ),
  );
}

class _SettingsScreenState extends State<SettingsScreen> {
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
                              'Settings',
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

                        // Clear All Pins
                        SizedBox(height: deviceHeight * 0.016),
                        SizedBox(
                          width: double.infinity,
                          height: deviceHeight * 0.054,
                          child: ElevatedButton(
                            onPressed: () =>
                                _showClearPinsDialog(context, profile),
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
                              'Clear all saved pins',
                              style: TextStyle(
                                fontFamily: 'Clash',
                                fontSize: deviceWidth * 0.049,
                                fontWeight: FontWeight(500),
                              ),
                            ),
                          ),
                        ),
                        // Clear All Pins
                        SizedBox(height: deviceHeight * 0.016),
                        SizedBox(
                          width: double.infinity,
                          height: deviceHeight * 0.054,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
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
                              'Go back',
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
