import 'package:prop_crm/core/constants/api_constants.dart';
import 'package:prop_crm/core/networking/api_service.dart';
import '../models/service_date_model.dart';
import '../models/time_slot_model.dart';

abstract class DateTimeRemoteDataSource {
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

/// Production implementation connecting to REST backend via ApiService
class DateTimeRemoteDataSourceImpl implements DateTimeRemoteDataSource {
  final ApiService apiService;

  DateTimeRemoteDataSourceImpl({required this.apiService});

  @override
  Future<List<ServiceDateModel>> getAvailableDates({
    required String serviceId,
    String? packageId,
  }) async {
    final queryParams = <String, dynamic>{};
    if (packageId != null && packageId.isNotEmpty) {
      queryParams['packageId'] = packageId;
    }

    final response = await apiService.get<List<ServiceDateModel>>(
      ApiConstants.serviceAvailability(serviceId),
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
      fromJson: (json) {
        if (json is List) {
          return json
              .map((item) =>
                  ServiceDateModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
    );
    return response.data ?? [];
  }

  @override
  Future<List<TimeSlotModel>> getTimeSlots({
    required String serviceId,
    required DateTime date,
    String? packageId,
  }) async {
    final dateStr =
        "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    final queryParams = <String, dynamic>{'date': dateStr};
    if (packageId != null && packageId.isNotEmpty) {
      queryParams['packageId'] = packageId;
    }

    final response = await apiService.get<List<TimeSlotModel>>(
      ApiConstants.serviceSlotsByDate(serviceId, dateStr),
      queryParameters: queryParams,
      fromJson: (json) {
        if (json is List) {
          return json
              .map((item) =>
                  TimeSlotModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
    );
    return response.data ?? [];
  }
}

/// TEMPORARY: Isolated mock data source providing realistic dynamic rolling availability
class MockDateTimeRemoteDataSource implements DateTimeRemoteDataSource {
  // Session cache so availability remains stable across date clicks during a session
  final Map<String, List<ServiceDateModel>> _cache = {};

  final List<Map<String, String>> _standardSlotTemplates = const [
    {'id': 'slot_1', 'start': '09:00 AM', 'end': '10:00 AM'},
    {'id': 'slot_2', 'start': '10:00 AM', 'end': '11:00 AM'},
    {'id': 'slot_3', 'start': '11:00 AM', 'end': '12:00 PM'},
    {'id': 'slot_4', 'start': '12:00 PM', 'end': '01:00 PM'},
    {'id': 'slot_5', 'start': '02:00 PM', 'end': '03:00 PM'},
    {'id': 'slot_6', 'start': '03:00 PM', 'end': '04:00 PM'},
    {'id': 'slot_7', 'start': '04:00 PM', 'end': '05:00 PM'},
    {'id': 'slot_8', 'start': '05:00 PM', 'end': '06:00 PM'},
  ];

  List<ServiceDateModel> _generateMockDates() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dates = <ServiceDateModel>[];

    for (int dayOffset = 0; dayOffset < 14; dayOffset++) {
      final date = today.add(Duration(days: dayOffset));
      final isSunday = date.weekday == DateTime.sunday;
      final isDay4 = dayOffset == 4;
      final isDay3 = dayOffset == 3;

      // Business Rule: Day 4 is fully booked to test disabled date UI
      if (isDay4) {
        dates.add(
          ServiceDateModel(
            date: date,
            isAvailable: false,
            unavailableReason: 'Fully Booked',
            slots: _standardSlotTemplates.map((t) {
              return TimeSlotModel(
                id: '${date.millisecondsSinceEpoch}_${t['id']}',
                startTime: t['start']!,
                endTime: t['end']!,
                isAvailable: false,
              );
            }).toList(),
          ),
        );
        continue;
      }

      // Generate slots for this day
      final slots = <TimeSlotModel>[];
      for (int i = 0; i < _standardSlotTemplates.length; i++) {
        final t = _standardSlotTemplates[i];
        bool isSlotAvailable = true;

        if (dayOffset == 0) {
          // Today: earlier slots might be unavailable
          if (i < 3) isSlotAvailable = false;
        } else if (isDay3) {
          // Limited availability day: only slots 2 and 5 available
          isSlotAvailable = (i == 2 || i == 5);
        } else if (isSunday) {
          // Sunday: afternoon half off
          if (i >= 5) isSlotAvailable = false;
        } else {
          // Normal weekday: slot 3 (lunch hour) occasionally booked
          if (i == 3) isSlotAvailable = false;
        }

        slots.add(
          TimeSlotModel(
            id: '${date.millisecondsSinceEpoch}_${t['id']}',
            startTime: t['start']!,
            endTime: t['end']!,
            isAvailable: isSlotAvailable,
          ),
        );
      }

      dates.add(
        ServiceDateModel(
          date: date,
          isAvailable: slots.any((s) => s.isAvailable),
          slots: slots,
        ),
      );
    }

    return dates;
  }

  @override
  Future<List<ServiceDateModel>> getAvailableDates({
    required String serviceId,
    String? packageId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final cacheKey = '${serviceId}_${packageId ?? ''}';
    return _cache.putIfAbsent(cacheKey, () => _generateMockDates());
  }

  @override
  Future<List<TimeSlotModel>> getTimeSlots({
    required String serviceId,
    required DateTime date,
    String? packageId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final dates = await getAvailableDates(
      serviceId: serviceId,
      packageId: packageId,
    );

    try {
      final matchingDate = dates.firstWhere(
        (d) =>
            d.date.year == date.year &&
            d.date.month == date.month &&
            d.date.day == date.day,
      );
      return matchingDate.slots;
    } catch (_) {
      return [];
    }
  }
}
