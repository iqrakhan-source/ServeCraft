import '../../domain/repositories/waitlist_repository.dart';
import '../datasources/waitlist_remote_data_source.dart';
import '../models/join_waitlist_response_model.dart';
import '../models/waitlist_entry_model.dart';

class WaitlistRepositoryImpl implements WaitlistRepository {
  final WaitlistRemoteDataSource remoteDataSource;

  WaitlistRepositoryImpl({required this.remoteDataSource});

  @override
  Future<JoinWaitlistResponseModel> joinWaitlist({
    required String branchId,
    required String serviceId,
    String? preferredTime,
    String? notes,
  }) {
    return remoteDataSource.joinWaitlist(
      branchId: branchId,
      serviceId: serviceId,
      preferredTime: preferredTime,
      notes: notes,
    );
  }

  @override
  Future<List<WaitlistEntryModel>> getMyWaitlist() {
    return remoteDataSource.getMyWaitlist();
  }
}
