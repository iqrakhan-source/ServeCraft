
import 'package:prop_crm/core/constants/api_constants.dart';
import 'package:prop_crm/core/networking/api_client.dart';

import '../models/branch_model.dart';

abstract class BranchRemoteDataSource {
  Future<List<BranchModel>> getBranches({bool activeOnly = false});
  Future<BranchModel> getBranchById(String id);
}

class BranchRemoteDataSourceImpl implements BranchRemoteDataSource {
  final ApiClient apiService;

  BranchRemoteDataSourceImpl({required this.apiService});

  @override
  Future<List<BranchModel>> getBranches({
    bool activeOnly = false,
  }) async {
    final response = await apiService.get<List<BranchModel>>(
      ApiConstants.branches,
      fromJson: (json) {
        final List<dynamic> items = json as List<dynamic>;

        return items
            .map(
              (item) => BranchModel.fromJson(
            item as Map<String, dynamic>,
          ),
        )
            .toList();
      },
    );

    final branches = response.data ?? <BranchModel>[];

    // The current API response does not include isActive.
    // BranchModel defaults it to true.
    return activeOnly
        ? branches.where((branch) => branch.isActive).toList()
        : branches;
  }

  @override
  Future<BranchModel> getBranchById(String id) async {
    final branches = await getBranches();

    return branches.firstWhere(
          (branch) => branch.id == id,
      orElse: () => throw Exception('Branch not found: $id'),
    );
  }
}
