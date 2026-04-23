import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinnote/widgets/own_pins_tab.dart';

import 'package:pinnote/widgets/saved_pins_tab.dart';

class PinScreen extends StatefulWidget {
  const PinScreen({super.key});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  double _lat = 0.0;
  double _lng = 0.0;
  bool _locationReady = false;

  int _tab = 0;
  void _locationWarning(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Warning'),
        content: const Text(
          'Please enable location services on your phone to use the application.',
        ),
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

  // Location service check
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // TODO: go to page telling user to enable location permissions before using the application
      //    other phone has this issue?
      _locationWarning(context);
      return Future.error('Location service is disabled on this device');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        // go to page telling user to enable location permissions before using the application
        _locationWarning(context);
        return Future.error('Location Permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // go to page telling user to enable location permissions before using the application
      _locationWarning(context);
      return Future.error('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.best),
    );
  }

  /// Function for getting the fetching the nearby pins and saving them to firestore + bloc state

  Future<void> _getLocationPermissions() async {
    final position = await _determinePosition();

    if (mounted) {
      setState(() {
        _lat = position.latitude;
        _lng = position.longitude;
        _locationReady = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _locationReady = false;
    _getLocationPermissions();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // responsive variables
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      // "NewPin" circle button
      floatingActionButton: FloatingActionButton.large(
        onPressed: () {
          Navigator.of(context).pushNamed('/new-pin');
        },
        backgroundColor: Color.fromARGB(255, 9, 55, 15),
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.pin_drop_rounded),
      ),

      // Application
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: deviceWidth * 0.05),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    /// Home button
                    GestureDetector(
                      onTap: () => Navigator.of(context).pushNamed("/home"),
                      child: Container(
                        width: deviceWidth * 0.09,
                        height: deviceWidth * 0.09,
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
                        child: Icon(Icons.home),
                      ),
                    ),
                    const SizedBox(width: 8),

                    /// Title
                    Text(
                      'Pins',
                      style: TextStyle(
                        fontFamily: 'Clash',
                        fontSize: deviceWidth * 0.13,
                        fontWeight: FontWeight(800),
                      ),
                    ),

                    /// Navigator
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => setState(() => _tab = 0),
                            child: Text(
                              'Found',
                              style: TextStyle(
                                fontFamily: 'Clash',
                                fontSize: deviceWidth * 0.06,
                                fontWeight: const FontWeight(800),
                                color: _tab == 0
                                    ? Colors.black
                                    : const Color.fromARGB(255, 143, 143, 143),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () {
                              setState(() => _tab = 1);
                            },
                            child: Text(
                              'Own',
                              style: TextStyle(
                                fontFamily: 'Clash',
                                fontSize: deviceWidth * 0.06,
                                fontWeight: const FontWeight(800),
                                color: _tab == 1
                                    ? Colors.black
                                    : const Color.fromARGB(255, 143, 143, 143),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Tabbing between elements
                Expanded(
                  child: !_locationReady
                      ? const Center(child: CircularProgressIndicator())
                      : _tab == 0
                      ? SavedPinsTab(latitude: _lat, longitude: _lng)
                      : const OwnPinsTab(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
