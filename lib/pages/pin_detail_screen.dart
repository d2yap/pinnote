import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinnote/models/pin.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:pinnote/bloc/pin/pin_bloc.dart';
import 'package:pinnote/bloc/pin/pin_event.dart';
import 'package:pinnote/bloc/auth/auth_bloc.dart';
import 'package:pinnote/bloc/auth/auth_state.dart';

import 'package:intl/intl.dart';

import 'package:pinnote/widgets/confirm_action_dialog.dart';
import 'package:pinnote/widgets/go_back.dart';

class PinDetailScreen extends StatefulWidget {
  const PinDetailScreen({super.key});

  @override
  State<PinDetailScreen> createState() => _PinDetailScreenState();
}

void _confirmDelete(BuildContext context, Pin pin, String uid) {
  showDialog(
    context: context,
    builder: (context) => ConfirmActionDialog(
      title: 'Delete Pin',
      content: 'This will permanently delete your pin. Are you sure?',
      confirmLabel: 'Delete',
      onConfirm: () {
        context.read<PinBloc>().add(DeletePin(pinId: pin.id, uid: uid));
        Navigator.of(context).pop();
      },
    ),
  );
}

void _confirmReport(BuildContext context, Pin pin, String uid) {
  showDialog(
    context: context,
    builder: (context) => ConfirmActionDialog(
      title: 'Report Pin',
      content: 'This will report this pin. Are you sure?',
      confirmLabel: 'Report',
      onConfirm: () {
        context.read<PinBloc>().add(ReportSavedPin(pinId: pin.id, uid: uid));
        context.read<PinBloc>().add(ClearSavedPin(pinId: pin.id, uid: uid));
        Navigator.of(context).pop();
      },
    ),
  );
}

void _confirmClear(BuildContext context, Pin pin, String uid) {
  showDialog(
    context: context,
    builder: (context) => ConfirmActionDialog(
      title: 'Clear Pin',
      content:
          'This will clear this pin. Are you sure? \nNote: Currently if you are near a found pin that you recently deleted, it will come back.',
      confirmLabel: 'Clear',
      onConfirm: () {
        Navigator.of(context).pop();
        context.read<PinBloc>().add(ClearSavedPin(pinId: pin.id, uid: uid));
        Navigator.of(context).pop(); // go back after delete
      },
    ),
  );
}

class _PinDetailScreenState extends State<PinDetailScreen> {
  final MapController _mapController = MapController();

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pin = ModalRoute.of(context)!.settings.arguments as Pin;
    final authState = context.read<AuthBloc>().state;
    final isOwn =
        authState is AuthAuthenticated && authState.profile.uid == pin.uid;

    // responsive variables
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: deviceWidth * 0.05),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Pin Location',
                  style: TextStyle(
                    fontFamily: 'Clash',
                    fontSize: deviceWidth * 0.13,
                    fontWeight: FontWeight(800),
                  ),
                ),
              ),

              SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: LatLng(
                      pin.location.latitude,
                      pin.location.longitude,
                    ),
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.none,
                    ),
                    initialZoom: 17,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.pinnote',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(
                            pin.location.latitude,
                            pin.location.longitude,
                          ),
                          width: 60,
                          height: 60,
                          child: pin.profilePicturePath != null
                              ? Container(
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
                                      pin.profilePicturePath!,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                              : const Icon(
                                  Icons.location_pin,
                                  color: Colors.red,
                                  size: 40,
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '"${pin.note}"',
                        style: TextStyle(
                          fontSize: deviceWidth * 0.05,
                          fontFamily: "Clash",
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          pin.profilePicturePath != null
                              ? Container(
                                  width: 60,
                                  height: 60,
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
                                      pin.profilePicturePath!,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                              : const Icon(
                                  Icons.location_pin,
                                  color: Colors.red,
                                  size: 40,
                                ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '@${pin.username}',
                                style: TextStyle(
                                  fontWeight: FontWeight(900),
                                  fontSize: deviceWidth * 0.05,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${DateFormat('dd MMMM yyyy h:mm a').format(pin.createdAt.toLocal())}',
                                style: const TextStyle(
                                  fontWeight: FontWeight(700),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (isOwn)
                        Column(
                          children: [
                            const SizedBox(width: 12, height: 40),
                            SizedBox(
                              width: double.infinity,
                              height: deviceHeight * 0.07,
                              child: ElevatedButton(
                                onPressed: () => _confirmDelete(
                                  context,
                                  pin,
                                  authState.profile.uid,
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color.fromARGB(
                                    255,
                                    241,
                                    81,
                                    81,
                                  ),
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(
                                      color: Color.fromARGB(255, 156, 20, 20),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'DELETE MY PIN',
                                  style: TextStyle(
                                    fontFamily: 'Clash',
                                    fontSize: deviceWidth * 0.08,
                                    fontWeight: FontWeight(700),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      /*IconButton(
                          onPressed: () => _confirmDelete(
                            context,
                            pin,
                            (authState as AuthAuthenticated).profile.uid,
                          ),
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                        )*/
                      else
                        Column(
                          children: [
                            const SizedBox(width: 12, height: 40),
                            SizedBox(
                              width: double.infinity,
                              height: deviceHeight * 0.07,
                              child: ElevatedButton(
                                onPressed: () => _confirmClear(
                                  context,
                                  pin,
                                  (authState as AuthAuthenticated).profile.uid,
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(
                                      color: Color.fromARGB(255, 156, 20, 20),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'CLEAR PIN',
                                  style: TextStyle(
                                    fontFamily: 'Clash',
                                    fontSize: deviceWidth * 0.09,
                                    fontWeight: FontWeight(700),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12, height: 20),
                            SizedBox(
                              width: double.infinity,
                              height: deviceHeight * 0.07,
                              child: ElevatedButton(
                                onPressed: () => _confirmReport(
                                  context,
                                  pin,
                                  (authState as AuthAuthenticated).profile.uid,
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color.fromARGB(
                                    255,
                                    241,
                                    81,
                                    81,
                                  ),
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(
                                      color: Color.fromARGB(255, 156, 20, 20),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'REPORT PIN',
                                  style: TextStyle(
                                    fontFamily: 'Clash',
                                    fontSize: deviceWidth * 0.09,
                                    fontWeight: FontWeight(700),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(width: 20),
                      GoBack(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
