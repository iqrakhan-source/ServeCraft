import '../../domain/repositories/date_time_repository.dart';
import '../datasources/date_time_remote_data_source.dart';
import '../models/service_date_model.dart';
import '../models/time_slot_model.dart';

class DateTimeRepositoryImpl implements DateTimeRepository {
  final DateTimeRemoteDataSource remoteDataSource;

  DateTimeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ServiceDateModel>> getAvailableDates({
    required String serviceId,
    String? packageId,
  }) {
    return remoteDataSource.getAvailableDates(
      serviceId: serviceId,
      packageId: packageId,
    );
  }

  @override
  Future<List<TimeSlotModel>> getTimeSlots({
    required String serviceId,
    required DateTime date,
    String? packageId,
  }) {
    return remoteDataSource.getTimeSlots(
      serviceId: serviceId,
      date: date,
      packageId: packageId,
    );
  }
}
