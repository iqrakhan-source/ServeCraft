import 'package:flutter/foundation.dart';
import 'package:prop_crm/core/base/view_state.dart';
import 'package:prop_crm/core/error/error_handler.dart';

import '../../data/models/service_model.dart';
import '../../data/models/service_package_model.dart';
import '../../data/models/service_products_response.dart';
import '../../domain/repositories/service_repository.dart';

class ServiceDetailsProvider extends ChangeNotifier {
  final ServiceRepository repository;

  ServiceDetailsProvider({
    required this.repository,
  });


  ViewState<ServiceModel> _serviceState = ViewState.initial();
  ViewState<ServiceProductsResponse> _productsState =
  ViewState.initial();

  ServicePackageModel? _selectedPackage;
  ConsumableProduct? _selectedProduct;

  void setService(ServiceModel service) {
    _serviceState = ViewState.success(service);
    _selectedPackage = null;
    if (service.packages.isNotEmpty) {
      _selectedPackage = service.packages.first;
    }
    notifyListeners();
  }

  // Existing service state
  ViewState<ServiceModel> get serviceState => _serviceState;
  ServiceModel? get service => _serviceState.data;
  ServicePackageModel? get selectedPackage => _selectedPackage;
  ConsumableProduct? get selectedProduct => _selectedProduct;

  double get totalPrice {
    final base = _selectedPackage?.price ?? _serviceState.data?.startingPrice ?? 0.0;
    final add = _selectedProduct?.addedPrice ?? 0.0;
    return base + add;
  }

  int get totalDurationMinutes {
    final base = _serviceState.data?.durationInMinutes ?? 45;
    final add = _selectedProduct?.addedDuration ?? 0;
    return base + add;
  }

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

  void selectProduct(ConsumableProduct? product) {
    _selectedProduct = product;
    notifyListeners();
  }
}