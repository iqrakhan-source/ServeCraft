import '../../domain/repositories/stylist_repository.dart';
import '../datasources/stylist_remote_data_source.dart';
import '../models/stylist_model.dart';

class StylistRepositoryImpl implements StylistRepository {
  final StylistRemoteDataSource remoteDataSource;

  StylistRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<StylistModel>> getStylists({
    required String branchId,
    String? serviceId,
    String? date,
    String? timeSlot,
  }) {
    return remoteDataSource.getStylists(
      branchId: branchId,
      serviceId: serviceId,
      date: date,
      timeSlot: timeSlot,
    );
  }
}
