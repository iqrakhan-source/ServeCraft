import 'package:flutter/foundation.dart';
import 'package:prop_crm/core/base/view_state.dart';
import 'package:prop_crm/core/error/error_handler.dart';
import '../../data/models/service_model.dart';
import '../../data/models/service_package_model.dart';
import '../../domain/repositories/service_repository.dart';

class ServiceDetailsProvider extends ChangeNotifier {
  final ServiceRepository repository;

  ViewState<ServiceModel> _serviceState = ViewState.initial();
  ServicePackageModel? _selectedPackage;

  ServiceDetailsProvider({required this.repository});

  ViewState<ServiceModel> get serviceState => _serviceState;
  ServiceModel? get service => _serviceState.data;
  ServicePackageModel? get selectedPackage => _selectedPackage;

  bool get isLoading => _serviceState.isLoading;
  bool get hasError => _serviceState.isError;
  String? get errorMessage => _serviceState.errorMessage;

  Future<void> fetchServiceDetails(String serviceId) async {
    _serviceState = ViewState.loading();
    _selectedPackage = null;
    notifyListeners();

    try {
      final service = await repository.getServiceById(serviceId);
      _serviceState = ViewState.success(service);
      if (service.packages.isNotEmpty) {
        _selectedPackage = service.packages.first;
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

  void selectPackage(ServicePackageModel package) {
    _selectedPackage = package;
    notifyListeners();
  }
}
