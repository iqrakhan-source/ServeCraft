import '../../domain/repositories/branch_repository.dart';
import '../datasources/branch_remote_data_source.dart';
import '../models/branch_model.dart';
import '../models/chair_availability_model.dart';

class BranchRepositoryImpl implements BranchRepository {
  final BranchRemoteDataSource remoteDataSource;

  BranchRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<BranchModel>> getBranches({
    double? lat,
    double? lng,
    double? radiusKm,
    String? city,
    String? search,
    bool activeOnly = false,
  }) {
    return remoteDataSource.getBranches(
      lat: lat,
      lng: lng,
      radiusKm: radiusKm,
      city: city,
      search: search,
      activeOnly: activeOnly,
    );
  }

  @override
  Future<BranchModel> getBranchById(String id) {
    return remoteDataSource.getBranchById(id);
  }

  @override
  Future<ChairAvailabilityModel> getChairAvailability({
    required String branchId,
    required String date,
    required String timeSlot,
    int? duration,
  }) {
    return remoteDataSource.getChairAvailability(
      branchId: branchId,
      date: date,
      timeSlot: timeSlot,
      duration: duration,
    );
  }
}
