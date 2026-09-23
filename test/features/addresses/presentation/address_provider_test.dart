import 'package:flutter_test/flutter_test.dart';
import 'package:prop_crm/features/addresses/data/datasources/address_remote_data_source.dart';
import 'package:prop_crm/features/addresses/data/models/address_model.dart';
import 'package:prop_crm/features/addresses/data/repositories/address_repository_impl.dart';
import 'package:prop_crm/features/addresses/presentation/providers/address_provider.dart';

void main() {
  group('AddressProvider State Management Tests', () {
    late MockAddressRemoteDataSource dataSource;
    late AddressRepositoryImpl repository;
    late AddressProvider provider;

    setUp(() {
      dataSource = MockAddressRemoteDataSource();
      repository = AddressRepositoryImpl(remoteDataSource: dataSource);
      provider = AddressProvider(repository: repository);
    });

    test('initial state is uninitialized', () {
      expect(provider.isLoading, isFalse);
      expect(provider.addresses, isEmpty);
      expect(provider.selectedAddress, isNull);
    });

    test('fetchAddresses populates addresses and auto-selects default address', () async {
      await provider.fetchAddresses();

      expect(provider.isLoading, isFalse);
      expect(provider.addresses.length, equals(3));
      expect(provider.selectedAddress, isNotNull);
      expect(provider.selectedAddress!.isDefault, isTrue);
      expect(provider.selectedAddress!.label, equals('Home'));
    });

    test('selectAddress updates selectedAddress', () async {
      await provider.fetchAddresses();
      final workAddress = provider.addresses.firstWhere((a) => a.label == 'Work');

      provider.selectAddress(workAddress);
      expect(provider.selectedAddress!.id, equals(workAddress.id));
      expect(provider.selectedAddress!.label, equals('Work'));
    });

    test('createAddress adds address and refreshes list', () async {
      await provider.fetchAddresses();

      const newAddr = AddressModel(
        id: '',
        userId: 'usr_current',
        label: 'Studio',
        houseNumber: '12',
        addressLine: 'MI Road',
        city: 'Jaipur',
        state: 'Rajasthan',
        pincode: '302001',
      );

      final success = await provider.createAddress(newAddr);
      expect(success, isTrue);
      expect(provider.addresses.length, equals(4));
      expect(provider.addresses.any((a) => a.label == 'Studio'), isTrue);
    });

    test('updateAddress modifies address and updates selection', () async {
      await provider.fetchAddresses();
      final addr1 = provider.addresses.firstWhere((a) => a.id == 'addr_1');

      final updated = addr1.copyWith(houseNumber: 'Penthouse 901');
      final success = await provider.updateAddress(updated);

      expect(success, isTrue);
      expect(provider.selectedAddress?.houseNumber, equals('Penthouse 901'));
    });

    test('deleteAddress removes address from list', () async {
      await provider.fetchAddresses();

      final success = await provider.deleteAddress('addr_3');
      expect(success, isTrue);
      expect(provider.addresses.length, equals(2));
      expect(provider.addresses.any((a) => a.id == 'addr_3'), isFalse);
    });

    test('setDefaultAddress sets default address', () async {
      await provider.fetchAddresses();

      final success = await provider.setDefaultAddress('addr_2');
      expect(success, isTrue);

      final defaultAddr = provider.defaultAddress;
      expect(defaultAddr?.id, equals('addr_2'));
      expect(defaultAddr?.isDefault, isTrue);
    });
  });
}
