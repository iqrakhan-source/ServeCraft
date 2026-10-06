import '../../data/models/branch_model.dart';

abstract class BranchRepository {
  Future<List<BranchModel>> getBranches({bool activeOnly = false});
  Future<BranchModel> getBranchById(String id);
}
