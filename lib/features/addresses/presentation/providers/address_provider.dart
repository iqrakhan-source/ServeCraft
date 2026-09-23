import 'package:flutter/foundation.dart';
import 'package:prop_crm/core/base/view_state.dart';
import 'package:prop_crm/core/error/error_handler.dart';
import '../../data/models/address_model.dart';
import '../../domain/repositories/address_repository.dart';

class AddressProvider extends ChangeNotifier {
  final AddressRepository repository;

  ViewState<List<AddressModel>> _addressesState = ViewState.initial();
  AddressModel? _selectedAddress;
  bool _isActionLoading = false;
  String? _actionError;

  AddressProvider({required this.repository});

  ViewState<List<AddressModel>> get addressesState => _addressesState;
  List<AddressModel> get addresses => _addressesState.data ?? [];
  AddressModel? get selectedAddress => _selectedAddress;
  bool get isActionLoading => _isActionLoading;
  String? get actionError => _actionError;

  bool get isLoading => _addressesState.isLoading;
  bool get hasError => _addressesState.isError;
  bool get isEmpty => _addressesState.isEmpty;
  String? get errorMessage => _addressesState.errorMessage;

  AddressModel? get defaultAddress {
    try {
      return addresses.firstWhere((a) => a.isDefault);
    } catch (_) {
      return addresses.isNotEmpty ? addresses.first : null;
    }
  }

  /// Fetches saved addresses for the authenticated user
  Future<void> fetchAddresses({bool forceRefresh = false}) async {
    if (!forceRefresh && _addressesState.isSuccess && addresses.isNotEmpty) {
      return;
    }

    _addressesState = ViewState.loading();
    notifyListeners();

    try {
      final result = await repository.getAddresses();
      if (result.isEmpty) {
        _addressesState = ViewState.empty();
        _selectedAddress = null;
      } else {
        _addressesState = ViewState.success(result);
        // Default selection logic: preserve current selected if still present, or fallback to default
        if (_selectedAddress != null) {
          final stillPresent = result.any((a) => a.id == _selectedAddress!.id);
          if (!stillPresent) {
            _selectedAddress = defaultAddress;
          } else {
            // Update selected address object with latest data
            _selectedAddress = result.firstWhere((a) => a.id == _selectedAddress!.id);
          }
        } else {
          _selectedAddress = defaultAddress;
        }
      }
    } catch (e) {
      final appError = ErrorHandler.handleError(e);
      _addressesState = ViewState.error(
        appError.message,
        statusCode: appError.statusCode,
      );
    }

    notifyListeners();
  }

  /// Select an address for checkout or appointment
  void selectAddress(AddressModel address) {
    _selectedAddress = address;
    notifyListeners();
  }

  /// Create a new address and refresh list
  Future<bool> createAddress(AddressModel address) async {
    _isActionLoading = true;
    _actionError = null;
    notifyListeners();

    try {
      final created = await repository.createAddress(address);
      await fetchAddresses(forceRefresh: true);
      if (created.isDefault || _selectedAddress == null) {
        _selectedAddress = created;
      }
      _isActionLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      final appError = ErrorHandler.handleError(e);
      _actionError = appError.message;
      _isActionLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update an existing address and refresh list
  Future<bool> updateAddress(AddressModel address) async {
    _isActionLoading = true;
    _actionError = null;
    notifyListeners();

    try {
      final updated = await repository.updateAddress(address);
      await fetchAddresses(forceRefresh: true);
      if (_selectedAddress?.id == updated.id) {
        _selectedAddress = updated;
      }
      _isActionLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      final appError = ErrorHandler.handleError(e);
      _actionError = appError.message;
      _isActionLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete an address and refresh list
  Future<bool> deleteAddress(String id) async {
    _isActionLoading = true;
    _actionError = null;
    notifyListeners();

    try {
      await repository.deleteAddress(id);
      if (_selectedAddress?.id == id) {
        _selectedAddress = null;
      }
      await fetchAddresses(forceRefresh: true);
      _isActionLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      final appError = ErrorHandler.handleError(e);
      _actionError = appError.message;
      _isActionLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Mark an address as default
  Future<bool> setDefaultAddress(String id) async {
    _isActionLoading = true;
    _actionError = null;
    notifyListeners();

    try {
      await repository.setDefaultAddress(id);
      await fetchAddresses(forceRefresh: true);
      _isActionLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      final appError = ErrorHandler.handleError(e);
      _actionError = appError.message;
      _isActionLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearActionError() {
    _actionError = null;
    notifyListeners();
  }
}
