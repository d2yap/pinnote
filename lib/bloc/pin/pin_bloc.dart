import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';

import 'package:pinnote/bloc/pin/pin_event.dart';
import 'package:pinnote/bloc/pin/pin_state.dart';
import 'package:pinnote/models/pin.dart';

import 'dart:async';

class PinBloc extends Bloc<PinEvent, PinState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Set<String> _savedPinIds = {};
  Timer? _refreshTimer;

  List<Pin> _nearbyPins = [];
  List<Pin> _savedPins = [];
  List<Pin> _ownedPins = [];

  PinBloc() : super(PinInitial()) {
    on<FetchNearbyPins>(_onFetchNearbyPins);
    on<SavePin>(_onSavePin);
    on<FetchSavedPins>(_onFetchSavedPins);
    on<FetchOwnedPins>(_onFetchOwnedPins);
    on<DeletePin>(_onDeletePin);
    on<ClearSavedPin>(_onClearSavedPin);
    on<ReportSavedPin>(_onReportSavedPin);
    on<ClearAllPins>(_onClearAllPins);
  }

  Future<void> _onSavePin(SavePin event, Emitter<PinState> emit) async {
    if (event.pin.uid == event.uid) return;
    // -> checking if this will lower read counts
    if (_savedPinIds.contains(event.pinId)) return;

    try {
      await _firestore
          .collection('users')
          .doc(event.uid)
          .collection('saved-pins')
          .doc(event.pinId)
          .set(event.pin.toMap());

      _savedPinIds.add(event.pinId);
    } catch (e) {
      emit(PinError(e.toString()));
    }
  }

  Future<void> _onFetchNearbyPins(
    FetchNearbyPins event,
    Emitter<PinState> emit,
  ) async {
    if (_nearbyPins.isEmpty) emit(PinLoading());
    try {
      // subscribe -> 5k writes
      // fetch ->
      final docs =
          await GeoCollectionReference<Map<String, dynamic>>(
            _firestore.collection('pins'),
          ).fetchWithin(
            center: GeoFirePoint(GeoPoint(event.latitude, event.longitude)),
            radiusInKm: event.radiusInKm,
            field: 'location',
            geopointFrom: (data) => data['location']['geopoint'] as GeoPoint,
          );

      _nearbyPins = docs
          .map((doc) => Pin.fromFirestore(doc))
          .where((pin) => pin.uid != event.uid)
          .where((pin) => !pin.markedForDeletion)
          .toList();

      emit(NearbyPinsLoaded(pins: _nearbyPins));

      // Timer, every 2 minutes it refreshes the pins.
      if (_refreshTimer == null || !_refreshTimer!.isActive) {
        _refreshTimer = Timer.periodic(Duration(minutes: 2), (_) {
          if (!isClosed) {
            add(
              FetchNearbyPins(
                latitude: event.latitude,
                longitude: event.longitude,
                radiusInKm: event.radiusInKm,
                uid: event.uid,
              ),
            );
          }
        });
      }
    } catch (e) {
      emit(PinError(e.toString()));
    }
  }

  Future<void> _onFetchSavedPins(
    FetchSavedPins event,
    Emitter<PinState> emit,
  ) async {
    if (_savedPins.isEmpty) emit(PinLoading());
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(event.uid)
          .collection('saved-pins')
          .get();

      _savedPins = snapshot.docs
          .map((doc) => Pin.fromFirestore(doc))
          .where((pin) => !pin.markedForDeletion)
          .toList();

      emit(SavedPinsLoaded(pins: _savedPins));
    } catch (e) {
      emit(PinError(e.toString()));
    }
  }

  Future<void> _onFetchOwnedPins(
    FetchOwnedPins event,
    Emitter<PinState> emit,
  ) async {
    if (_ownedPins.isEmpty) emit(PinLoading());
    try {
      final snapshot = await _firestore
          .collection('pins')
          .where('uid', isEqualTo: event.uid)
          .get();

      _ownedPins = snapshot.docs
          .map((doc) => Pin.fromFirestore(doc))
          .where((pin) => !pin.markedForDeletion)
          .toList();

      emit(OwnedPinsLoaded(pins: _ownedPins));
    } catch (e) {
      emit(PinError(e.toString()));
    }
  }

  Future<void> _onDeletePin(DeletePin event, Emitter<PinState> emit) async {
    emit(PinLoading());
    try {
      final pinDoc = await _firestore.collection('pins').doc(event.pinId).get();

      if (!pinDoc.exists) {
        emit(PinError('Pin not found.'));
        return;
      }

      if (pinDoc['uid'] != event.uid) {
        emit(PinError('You can only delete your own pins.'));
        return;
      }

      await _firestore.collection('pins').doc(event.pinId).update({
        'markedForDeletion': true,
      });

      _savedPinIds.remove(event.pinId);
      _ownedPins.removeWhere((pin) => pin.id == event.pinId);

      emit(OwnedPinsLoaded(pins: _ownedPins));
    } catch (e) {
      emit(PinError(e.toString()));
    }
  }

  Future<void> _onClearSavedPin(
    ClearSavedPin event,
    Emitter<PinState> emit,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(event.uid)
          .collection('saved-pins')
          .doc(event.pinId)
          .delete();

      _savedPinIds.remove(event.pinId);
      _savedPins.removeWhere((pin) => pin.id == event.pinId);

      emit(SavedPinsLoaded(pins: _savedPins));
    } catch (e) {
      emit(PinError(e.toString()));
    }
  }

  Future<void> _onReportSavedPin(
    ReportSavedPin event,
    Emitter<PinState> emit,
  ) async {
    try {
      await _firestore.collection('pins').doc(event.pinId).update({
        'reports': FieldValue.increment(1),
      });
      emit(SavedPinsLoaded(pins: _savedPins));
    } catch (err) {
      emit(PinError(err.toString()));
    }
  }

  Future<void> _onClearAllPins(
    ClearAllPins event,
    Emitter<PinState> emit,
  ) async {
    try {
      emit(PinLoading());

      final snapshot = await _firestore
          .collection('users')
          .doc(event.uid)
          .collection('saved-pins')
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      _savedPins.clear();
      _savedPinIds.clear();

      emit(SavedPinsLoaded(pins: _savedPins));
    } catch (e) {
      emit(PinError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    return super.close();
  }
}
