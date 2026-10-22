import 'package:flutter/foundation.dart';
import 'package:prop_crm/core/base/view_state.dart';
import 'package:prop_crm/core/error/error_handler.dart';

import '../../data/models/service_model.dart';
import '../../data/models/service_package_model.dart';
import '../../data/models/service_products_response.dart';
import '../../domain/repositories/service_repository.dart';

class ServiceDetailsProvider extends ChangeNotifier {
  final ServiceRepository repository;

  ViewState<ServiceModel> _serviceState = ViewState.initial();
  ViewState<ServiceProductsResponse> _productsState =
  ViewState.initial();

  ServicePackageModel? _selectedPackage;

  ServiceDetailsProvider({required this.repository});

  // Existing service state
  ViewState<ServiceModel> get serviceState => _serviceState;
  ServiceModel? get service => _serviceState.data;
  ServicePackageModel? get selectedPackage => _selectedPackage;

  bool get isLoading => _serviceState.isLoading;
  bool get hasError => _serviceState.isError;
  String? get errorMessage => _serviceState.errorMessage;

  // Products API state
  ViewState<ServiceProductsResponse> get productsState =>
      _productsState;

  ServiceProductsResponse? get productsResponse =>
      _productsState.data;

  List<ConsumableProduct> get products =>
      _productsState.data?.products ?? [];

  bool get isProductsLoading => _productsState.isLoading;
  bool get hasProductsError => _productsState.isError;
  String? get productsErrorMessage => _productsState.errorMessage;

  Future<void> fetchServiceDetails(String serviceId) async {
    _serviceState = ViewState.loading();
    _selectedPackage = null;
    notifyListeners();

    try {
      final fetchedService = await repository.getServiceById(serviceId);
      _serviceState = ViewState.success(fetchedService);

        if (fetchedService.packages.isNotEmpty) {
        _selectedPackage = fetchedService.packages.first;
      }
    } catch (e) {
      final appError = ErrorHandler.handleError(e);
      _serviceState = ViewState.error(
        appError.message,
        statusCode: appError.statusCode,
      );
    }

    notifyListeners();
  }

  // New: fetch products associated with this service.
  Future<void> fetchProductsForService(String serviceId) async {
    _productsState = ViewState.loading();
    notifyListeners();

    try {
      final response = await repository.getProductsForService(serviceId);
      _productsState = ViewState.success(response);
    } catch (e) {
      final appError = ErrorHandler.handleError(e);
      _productsState = ViewState.error(
        appError.message,
        statusCode: appError.statusCode,
      );
    }

    notifyListeners();
  }

  void selectPackage(ServicePackageModel package) {
    _selectedPackage = package;
    notifyListeners();
  }
}