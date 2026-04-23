import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinnote/models/profile.dart';
import 'package:pinnote/bloc/auth/auth_bloc.dart';
import 'package:pinnote/bloc/auth/auth_event.dart';
import 'package:pinnote/bloc/auth/auth_state.dart';
import 'package:pinnote/widgets/go_back.dart';

class NewPinScreen extends StatefulWidget {
  const NewPinScreen({super.key});

  @override
  State<NewPinScreen> createState() => _NewPinScreenState();
}

class _NewPinScreenState extends State<NewPinScreen> {
  final MapController _mapController = MapController();
  final _noteController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Profile? _profile;
  LatLng? _location;
  bool _loading = true;

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // go to page telling user to enable location permissions before using the application
      return Future.error('Location service is disabled on this device');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        // go to page telling user to enable location permissions before using the application
        return Future.error('Location Permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // go to page telling user to enable location permissions before using the application
      return Future.error('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.best),
    );
  }

  Future<void> _assignPosition() async {
    final position = await _determinePosition();
    // BUG FIX -> Check if widget is mounted before updating the state. Application crashes when user pops the navigation too fast.
    if (mounted) {
      super.setState(() {
        _location = LatLng(position.latitude, position.longitude);
        _loading = false;
      });
    }
  }

  void _submitPin() async {
    if (!_formKey.currentState!.validate()) return;
    if (_profile!.pinUsage >= 5) {
      // show error widget
      _pinWarning(context);
      return;
    }
    _dialogBuilder();
  }

  void _pinSave() async {
    if (_location == null) return;
    if (!_formKey.currentState!.validate()) return;

    final ref = FirebaseFirestore.instance.collection('pins').doc();
    final geoFirePoint = GeoFirePoint(
      GeoPoint(_location!.latitude, _location!.longitude),
    );

    await ref.set({
      'id': ref.id,
      'uid': _profile!.uid,
      'username': _profile!.username,
      'profilePicturePath': _profile!.profilePicturePath,
      'note': _noteController.text,
      'createdAt': FieldValue.serverTimestamp(),
      'location': geoFirePoint.data,
      'reports': 0,
      'markedForDeletion': false,
    });

    if (mounted) {
      // This updates firestore with an updated usage count.
      context.read<AuthBloc>().add(UpdatePinUsage());
      Navigator.of(context).pushNamedAndRemoveUntil('/pins', (route) => false);
    }
  }

