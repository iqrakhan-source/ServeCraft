import 'package:flutter/foundation.dart';
import '../../../../core/base/view_state.dart';
import '../../../../core/storage/storage_service.dart';
import '../../data/models/branch_model.dart';
import '../../domain/repositories/branch_repository.dart';

class BranchProvider extends ChangeNotifier {
  final BranchRepository repository;
  final StorageService? storageService;

  static const String _storageKeyBranchId = 'selected_salon_branch_id';

  ViewState<List<BranchModel>> _branchesState = ViewState.initial();
  BranchModel? _selectedBranch;
  String? _errorMessage;

  BranchProvider({
    required this.repository,
    this.storageService,
  }) {
    loadBranches();
  }

  ViewState<List<BranchModel>> get branchesState => _branchesState;
  List<BranchModel> get branches => _branchesState.data ?? [];
  List<BranchModel> get activeBranches =>
      branches.where((b) => b.isActive).toList();
  BranchModel? get selectedBranch => _selectedBranch;
  bool get isLoading => _branchesState.isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadBranches({bool activeOnly = false}) async {
    _branchesState = ViewState.loading();
    notifyListeners();

    try {
      final list = await repository.getBranches(activeOnly: activeOnly);
      _branchesState = ViewState.success(list);

      // Restore previously saved branch or default to first active branch
      final savedId = storageService?.getString(_storageKeyBranchId);
      if (savedId != null && list.any((b) => b.id == savedId && b.isActive)) {
        _selectedBranch = list.firstWhere((b) => b.id == savedId);
      } else if (list.any((b) => b.isActive)) {
        _selectedBranch = list.firstWhere((b) => b.isActive);
      } else if (list.isNotEmpty) {
        _selectedBranch = list.first;
      }
      _errorMessage = null;
    } catch (e) {
      _branchesState = ViewState.error(e.toString());
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  bool selectBranch(BranchModel branch) {
    if (!branch.isActive) {
      _errorMessage = 'This salon branch is temporarily closed and cannot accept new bookings.';
      notifyListeners();
      return false;
    }

    _selectedBranch = branch;
    _errorMessage = null;
    storageService?.setString(_storageKeyBranchId, branch.id);
    notifyListeners();
    return true;
  }
}
