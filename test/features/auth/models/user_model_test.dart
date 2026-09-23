import 'package:flutter_test/flutter_test.dart';
import 'package:prop_crm/features/auth/data/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('serializes to and from JSON correctly', () {
      final now = DateTime.now();
      final user = UserModel(
        id: 'usr_123',
        name: 'Alex Morgan',
        phone: '9876543210',
        email: 'alex@example.com',
        profileImage: 'https://example.com/avatar.jpg',
        isProfileComplete: true,
        createdAt: now,
        updatedAt: now,
      );

      final json = user.toJson();
      expect(json['id'], equals('usr_123'));
      expect(json['name'], equals('Alex Morgan'));
      expect(json['phone'], equals('9876543210'));
      expect(json['isProfileComplete'], isTrue);

      final deserialized = UserModel.fromJson(json);
      expect(deserialized.id, equals(user.id));
      expect(deserialized.name, equals(user.name));
      expect(deserialized.phone, equals(user.phone));
      expect(deserialized.email, equals(user.email));
      expect(deserialized.isProfileComplete, isTrue);
    });

    test('copyWith updates fields without mutating originals', () {
      final user = UserModel(
        id: 'usr_1',
        name: 'Original Name',
        phone: '9876543210',
        email: '',
        isProfileComplete: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final updated = user.copyWith(
        name: 'Updated Name',
        isProfileComplete: true,
      );

      expect(updated.name, equals('Updated Name'));
      expect(updated.isProfileComplete, isTrue);
      expect(updated.phone, equals(user.phone));
      expect(user.name, equals('Original Name'));
      expect(user.isProfileComplete, isFalse);
    });
  });
}
