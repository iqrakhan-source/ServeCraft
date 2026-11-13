import 'package:prop_crm/core/constants/api_constants.dart';
import 'package:prop_crm/core/networking/api_client.dart';
import '../models/branch_model.dart';
import '../models/chair_availability_model.dart';

abstract class BranchRemoteDataSource {
  Future<List<BranchModel>> getBranches({
    double? lat,
    double? lng,
    double? radiusKm,
    String? city,
    String? search,
    bool activeOnly = false,
  });

  Future<BranchModel> getBranchById(String id);

  Future<ChairAvailabilityModel> getChairAvailability({
    required String branchId,
    required String date,
    required String timeSlot,
    int? duration,
  });
}

class BranchRemoteDataSourceImpl implements BranchRemoteDataSource {
  final ApiClient apiService;

  BranchRemoteDataSourceImpl({required this.apiService});

  @override
  Future<List<BranchModel>> getBranches({
    double? lat,
    double? lng,
    double? radiusKm,
    String? city,
    String? search,
    bool activeOnly = false,
  }) async {
    final queryParams = <String, dynamic>{
      'lat': ?lat,
      'lng': ?lng,
      'radiusKm': ?radiusKm,
      if (city != null && city.trim().isNotEmpty) 'city': city.trim(),
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
    };

    final response = await apiService.get<List<BranchModel>>(
      ApiConstants.branches,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
      fromJson: (json) {
        final List<dynamic> items;

        if (json is List) {
          items = json;
        } else if (json is Map<String, dynamic>) {
          final branchesData = json['branches'] ?? json['data'];
          if (branchesData is List) {
            items = branchesData;
          } else {
            return <BranchModel>[];
          }
        } else {
          return <BranchModel>[];
        }

        return items
            .whereType<Map<String, dynamic>>()
            .map((item) => BranchModel.fromJson(item))
            .toList();
      },
    );

    final branches = response.data ?? <BranchModel>[];
    return activeOnly
        ? branches.where((branch) => branch.isActive).toList()
        : branches;
  }

  @override
  Future<BranchModel> getBranchById(String id) async {
    final response = await apiService.get<BranchModel>(
      ApiConstants.branchById(id),
      fromJson: (json) {
        if (json is Map<String, dynamic>) {
          final branchData = json['branch'] ?? json['data'] ?? json;
          if (branchData is Map<String, dynamic>) {
            return BranchModel.fromJson(branchData);
          }
        }
        throw const FormatException('Invalid branch response format');
      },
    );

    if (response.data != null) {
      return response.data!;
    }
    throw NotFoundException(message: 'Branch with id $id not found');
  }

  @override
  Future<ChairAvailabilityModel> getChairAvailability({
    required String branchId,
    required String date,
    required String timeSlot,
    int? duration,
  }) async {
    final queryParams = {
      'date': date,
      'timeSlot': timeSlot,
      if (duration != null && duration > 0) 'duration': duration,
    };

    final response = await apiService.get<ChairAvailabilityModel>(
      ApiConstants.branchChairAvailability(branchId),
      queryParameters: queryParams,
      fromJson: (json) {
        if (json is Map<String, dynamic>) {
          return ChairAvailabilityModel.fromJson(json);
        }
        throw const FormatException('Invalid chair availability format');
      },
    );

    if (response.data != null) {
      return response.data!;
    }
    throw const ServerException(message: 'Failed to fetch chair availability');
  }
}
