import 'package:flutter/foundation.dart';
import 'package:prop_crm/core/base/view_state.dart';
import 'package:prop_crm/core/error/error_handler.dart';
import 'package:prop_crm/features/home/data/models/home_data_model.dart';
import 'package:prop_crm/features/home/domain/repositories/home_repository.dart';

class HomeProvider extends ChangeNotifier {
  final HomeRepository repository;

  ViewState<HomeDataModel> _homeState = ViewState.initial();
  String _currentAddress = 'Home • Indiranagar, Bengaluru';

  HomeProvider({required this.repository});

  ViewState<HomeDataModel> get homeState => _homeState;
  HomeDataModel? get homeData => _homeState.data;
  String get currentAddress => _currentAddress;

  bool get isLoading => _homeState.isLoading;
  bool get hasError => _homeState.isError;
  bool get isEmpty => _homeState.isEmpty;
  String? get errorMessage => _homeState.errorMessage;

  Future<void> fetchHomeData({bool forceRefresh = false}) async {
    if (!forceRefresh && _homeState.isSuccess && homeData != null) {
      return;
    }

    _homeState = ViewState.loading();
    notifyListeners();

    try {
      final data = await repository.getHomeData();
      if (data.categories.isEmpty && data.popularServices.isEmpty) {
        _homeState = ViewState.empty();
      } else {
        _homeState = ViewState.success(data);
      }
    } catch (e) {
      final appError = ErrorHandler.handleError(e);
      _homeState = ViewState.error(
        appError.message,
        statusCode: appError.statusCode,
      );
    }

    notifyListeners();
  }

  void updateLocation(String newAddress) {
    _currentAddress = newAddress;
    notifyListeners();
  }
}
