
import 'package:flutter/foundation.dart';
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
    debugPrint('========== BRANCH API CALLED ==========');
    debugPrint('Endpoint: ${ApiConstants.branches}');

    final response = await apiService.get<List<BranchModel>>(
      ApiConstants.branches,
      fromJson: (json) {
        debugPrint('========== BRANCH RAW DATA ==========');
        debugPrint('$json');

        final List<dynamic> items;

        if (json is List) {
          items = json;
        } else if (json is Map<String, dynamic>) {
          final branchesData = json['branches'];

          if (branchesData is List) {
            items = branchesData;
          } else {
            throw const FormatException(
              'Branches list not found in API response.',
            );
          }
        } else {
          throw const FormatException(
            'Invalid branches API response format.',
          );
        }

        final parsedBranches = items
            .map(
              (item) => BranchModel.fromJson(
            item as Map<String, dynamic>,
          ),
        )
            .toList();

        debugPrint('========== BRANCH PARSED ==========');
        for (final branch in parsedBranches) {
          debugPrint(
            'Name: ${branch.name} | ID: ${branch.id} | Active: ${branch.isActive}',
          );
        }

        return parsedBranches;
      },
    );

    final branches = response.data ?? <BranchModel>[];

    debugPrint('========== BRANCH FINAL RESULT ==========');
    debugPrint('Total branches: ${branches.length}');

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
