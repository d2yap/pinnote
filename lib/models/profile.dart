import 'package:cloud_firestore/cloud_firestore.dart';

class Profile {
  Profile({
    required String uid,
    required String username,
    required String email,
    String? profilePicturePath,
    required int pinUsage,
    required DateTime lastPinDate,
  }) {
    this.uid = uid;
    this.username = username;
    this.email = email;
    this.profilePicturePath = profilePicturePath;
    this.pinUsage = pinUsage;
    this.lastPinDate = lastPinDate;
  }

  Profile copyWith({
    String? uid,
    String? username,
    String? email,
    String? profilePicturePath,
    int? pinUsage,
    DateTime? lastPinDate,
  }) {
    return Profile(
      uid: uid ?? _uid,
      username: username ?? _username,
      email: email ?? _email,
      profilePicturePath: profilePicturePath ?? _profilePicturePath,
      pinUsage: pinUsage ?? _pinUsage,
      lastPinDate: lastPinDate ?? _lastPinDate,
    );
  }

  late String _uid;
  late String _username;
  late String _email;
  late String? _profilePicturePath;
  late int _pinUsage;
  late DateTime _lastPinDate;

  String get uid => _uid;
  String get username => _username;
  String get email => _email;
  String? get profilePicturePath => _profilePicturePath;
  int get pinUsage => _pinUsage;
  DateTime get lastPinDate => _lastPinDate;

  set uid(String value) => _uid = value;
  set username(String value) => _username = value;
  set email(String value) => _email = value;
  set profilePicturePath(String? value) => _profilePicturePath = value;
  set pinUsage(int value) => _pinUsage = value;
  set lastPinDate(DateTime value) => _lastPinDate = value;

  factory Profile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Profile(
      uid: doc.id,
      username: data['username'],
      email: data['email'],
      profilePicturePath: data['profilePicturePath'],
      pinUsage: data['pinUsage'],
      // BUG FIX -> lastPinDate was crashing the application load preventing sign in/sign up. Fallback to 1970 to prevent null.
      lastPinDate:
          (data['lastPinDate'] as Timestamp?)?.toDate() ?? DateTime(1970),
    );
  }

  Map<String, dynamic> toMap() => {
    'username': _username,
    'email': _email,
    'profilePicturePath': _profilePicturePath,
    'pinUsage': _pinUsage,
    'lastPinDate': _lastPinDate,
  };
}