  Future<void> _dialogBuilder() {
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;

    String profilePath = _profile!.profilePicturePath!;

    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: Duration(milliseconds: 250),
      pageBuilder: (context, anim1, anim2) => Container(),
      transitionBuilder: (context, anim1, anim2, child) {
        final curved = CurvedAnimation(parent: anim1, curve: Curves.easeOut);

        return Center(
          child: Transform.translate(
            offset: Offset(0, (1 - curved.value) * 200),
            child: Opacity(
              opacity: curved.value,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: deviceHeight * 0.4),
                    child: SizedBox(
                      width: deviceHeight * 0.30,
                      height: deviceHeight * 0.15,
                      child: ElevatedButton(
                        onPressed: () {
                          _pinSave();
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: Colors.black, width: 2),
                          ),
                        ),
                        child: Text(
                          'Pin!',
                          style: TextStyle(
                            fontFamily: 'Clash',
                            fontSize: deviceWidth * 0.2,
                            fontWeight: FontWeight(800),
                          ),
                        ),
                      ),
                    ),
                  ),

                  Transform.translate(
                    offset: Offset(deviceWidth * -0.02, deviceHeight * 0.2),
                    child: Container(
                      width: deviceHeight * 0.1,
                      height: deviceHeight * 0.1,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Color(0xFFFFFFFF), width: 4),
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
                        child: Image.asset(profilePath!, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _pinWarning(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Warning'),
        content: const Text('You used the maximum amount of pins.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // go back after delete
            },
            style: TextButton.styleFrom(foregroundColor: Colors.green),
            child: const Text('Okay'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _assignPosition();

    var state = context.read<AuthBloc>().state;
    if (state is AuthAuthenticated) {
      _profile = state.profile;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _mapController.dispose();
    _noteController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            final profile = state.profile;
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: deviceWidth * 0.05),
                child: Center(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'My Location',
                            style: TextStyle(
                              fontFamily: 'Clash',
                              fontSize: deviceWidth * 0.13,
                              fontWeight: FontWeight(800),
                            ),
                          ),
                        ),
                        Container(
                          child: _loading
                              ? Center(
                                  child: SizedBox(
                                    height: deviceHeight * 0.4,
                                    width: deviceHeight * 0.4,
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : Container(
                                  height: deviceHeight * 0.4,
                                  child: FlutterMap(
                                    mapController: _mapController,
                                    options: MapOptions(
                                      initialCenter: _location!,
                                      initialZoom: 15.0,
                                      interactionOptions:
                                          const InteractionOptions(
                                            flags: InteractiveFlag.none,
                                          ),
                                      onMapReady: () {
                                        _mapController.move(_location!, 15.0);
                                      },
                                    ),
                                    children: [
                                      TileLayer(
                                        urlTemplate:
                                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                        userAgentPackageName:
                                            'com.example.pinnote',
                                      ),
                                      MarkerLayer(
                                        markers: [
                                          Marker(
                                            point: _location!,
                                            width: 60,
                                            height: 60,
                                            child:
                                                profile.profilePicturePath !=
                                                    null
                                                ? Container(
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.rectangle,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20,
                                                          ),
                                                      border: Border.all(
                                                        color: Color(
                                                          0xFFFFFFFF,
                                                        ),
                                                        width: 4,
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withValues(
                                                                alpha: 0.2,
                                                              ),
                                                          blurRadius: 1,
                                                          spreadRadius: 2,
                                                          offset: Offset(0, 2),
                                                        ),
                                                      ],
                                                    ),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            16,
                                                          ),
                                                      child: Image.asset(
                                                        profile
                                                            .profilePicturePath!,
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
                        ),
                        SizedBox(height: deviceHeight * 0.016),
                        TextFormField(
                          controller: _noteController,
                          maxLength: 50,
                          decoration: InputDecoration(
                            hintText: 'Note',

                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey,
                                width: 1.0,
                              ),
                            ),
                            // Border shown when the field IS focused
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.blue,
                                width: 2.0,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Note is required.";
                            }
                            if (_noteController.text.characters.length > 50) {
                              return "Note cannot be more than 50 characters";
                            }
                            return null;
                          },
                        ),

                        SizedBox(
                          height: deviceWidth * 0.6,
                          width: deviceWidth * 1,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Pin!
                              ClipOval(
                                child: SizedBox(
                                  width: deviceWidth * 0.4,
                                  height: deviceWidth * 0.4,
                                  child: ElevatedButton(
                                    onPressed: _submitPin,
                                    style: ElevatedButton.styleFrom(
                                      shape: CircleBorder(
                                        side: BorderSide(
                                          color: const Color.fromARGB(
                                            255,
                                            70,
                                            182,
                                            139,
                                          ),
                                          width: 2.0,
                                        ),
                                      ),
                                      backgroundColor: const Color(0xFF61F6BE),
                                      foregroundColor: Colors.black,
                                    ),
                                    child: Text(
                                      "Pin!",
                                      style: TextStyle(
                                        fontSize: deviceWidth * 0.12,
                                        fontFamily: 'Clash',
                                        fontWeight: FontWeight(800),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // uses
                              Positioned(
                                top: deviceWidth * 0.420,
                                left: deviceWidth * 0.65,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "Uses",
                                      style: TextStyle(
                                        fontWeight: FontWeight(400),
                                        fontSize: deviceWidth * 0.07,
                                        fontFamily: 'Clash',
                                      ),
                                    ),
                                    Text(
                                      "${profile.pinUsage} / 5",
                                      style: TextStyle(
                                        fontWeight: FontWeight(800),
                                        fontSize: deviceWidth * 0.07,
                                        fontFamily: 'Clash',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        GoBack(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
          return const SizedBox(child: Text("Error."));
        },
      ),
    );
  }
}
