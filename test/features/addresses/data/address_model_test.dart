import 'package:flutter_test/flutter_test.dart';
import 'package:prop_crm/features/addresses/data/models/address_model.dart';

void main() {
  group('AddressModel Tests', () {
    const address = AddressModel(
      id: 'addr_test_1',
      userId: 'usr_test_1',
      label: 'Home',
      houseNumber: 'Flat 402, Block B',
      addressLine: 'Queens Road, Vaishali Nagar',
      landmark: 'Near Vaishali Circle',
      city: 'Jaipur',
      state: 'Rajasthan',
      pincode: '302021',
      latitude: 26.9124,
      longitude: 75.7873,
      isDefault: true,
    );

    test('toJson and fromJson preserves all fields accurately', () {
      final json = address.toJson();
      final parsed = AddressModel.fromJson(json);

      expect(parsed.id, equals('addr_test_1'));
      expect(parsed.userId, equals('usr_test_1'));
      expect(parsed.label, equals('Home'));
      expect(parsed.houseNumber, equals('Flat 402, Block B'));
      expect(parsed.addressLine, equals('Queens Road, Vaishali Nagar'));
      expect(parsed.landmark, equals('Near Vaishali Circle'));
      expect(parsed.city, equals('Jaipur'));
      expect(parsed.state, equals('Rajasthan'));
      expect(parsed.pincode, equals('302021'));
      expect(parsed.latitude, equals(26.9124));
      expect(parsed.longitude, equals(75.7873));
      expect(parsed.isDefault, isTrue);
      expect(parsed, equals(address));
    });

    test('copyWith updates specified fields only', () {
      final updated = address.copyWith(
        label: 'Work',
        isDefault: false,
        houseNumber: 'Flat 101',
      );

      expect(updated.id, equals('addr_test_1'));
      expect(updated.label, equals('Work'));
      expect(updated.isDefault, isFalse);
      expect(updated.houseNumber, equals('Flat 101'));
      expect(updated.city, equals('Jaipur'));
    });

    test('formatting helpers output clean strings', () {
      expect(address.shortAddress, equals('Flat 402, Block B, Queens Road, Vaishali Nagar'));
      expect(address.localitySummary, equals('Jaipur, Rajasthan - 302021'));
      expect(
        address.formattedAddress,
        equals('Flat 402, Block B, Queens Road, Vaishali Nagar, Near Vaishali Circle, Jaipur, Rajasthan - 302021'),
      );

      const noLandmark = AddressModel(
        id: '2',
        userId: 'u',
        label: 'Work',
        houseNumber: '10',
        addressLine: 'Main St',
        city: 'Jaipur',
        state: 'Rajasthan',
        pincode: '302001',
      );
      expect(noLandmark.formattedAddress, equals('10, Main St, Jaipur, Rajasthan - 302001'));
    });
  });
}
