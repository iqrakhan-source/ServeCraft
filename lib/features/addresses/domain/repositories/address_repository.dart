import '../../data/models/address_model.dart';

abstract class AddressRepository {
  Future<List<AddressModel>> getAddresses();
  Future<AddressModel> getAddressById(String id);
  Future<AddressModel> createAddress(AddressModel address);
  Future<AddressModel> updateAddress(AddressModel address);
  Future<void> deleteAddress(String id);
  Future<AddressModel> setDefaultAddress(String id);
}
