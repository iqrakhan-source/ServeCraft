import 'package:prop_crm/features/branches/data/models/branch_model.dart';
import 'package:prop_crm/features/branches/data/models/chair_availability_model.dart';

abstract class BranchRepository {
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
