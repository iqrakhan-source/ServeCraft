import 'package:prop_crm/core/constants/api_constants.dart';
import 'package:prop_crm/core/networking/api_exceptions.dart';
import 'package:prop_crm/core/networking/api_service.dart';
import '../models/address_model.dart';

abstract class AddressRemoteDataSource {
  Future<List<AddressModel>> getAddresses();
  Future<AddressModel> getAddressById(String id);
  Future<AddressModel> createAddress(AddressModel address);
  Future<AddressModel> updateAddress(AddressModel address);
  Future<void> deleteAddress(String id);
  Future<AddressModel> setDefaultAddress(String id);
}

/// Production implementation connecting to REST backend via ApiService
class AddressRemoteDataSourceImpl implements AddressRemoteDataSource {
  final ApiService apiService;

  AddressRemoteDataSourceImpl({required this.apiService});

  @override
  Future<List<AddressModel>> getAddresses() async {
    final response = await apiService.get<List<AddressModel>>(
      ApiConstants.addresses,
      fromJson: (json) {
        if (json is List) {
          return json
              .map((item) =>
                  AddressModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
    );
    return response.data ?? [];
  }

  @override
  Future<AddressModel> getAddressById(String id) async {
    final response = await apiService.get<AddressModel>(
      ApiConstants.addressById(id),
      fromJson: (json) => AddressModel.fromJson(json as Map<String, dynamic>),
    );
    if (response.data == null) {
      throw NotFoundException(message: 'Address with id $id not found');
    }
    return response.data!;
  }

  @override
  Future<AddressModel> createAddress(AddressModel address) async {
    final response = await apiService.post<AddressModel>(
      ApiConstants.addresses,
      data: address.toJson(),
      fromJson: (json) => AddressModel.fromJson(json as Map<String, dynamic>),
    );
    if (response.data == null) {
      throw const ServerException(message: 'Failed to create address');
    }
    return response.data!;
  }

  @override
  Future<AddressModel> updateAddress(AddressModel address) async {
    final response = await apiService.put<AddressModel>(
      ApiConstants.addressById(address.id),
      data: address.toJson(),
      fromJson: (json) => AddressModel.fromJson(json as Map<String, dynamic>),
    );
    if (response.data == null) {
      throw const ServerException(message: 'Failed to update address');
    }
    return response.data!;
  }

  @override
  Future<void> deleteAddress(String id) async {
    await apiService.delete<void>(ApiConstants.addressById(id));
  }

  @override
  Future<AddressModel> setDefaultAddress(String id) async {
    final response = await apiService.patch<AddressModel>(
      ApiConstants.setDefaultAddress(id),
      fromJson: (json) => AddressModel.fromJson(json as Map<String, dynamic>),
    );
    if (response.data == null) {
      throw const ServerException(message: 'Failed to set default address');
    }
    return response.data!;
  }
}

/// TEMPORARY: Isolated in-memory mock data source until live REST backend is deployed.
class MockAddressRemoteDataSource implements AddressRemoteDataSource {
  final List<AddressModel> _mockAddresses = [
    const AddressModel(
      id: 'addr_1',
      userId: 'usr_current',
      label: 'Home',
      houseNumber: 'Flat 402, Royal Palms',
      addressLine: 'Queens Road, Vaishali Nagar',
      landmark: 'Near Vaishali Circle',
      city: 'Jaipur',
      state: 'Rajasthan',
      pincode: '302021',
      latitude: 26.9124,
      longitude: 75.7873,
      isDefault: true,
    ),
    const AddressModel(
      id: 'addr_2',
      userId: 'usr_current',
      label: 'Work',
      houseNumber: 'Office 305, World Trade Park',
      addressLine: 'JLN Marg, Malviya Nagar',
      landmark: 'Near Gaurav Tower',
      city: 'Jaipur',
      state: 'Rajasthan',
      pincode: '302017',
      latitude: 26.8530,
      longitude: 75.8050,
      isDefault: false,
    ),
    const AddressModel(
      id: 'addr_3',
      userId: 'usr_current',
      label: 'Other',
      houseNumber: 'Villa 18, Green Meadows',
      addressLine: 'Madhyam Marg, Mansarovar',
      landmark: 'Near Mansarovar Metro Station',
      city: 'Jaipur',
      state: 'Rajasthan',
      pincode: '302020',
      latitude: 26.8688,
      longitude: 75.7667,
      isDefault: false,
    ),
  ];

  @override
  Future<List<AddressModel>> getAddresses() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return List<AddressModel>.from(_mockAddresses);
  }

  @override
  Future<AddressModel> getAddressById(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _mockAddresses.indexWhere((a) => a.id == id);
    if (index == -1) {
      throw NotFoundException(message: 'Address with id $id not found');
    }
    return _mockAddresses[index];
  }

  @override
  Future<AddressModel> createAddress(AddressModel address) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final newId = address.id.isNotEmpty
        ? address.id
        : 'addr_${DateTime.now().millisecondsSinceEpoch}';

    final shouldBeDefault = address.isDefault || _mockAddresses.isEmpty;

    if (shouldBeDefault) {
      for (int i = 0; i < _mockAddresses.length; i++) {
        _mockAddresses[i] = _mockAddresses[i].copyWith(isDefault: false);
      }
    }

    final created = address.copyWith(
      id: newId,
      isDefault: shouldBeDefault,
    );
    _mockAddresses.add(created);
    return created;
  }

  @override
  Future<AddressModel> updateAddress(AddressModel address) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _mockAddresses.indexWhere((a) => a.id == address.id);
    if (index == -1) {
      throw NotFoundException(message: 'Address with id ${address.id} not found');
    }

    if (address.isDefault) {
      for (int i = 0; i < _mockAddresses.length; i++) {
        _mockAddresses[i] = _mockAddresses[i].copyWith(isDefault: false);
      }
    }

    _mockAddresses[index] = address;
    return address;
  }

  @override
  Future<void> deleteAddress(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _mockAddresses.indexWhere((a) => a.id == id);
    if (index == -1) {
      throw NotFoundException(message: 'Address with id $id not found');
    }

    final wasDefault = _mockAddresses[index].isDefault;
    _mockAddresses.removeAt(index);

    // If deleted address was default and there are remaining addresses, set the first as default
    if (wasDefault && _mockAddresses.isNotEmpty) {
      _mockAddresses[0] = _mockAddresses[0].copyWith(isDefault: true);
    }
  }

  @override
  Future<AddressModel> setDefaultAddress(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _mockAddresses.indexWhere((a) => a.id == id);
    if (index == -1) {
      throw NotFoundException(message: 'Address with id $id not found');
    }

    for (int i = 0; i < _mockAddresses.length; i++) {
      _mockAddresses[i] = _mockAddresses[i].copyWith(isDefault: i == index);
    }

    return _mockAddresses[index];
  }
}
