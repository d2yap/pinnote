import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pinnote/models/pin.dart';

// Arrange
Pin makePin({
  String id = 'pin1',
  String uid = 'user1',
  String username = 'testuser',
  String note = 'hello',
  int reports = 0,
  bool markedForDeletion = false,
}) {
  return Pin(
    id: id,
    uid: uid,
    username: username,
    note: note,
    createdAt: DateTime(2024),
    location: const GeoPoint(53.5, -113.5),
    geohash: 'abc123',
    reports: reports,
    markedForDeletion: markedForDeletion,
  );
}

void main() {
  /// pin tests
  group('pin creation tests', () {
    test('creates a pin with correct values', () {
      // Act
      final pin = makePin(id: 'pin1', note: 'hello');

      // Assert
      expect(pin.id, 'pin1');
      expect(pin.note, 'hello');
      expect(pin.markedForDeletion, false);
      expect(pin.reports, 0);
    });

    test('throws when note is empty', () {
      // Assert
      expect(() => makePin(note: ''), throwsArgumentError);
    });

    test('throws when note exceeds 50 characters', () {
      // Assert
      expect(() => makePin(note: 'a' * 51), throwsArgumentError);
    });

    test('accepts note at exactly 50 characters', () {
      // Act
      final pin = makePin(note: 'a' * 50);
      // Assert
      expect(pin.note.length, 50);
    });

    test('note setter throws when empty', () {
      // Act
      final pin = makePin();

      // Assert
      expect(() => pin.note = '', throwsArgumentError);
    });

    test('note setter throws when over 50 characters', () {
      // Act
      final pin = makePin();

      // Assert
      expect(() => pin.note = 'a' * 51, throwsArgumentError);
    });

    test('note setter updates value when valid', () {
      // Act
      final pin = makePin();
      pin.note = 'updated note';

      // Assert
      expect(pin.note, 'updated note');
    });
  });

  /// copyWith tests
  group('copyWith tests', () {
    test('copyWith returns new pin with updated fields', () {
      // Act
      final pin = makePin(note: 'original');
      final updated = pin.copyWith(note: 'updated');

      // Assert
      expect(updated.note, 'updated');
      expect(pin.note, 'original');
    });

    test('copyWith keeps original values when nothing passed', () {
      // Act
      final pin = makePin(id: 'pin1', username: 'testuser');
      final copy = pin.copyWith();

      // Assert
      expect(copy.id, 'pin1');
      expect(copy.username, 'testuser');
    });
  });
}
