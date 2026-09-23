import '../../domain/repositories/address_repository.dart';
import '../datasources/address_remote_data_source.dart';
import '../models/address_model.dart';

class AddressRepositoryImpl implements AddressRepository {
  final AddressRemoteDataSource remoteDataSource;

  AddressRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<AddressModel>> getAddresses() {
    return remoteDataSource.getAddresses();
  }

  @override
  Future<AddressModel> getAddressById(String id) {
    return remoteDataSource.getAddressById(id);
  }

  @override
  Future<AddressModel> createAddress(AddressModel address) {
    return remoteDataSource.createAddress(address);
  }

  @override
  Future<AddressModel> updateAddress(AddressModel address) {
    return remoteDataSource.updateAddress(address);
  }

  @override
  Future<void> deleteAddress(String id) {
    return remoteDataSource.deleteAddress(id);
  }

  @override
  Future<AddressModel> setDefaultAddress(String id) {
    return remoteDataSource.setDefaultAddress(id);
  }
}
