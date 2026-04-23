import 'package:pinnote/models/pin.dart';

abstract class PinState {}

class PinInitial extends PinState {}

class PinLoading extends PinState {}

class NearbyPinsLoaded extends PinState {
  final List<Pin> pins;
  NearbyPinsLoaded({required this.pins});
}

class SavedPinsLoaded extends PinState {
  final List<Pin> pins;
  SavedPinsLoaded({required this.pins});
}

class PinError extends PinState {
  final String error;
  PinError(this.error);
}

class OwnedPinsLoaded extends PinState {
  final List<Pin> pins;
  OwnedPinsLoaded({required this.pins});
}
