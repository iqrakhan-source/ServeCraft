import 'package:flutter/foundation.dart';
import 'package:prop_crm/core/base/view_state.dart';
import 'package:prop_crm/core/error/error_handler.dart';
import '../../data/models/service_model.dart';
import '../../domain/repositories/service_repository.dart';

class ServiceProvider extends ChangeNotifier {
  final ServiceRepository repository;

  ViewState<List<ServiceModel>> _servicesState = ViewState.initial();
  String? _currentCategoryId;
  String _currentQuery = '';

  ServiceProvider({required this.repository});

  ViewState<List<ServiceModel>> get servicesState => _servicesState;
  List<ServiceModel> get services => _servicesState.data ?? [];
  String? get currentCategoryId => _currentCategoryId;
  String get currentQuery => _currentQuery;

  bool get isLoading => _servicesState.isLoading;
  bool get hasError => _servicesState.isError;
  bool get isEmpty => _servicesState.isEmpty;
  String? get errorMessage => _servicesState.errorMessage;

  Future<void> fetchServices({
    String? categoryId,
    String? query,
    bool forceRefresh = false,
  }) async {
    _currentCategoryId = categoryId;
    if (query != null) _currentQuery = query;

    _servicesState = ViewState.loading();
    notifyListeners();

    try {
      final result = await repository.getServices(
        categoryId: _currentCategoryId,
        query: _currentQuery.isNotEmpty ? _currentQuery : null,
      );

      if (result.isEmpty) {
        _servicesState = ViewState.empty();
      } else {
        _servicesState = ViewState.success(result);
      }
    } catch (e) {
      final appError = ErrorHandler.handleError(e);
      _servicesState = ViewState.error(
        appError.message,
        statusCode: appError.statusCode,
      );
    }

    notifyListeners();
  }

  Future<void> searchServices(String query) async {
    _currentQuery = query;
    await fetchServices(categoryId: _currentCategoryId, query: _currentQuery);
  }

  Future<void> clearFilter() async {
    _currentCategoryId = null;
    _currentQuery = '';
    await fetchServices();
  }
}
