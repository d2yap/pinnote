import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:pinnote/bloc/pin/pin_bloc.dart';
import 'package:pinnote/bloc/pin/pin_event.dart';
import 'package:pinnote/bloc/pin/pin_state.dart';
import 'package:pinnote/bloc/auth/auth_bloc.dart';
import 'package:pinnote/bloc/auth/auth_state.dart';

class OwnPinsTab extends StatefulWidget {
  const OwnPinsTab({super.key});

  @override
  State<OwnPinsTab> createState() => _OwnPinsTabState();
}

class _OwnPinsTabState extends State<OwnPinsTab> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<PinBloc>().add(FetchOwnedPins(uid: authState.profile.uid));
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return const Center(child: Text('Not logged in.'));
    }

    return BlocBuilder<PinBloc, PinState>(
      buildWhen: (previous, current) =>
          current is OwnedPinsLoaded ||
          current is PinLoading ||
          current is PinError,
      builder: (context, state) {
        if (state is PinLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is OwnedPinsLoaded) {
          if (state.pins.isEmpty) {
            return const Center(
              child: Text("You haven't dropped any pins yet?"),
            );
          }
          final pins = [...state.pins]
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return Column(
            children: [
              Text(
                'PIN USAGE: ${authState.profile.pinUsage}/5',
                style: TextStyle(fontFamily: 'Clash'),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: pins.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final pin = pins[index];
                    return ListTile(
                      contentPadding: EdgeInsets.all(20.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(
                          color: Color.fromARGB(255, 3, 145, 88),
                          width: 1,
                        ),
                      ),
                      tileColor: Color.fromARGB(255, 3, 145, 88),
                      leading: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 1,
                              spreadRadius: 2,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: pin.profilePicturePath != null
                              ? Image.asset(
                                  pin.profilePicturePath!,
                                  fit: BoxFit.cover,
                                )
                              : const CircleAvatar(child: Icon(Icons.person)),
                        ),
                      ),
                      title: Text(
                        '"${pin.note}"',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Clash',
                          fontSize: deviceWidth * 0.07,
                          fontWeight: const FontWeight(800),
                        ),
                      ),
                      subtitle: Text(
                        'Pinned at ${DateFormat('dd MMMM yyyy h:mm a').format(pin.createdAt.toLocal())}',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Clash',
                          fontSize: deviceWidth * 0.035,
                          fontWeight: const FontWeight(500),
                        ),
                      ),
                      onTap: () async {
                        await Navigator.of(
                          context,
                        ).pushNamed('/pin-detail', arguments: pin);
                        // callback to refresh this tab on delete
                        if (!context.mounted) return;
                        if (context.mounted) {
                          context.read<PinBloc>().add(
                            FetchOwnedPins(uid: authState.profile.uid),
                          );
                        }
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
        return const Center(child: Text("You haven't dropped any pins yet."));
      },
    );
  }
}
