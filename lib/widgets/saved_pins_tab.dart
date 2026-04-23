import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:pinnote/bloc/pin/pin_bloc.dart';
import 'package:pinnote/bloc/pin/pin_event.dart';
import 'package:pinnote/bloc/pin/pin_state.dart';
import 'package:pinnote/bloc/auth/auth_bloc.dart';
import 'package:pinnote/bloc/auth/auth_state.dart';

class SavedPinsTab extends StatefulWidget {
  final double latitude;
  final double longitude;

  const SavedPinsTab({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<SavedPinsTab> createState() => _SavedPinsTabState();
}

class _SavedPinsTabState extends State<SavedPinsTab> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<PinBloc>().add(
        FetchNearbyPins(
          latitude: widget.latitude,
          longitude: widget.longitude,
          radiusInKm: 1,
          uid: authState.profile.uid,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // responsive variables
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;
    return BlocConsumer<PinBloc, PinState>(
      listener: (context, state) {
        if (state is NearbyPinsLoaded) {
          final authState = context.read<AuthBloc>().state;
          if (authState is AuthAuthenticated) {
            for (final pin in state.pins) {
              context.read<PinBloc>().add(
                SavePin(uid: authState.profile.uid, pinId: pin.id, pin: pin),
              );
            }
            context.read<PinBloc>().add(
              FetchSavedPins(uid: authState.profile.uid),
            );
          }
        }
      },
      builder: (context, state) {
        if (state is PinLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        // SavedPinsLoaded
        if (state is SavedPinsLoaded) {
          if (state.pins.isEmpty) {
            return const Center(child: Text('No pins found nearby.'));
          }
          // Sort by pin.createdAt
          final pins = [...state.pins]
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return Column(
            children: [
              Text(
                "CURRENTLY SCANNING FOR NEW PINS",
                style: TextStyle(fontFamily: 'Clash'),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: state.pins.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final pin = pins[index];
                    return ListTile(
                      contentPadding: EdgeInsets.all(20.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: Color(0xFF61F6BE), width: 1),
                      ),
                      tileColor: Color(0xFF61F6BE),
                      leading: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Color(0xFFFFFFFF),
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 1,
                              spreadRadius: 2,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            pin.profilePicturePath!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      title: Text(
                        '"${pin.note}"',
                        style: TextStyle(
                          fontFamily: 'Clash',
                          fontSize: deviceWidth * 0.07,
                          fontWeight: FontWeight(800),
                        ),
                      ),
                      subtitle: Text(
                        '@${pin.username} - Pinned at ${DateFormat('dd MMMM yyyy h:mm a').format(pin.createdAt.toLocal())}',

                        style: TextStyle(
                          fontFamily: 'Clash',
                          fontSize: deviceWidth * 0.035,
                          fontWeight: FontWeight(500),
                        ),
                      ),
                      onTap: () => {
                        Navigator.of(
                          context,
                        ).pushNamed('/pin-detail', arguments: pin),
                      },
                    );
                  },
                ),
              ),
            ],
          );
        }
        if (state is PinError) {
          return Center(child: Text(state.error));
        }
        return const Center(
          child: Text('Scanning for nearby pins in a moment.'),
        );
      },
    );
  }
}
