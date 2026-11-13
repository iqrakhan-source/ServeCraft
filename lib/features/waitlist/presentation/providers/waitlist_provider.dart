import 'package:flutter/foundation.dart';
import 'package:prop_crm/core/base/view_state.dart';
import 'package:prop_crm/core/error/error_handler.dart';
import '../../data/models/join_waitlist_response_model.dart';
import '../../data/models/waitlist_entry_model.dart';
import '../../domain/repositories/waitlist_repository.dart';

class WaitlistProvider extends ChangeNotifier {
  final WaitlistRepository repository;

  WaitlistProvider({required this.repository});

  ViewState<List<WaitlistEntryModel>> _waitlistState = ViewState.initial();
  ViewState<List<WaitlistEntryModel>> get waitlistState => _waitlistState;
  List<WaitlistEntryModel> get entries => _waitlistState.data ?? [];

  bool _isJoining = false;
  bool get isJoining => _isJoining;
  String? _joinMessage;
  String? get joinMessage => _joinMessage;

  Future<void> loadMyWaitlist() async {
    _waitlistState = ViewState.loading();
    notifyListeners();

    try {
      final data = await repository.getMyWaitlist();
      _waitlistState = ViewState.success(data);
    } catch (e) {
      final appError = ErrorHandler.handleError(e);
      _waitlistState = ViewState.error(appError.message);
    }

    notifyListeners();
  }

  Future<JoinWaitlistResponseModel?> joinWaitlist({
    required String branchId,
    required String serviceId,
    String? preferredTime,
    String? notes,
  }) async {
    _isJoining = true;
    _joinMessage = null;
    notifyListeners();

    try {
      final response = await repository.joinWaitlist(
        branchId: branchId,
        serviceId: serviceId,
        preferredTime: preferredTime,
        notes: notes,
      );
      _joinMessage = response.message;
      await loadMyWaitlist();
      return response;
    } catch (e) {
      final appError = ErrorHandler.handleError(e);
      _joinMessage = appError.message;
      return null;
    } finally {
      _isJoining = false;
      notifyListeners();
    }
  }
}
