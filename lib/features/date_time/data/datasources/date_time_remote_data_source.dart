import 'package:prop_crm/core/constants/api_constants.dart';
import 'package:prop_crm/core/networking/api_client.dart';
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
    String? branchId,
    String? categoryId,
  });
}

/// Production implementation connecting to REST backend via ApiService
class DateTimeRemoteDataSourceImpl implements DateTimeRemoteDataSource {
  final ApiClient apiService;

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

    try {
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
      if (response.data != null && response.data!.isNotEmpty) {
        return response.data!;
      }
    } catch (_) {
      // Fall through to generate upcoming rolling dates if endpoint is unavailable
    }

    // Default 14 upcoming rolling days for the salon
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return List.generate(14, (i) {
      final d = today.add(Duration(days: i));
      return ServiceDateModel(
        date: d,
        isAvailable: true,
        slots: const [],
      );
    });
  }

  @override
  Future<List<TimeSlotModel>> getTimeSlots({
    required String serviceId,
    required DateTime date,
    String? packageId,
    String? branchId,
    String? categoryId,
  }) async {
    final dateStr =
        "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    // First try GET /api/v1/customer/booking/slots
    try {
      final queryParams = <String, dynamic>{
        'branchId': (branchId != null && branchId.isNotEmpty)
            ? branchId
            : '6ace182c092ec489511e74ce',
        'categoryId': (categoryId != null && categoryId.isNotEmpty)
            ? categoryId
            : '6ace182d092ec489511e74d2',
        'date': dateStr,
      };

      final response = await apiService.get<List<TimeSlotModel>>(
        ApiConstants.bookingSlots,
        queryParameters: queryParams,
        fromJson: (json) {
          final list = json is Map && json['slots'] is List
              ? json['slots'] as List
              : (json is List ? json : []);
          return list
              .map((item) =>
                  TimeSlotModel.fromJson(item as Map<String, dynamic>))
              .toList();
        },
      );
      if (response.data != null && response.data!.isNotEmpty) {
        return response.data!;
      }
    } catch (_) {
      // Fallback
    }

    final queryParams = <String, dynamic>{'date': dateStr};
    if (packageId != null && packageId.isNotEmpty) {
      queryParams['packageId'] = packageId;
    }

    try {
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
    } catch (_) {
      return [];
    }
  }
}

/// TEMPORARY: Isolated mock data source providing realistic dynamic rolling availability
class MockDateTimeRemoteDataSource implements DateTimeRemoteDataSource {
  // Session cache so availability remains stable across date clicks during a session
  final Map<String, List<ServiceDateModel>> _cache = {};

  final List<Map<String, String>> _standardSlotTemplates = const [
    {'id': 'slot_morning_1', 'start': '10:00 AM', 'end': '11:00 AM'},
    {'id': 'slot_morning_2', 'start': '11:00 AM', 'end': '12:00 PM'},
    {'id': 'slot_afternoon_1', 'start': '01:00 PM', 'end': '02:00 PM'},
    {'id': 'slot_afternoon_2', 'start': '02:00 PM', 'end': '03:00 PM'},
    {'id': 'slot_afternoon_3', 'start': '03:00 PM', 'end': '04:00 PM'},
    {'id': 'slot_evening_1', 'start': '05:00 PM', 'end': '06:00 PM'},
    {'id': 'slot_evening_2', 'start': '06:00 PM', 'end': '07:00 PM'},
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
    String? branchId,
    String? categoryId,
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
