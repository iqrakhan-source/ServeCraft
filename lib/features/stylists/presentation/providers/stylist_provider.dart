import 'package:flutter/foundation.dart';
import 'package:prop_crm/core/base/view_state.dart';
import 'package:prop_crm/core/error/error_handler.dart';
import '../../data/models/stylist_model.dart';
import '../../domain/repositories/stylist_repository.dart';

class StylistProvider extends ChangeNotifier {
  final StylistRepository repository;

  ViewState<List<StylistModel>> _stylistsState = ViewState.initial();
  StylistModel _selectedStylist = StylistModel.anyStylist;

  StylistProvider({required this.repository});

  ViewState<List<StylistModel>> get stylistsState => _stylistsState;
  List<StylistModel> get stylists => _stylistsState.data ?? [];
  StylistModel get selectedStylist => _selectedStylist;
  bool get isLoading => _stylistsState.isLoading;

  Future<void> loadStylists({
    required String branchId,
    String? serviceId,
    String? date,
    String? timeSlot,
  }) async {
    _stylistsState = ViewState.loading();
    notifyListeners();

    try {
      final list = await repository.getStylists(
        branchId: branchId,
        serviceId: serviceId,
        date: date,
        timeSlot: timeSlot,
      );

      _stylistsState = ViewState.success(list);
    } catch (e) {
      final appError = ErrorHandler.handleError(e);
      _stylistsState = ViewState.error(
        appError.message,
        statusCode: appError.statusCode,
      );
    }

    notifyListeners();
  }

  void selectStylist(StylistModel stylist) {
    _selectedStylist = stylist;
    notifyListeners();
  }

  void reset() {
    _stylistsState = ViewState.initial();
    _selectedStylist = StylistModel.anyStylist;
    notifyListeners();
  }
}
