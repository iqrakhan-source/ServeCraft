import 'package:flutter/foundation.dart';
import '../../../../core/base/view_state.dart';
import '../../../../core/storage/storage_service.dart';
import '../../data/models/branch_model.dart';
import '../../data/models/chair_availability_model.dart';
import '../../domain/repositories/branch_repository.dart';

class BranchProvider extends ChangeNotifier {
  final BranchRepository repository;
  final StorageService? storageService;

  static const String _storageKeyBranchId = 'selected_salon_branch_id';

  ViewState<List<BranchModel>> _branchesState = ViewState.initial();
  BranchModel? _selectedBranch;
  String? _errorMessage;

  BranchProvider({required this.repository, this.storageService}) {
    loadBranches();
  }

  ViewState<List<BranchModel>> get branchesState => _branchesState;
  List<BranchModel> get branches => _branchesState.data ?? [];
  List<BranchModel> get activeBranches =>
      branches.where((b) => b.isActive).toList();
  BranchModel? get selectedBranch => _selectedBranch;
  bool get isLoading => _branchesState.isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadBranches({
    double? lat,
    double? lng,
    double? radiusKm,
    String? city,
    String? search,
    bool activeOnly = false,
  }) async {
    _branchesState = ViewState.loading();
    notifyListeners();

    try {
      final list = await repository.getBranches(
        lat: lat,
        lng: lng,
        radiusKm: radiusKm,
        city: city,
        search: search,
        activeOnly: activeOnly,
      );

      _branchesState = ViewState.success(list);

      final savedId = storageService?.getString(_storageKeyBranchId);

      // Restore only a valid, active saved branch.
      if (savedId != null && savedId.isNotEmpty) {
        final matchingBranches = list
            .where((branch) => branch.id == savedId && branch.isActive)
            .cast<BranchModel>();

        _selectedBranch = matchingBranches.isNotEmpty
            ? matchingBranches.first
            : null;
      } else {
        _selectedBranch = null;
      }

      _errorMessage = null;
    } catch (e) {
      _branchesState = ViewState.error(e.toString());
      _errorMessage = e.toString();
      _selectedBranch = null;
    }

    notifyListeners();
  }

  Future<bool> selectBranch(BranchModel branch) async {
    if (!branch.isActive) {
      _errorMessage =
          'This salon branch is temporarily closed and cannot accept new bookings.';
      notifyListeners();
      return false;
    }

    if (storageService == null) {
      _errorMessage = 'Unable to save selected branch.';
      notifyListeners();
      return false;
    }

    try {
      final saved = await storageService!.setString(
        _storageKeyBranchId,
        branch.id,
      );

      final storedId = storageService!.getString(_storageKeyBranchId);

      if (!saved || storedId != branch.id) {
        _errorMessage = 'Failed to save selected branch.';
        notifyListeners();
        return false;
      }

      _selectedBranch = branch;
      _errorMessage = null;
      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = 'Unable to save selected branch.';
      notifyListeners();
      return false;
    }
  }

  Future<ChairAvailabilityModel?> checkChairAvailability({
    required String branchId,
    required String date,
    required String timeSlot,
    int? duration,
  }) async {
    try {
      return await repository.getChairAvailability(
        branchId: branchId,
        date: date,
        timeSlot: timeSlot,
        duration: duration,
      );
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }
}
