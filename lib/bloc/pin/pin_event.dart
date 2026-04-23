import 'package:pinnote/models/pin.dart';

abstract class PinEvent {}

class FetchNearbyPins extends PinEvent {
  final double latitude;
  final double longitude;
  final double radiusInKm;
  final String uid;

  FetchNearbyPins({
    required this.latitude,
    required this.longitude,
    required this.uid,
    this.radiusInKm = 1,
  });
}

class SavePin extends PinEvent {
  final String uid;
  final String pinId;
  final Pin pin;
  SavePin({required this.uid, required this.pinId, required this.pin});
}

class FetchSavedPins extends PinEvent {
  final String uid;
  FetchSavedPins({required this.uid});
}

class FetchOwnedPins extends PinEvent {
  final String uid;
  FetchOwnedPins({required this.uid});
}

class DeletePin extends PinEvent {
  final String pinId;
  final String uid;
  DeletePin({required this.pinId, required this.uid});
}

class ClearSavedPin extends PinEvent {
  final String pinId;
  final String uid;
  ClearSavedPin({required this.pinId, required this.uid});
}

class ReportSavedPin extends PinEvent {
  final String pinId;
  final String uid;
  ReportSavedPin({required this.pinId, required this.uid});
}

class ClearAllPins extends PinEvent {
  final String uid;
  ClearAllPins({required this.uid});
}
