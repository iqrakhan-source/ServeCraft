import '../../data/models/service_date_model.dart';
import '../../data/models/time_slot_model.dart';

abstract class DateTimeRepository {
  Future<List<ServiceDateModel>> getAvailableDates({
    required String serviceId,
    String? packageId,
  });

  Future<List<TimeSlotModel>> getTimeSlots({
    required String serviceId,
    required DateTime date,
    String? packageId,
  });
}
