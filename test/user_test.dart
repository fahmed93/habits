import 'package:flutter_test/flutter_test.dart';
import 'package:habits/models/user.dart';

void main() {
  group('User Model Tests', () {
    test('User toJson should serialize all fields correctly', () {
      final user = User(
        uid: 'user123',
        email: 'test@example.com',
        displayName: 'Test User',
        photoURL: 'https://example.com/photo.jpg',
      );

      final json = user.toJson();

      expect(json['uid'], 'user123');
      expect(json['email'], 'test@example.com');
      expect(json['displayName'], 'Test User');
      expect(json['photoURL'], 'https://example.com/photo.jpg');
    });

    test('User toJson should handle null optional fields', () {
      final user = User(
        uid: 'user123',
      );

      final json = user.toJson();

      expect(json['uid'], 'user123');
      expect(json['email'], null);
      expect(json['displayName'], null);
      expect(json['photoURL'], null);
    });

    test('User fromJson should deserialize all fields correctly', () {
      final json = {
        'uid': 'user123',
        'email': 'test@example.com',
        'displayName': 'Test User',
        'photoURL': 'https://example.com/photo.jpg',
      };

      final user = User.fromJson(json);

      expect(user.uid, 'user123');
      expect(user.email, 'test@example.com');
      expect(user.displayName, 'Test User');
      expect(user.photoURL, 'https://example.com/photo.jpg');
    });

    test('User fromJson should handle null optional fields', () {
      final json = {
        'uid': 'user123',
        'email': null,
        'displayName': null,
        'photoURL': null,
      };

      final user = User.fromJson(json);

      expect(user.uid, 'user123');
      expect(user.email, null);
      expect(user.displayName, null);
      expect(user.photoURL, null);
    });

    test('User fromJson and toJson should be symmetric', () {
      final originalUser = User(
        uid: 'user456',
        email: 'another@example.com',
        displayName: 'Another User',
        photoURL: 'https://example.com/another.jpg',
      );

      final json = originalUser.toJson();
      final deserializedUser = User.fromJson(json);

      expect(deserializedUser.uid, originalUser.uid);
      expect(deserializedUser.email, originalUser.email);
      expect(deserializedUser.displayName, originalUser.displayName);
      expect(deserializedUser.photoURL, originalUser.photoURL);
    });
  });
}
