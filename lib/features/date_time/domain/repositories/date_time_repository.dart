import '../../data/models/service_date_model.dart';
import '../../data/models/time_slot_model.dart';

abstract class DateTimeRepository {
  Future<List<ServiceDateModel>> getAvailableDates({
    required String serviceId,
    required String branchId,
    String? packageId,
    String? categoryId,
    int? duration,
    String? stylistId,
  });

  Future<List<TimeSlotModel>> getTimeSlots({
    required String serviceId,
    required DateTime date,
    String? packageId,
    required String branchId,
    String? categoryId,
    int? duration,
    String? stylistId,
  });
}
