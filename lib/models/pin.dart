import 'package:cloud_firestore/cloud_firestore.dart';

class Pin {
  Pin({
    required String id,
    required String uid,
    required String username,
    String? profilePicturePath,
    required String note,
    required DateTime createdAt,
    required GeoPoint location,
    required String geohash,
    required int reports,
    required bool markedForDeletion,
  }) {
    this.id = id;
    this.uid = uid;
    this.username = username;
    this.profilePicturePath = profilePicturePath;
    this.note = note;
    this.createdAt = createdAt;
    this.location = location;
    this.geohash = geohash;
    this.reports = reports;
    this.markedForDeletion = markedForDeletion;
  }

  late String _id;
  late String _uid;
  late String _username;
  late String? _profilePicturePath;
  late String _note;
  late DateTime _createdAt;
  late GeoPoint _location;
  late String _geohash;
  late int _reports;
  late bool _markedForDeletion;

  String get id => _id;
  String get uid => _uid;
  String get username => _username;
  String? get profilePicturePath => _profilePicturePath;
  String get note => _note;
  DateTime get createdAt => _createdAt;
  GeoPoint get location => _location;
  String get geohash => _geohash;
  int get reports => _reports;
  bool get markedForDeletion => _markedForDeletion;

  set id(String value) => _id = value;
  set uid(String value) => _uid = value;
  set username(String value) => _username = value;
  set profilePicturePath(String? value) => _profilePicturePath = value;
  set note(String value) {
    if (value.isEmpty || value.length > 50) {
      throw ArgumentError('Note must be between 1 and 50 characters');
    }
    _note = value;
  }

  set createdAt(DateTime value) => _createdAt = value;
  set location(GeoPoint value) => _location = value;
  set geohash(String value) => _geohash = value;
  set reports(int value) => _reports = value;
  set markedForDeletion(bool value) => _markedForDeletion = value;

  Pin copyWith({
    String? id,
    String? uid,
    String? username,
    String? profilePicturePath,
    String? note,
    DateTime? createdAt,
    GeoPoint? location,
    String? geohash,
    int? reports,
    bool? markedForDeletion,
  }) {
    return Pin(
      id: id ?? _id,
      uid: uid ?? _uid,
      username: username ?? _username,
      profilePicturePath: profilePicturePath ?? _profilePicturePath,
      note: note ?? _note,
      createdAt: createdAt ?? _createdAt,
      location: location ?? _location,
      geohash: geohash ?? _geohash,
      reports: reports ?? _reports,
      markedForDeletion: markedForDeletion ?? _markedForDeletion,
    );
  }

  factory Pin.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final locationData = data['location'] as Map<String, dynamic>;

    return Pin(
      id: doc.id,
      uid: data['uid'],
      username: data['username'],
      profilePicturePath: data['profilePicturePath'],
      note: data['note'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime(1970),
      location: locationData['geopoint'] as GeoPoint,
      geohash: locationData['geohash'] as String,
      reports: data['reports'] ?? 0,
      markedForDeletion: data['markedForDeletion'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': _id,
    'uid': _uid,
    'username': _username,
    'profilePicturePath': _profilePicturePath,
    'note': _note,
    'createdAt': _createdAt,
    'location': {'geopoint': _location, 'geohash': _geohash},
    'reports': _reports,
    'markedForDeletion': _markedForDeletion,
  };
}
