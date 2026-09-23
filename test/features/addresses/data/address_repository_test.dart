import 'package:flutter_test/flutter_test.dart';
import 'package:prop_crm/core/networking/api_exceptions.dart';
import 'package:prop_crm/features/addresses/data/datasources/address_remote_data_source.dart';
import 'package:prop_crm/features/addresses/data/models/address_model.dart';
import 'package:prop_crm/features/addresses/data/repositories/address_repository_impl.dart';

void main() {
  group('AddressRepository & MockAddressRemoteDataSource Tests', () {
    late MockAddressRemoteDataSource dataSource;
    late AddressRepositoryImpl repository;

    setUp(() {
      dataSource = MockAddressRemoteDataSource();
      repository = AddressRepositoryImpl(remoteDataSource: dataSource);
    });

    test('getAddresses returns initial mock addresses with Jaipur location', () async {
      final addresses = await repository.getAddresses();

      expect(addresses.length, equals(3));
      expect(addresses.any((a) => a.city == 'Jaipur'), isTrue);
      expect(addresses.where((a) => a.isDefault).length, equals(1));
    });

    test('getAddressById returns matching address', () async {
      final address = await repository.getAddressById('addr_1');

      expect(address.id, equals('addr_1'));
      expect(address.label, equals('Home'));
      expect(address.isDefault, isTrue);
    });

    test('getAddressById throws NotFoundException for invalid id', () async {
      expect(
        () => repository.getAddressById('invalid_addr'),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('createAddress adds address and sets default properly', () async {
      const newAddress = AddressModel(
        id: '',
        userId: 'usr_current',
        label: 'Gym',
        houseNumber: 'Plot 45',
        addressLine: 'Tonk Road',
        city: 'Jaipur',
        state: 'Rajasthan',
        pincode: '302015',
        isDefault: true,
      );

      final created = await repository.createAddress(newAddress);
      expect(created.id, isNotEmpty);
      expect(created.label, equals('Gym'));
      expect(created.isDefault, isTrue);

      final all = await repository.getAddresses();
      expect(all.length, equals(4));

      // Previous default ('addr_1') must now be isDefault: false
      final addr1 = all.firstWhere((a) => a.id == 'addr_1');
      expect(addr1.isDefault, isFalse);
    });

    test('updateAddress updates fields and handles default state', () async {
      final existing = await repository.getAddressById('addr_2');
      final updated = existing.copyWith(
        houseNumber: 'Office Suite 500',
        isDefault: true,
      );

      final result = await repository.updateAddress(updated);
      expect(result.houseNumber, equals('Office Suite 500'));
      expect(result.isDefault, isTrue);

      final all = await repository.getAddresses();
      final addr1 = all.firstWhere((a) => a.id == 'addr_1');
      expect(addr1.isDefault, isFalse);
    });

    test('setDefaultAddress updates default flag across addresses', () async {
      await repository.setDefaultAddress('addr_2');

      final all = await repository.getAddresses();
      final addr1 = all.firstWhere((a) => a.id == 'addr_1');
      final addr2 = all.firstWhere((a) => a.id == 'addr_2');

      expect(addr1.isDefault, isFalse);
      expect(addr2.isDefault, isTrue);
    });

    test('deleteAddress removes address and sets fallback default if default is deleted', () async {
      // addr_1 is default initially
      await repository.deleteAddress('addr_1');

      final all = await repository.getAddresses();
      expect(all.length, equals(2));
      expect(all.any((a) => a.id == 'addr_1'), isFalse);

      // Remaining first address ('addr_2') should now be marked default
      final addr2 = all.firstWhere((a) => a.id == 'addr_2');
      expect(addr2.isDefault, isTrue);
    });
  });
}
