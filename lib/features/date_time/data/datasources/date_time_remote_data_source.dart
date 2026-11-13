
import 'package:flutter/foundation.dart';
import 'package:prop_crm/core/constants/api_constants.dart';
import 'package:prop_crm/core/networking/api_client.dart';

import '../models/service_date_model.dart';
import '../models/time_slot_model.dart';

abstract class DateTimeRemoteDataSource {
  Future<List<ServiceDateModel>> getAvailableDates({
    required String serviceId,
    required String branchId,
    String? packageId,
  });

  Future<List<TimeSlotModel>> getTimeSlots({
    required String serviceId,
    required DateTime date,
    required String branchId,
    String? packageId,
    String? categoryId,
    int? duration,
    String? stylistId,
  });
}

// Production implementation connecting to the REST backend.
class DateTimeRemoteDataSourceImpl implements DateTimeRemoteDataSource {
  final ApiClient apiService;

  DateTimeRemoteDataSourceImpl({required this.apiService});

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  @override
  Future<List<ServiceDateModel>> getAvailableDates({
    required String serviceId,
    required String branchId,
    String? packageId,
  }) async {
    if (branchId.trim().isEmpty) {
      throw ArgumentError('branchId is required to fetch available dates.');
    }

    debugPrint('========== AVAILABLE DATES API ==========');
    debugPrint('SERVICE ID: $serviceId');
    debugPrint('BRANCH ID: $branchId');
    debugPrint('PACKAGE ID: $packageId');

    // Generate the next 14 calendar dates.
    // Actual availability is determined by the backend.
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final dates = List.generate(
      14,
          (index) => today.add(Duration(days: index)),
    );

    // Fetch real availability for every date.
    // If a request fails, let the error reach the provider.
    // Never mark an unverified date as available.
    final results = await Future.wait(
      dates.map((date) async {
        final slots = await getTimeSlots(
          serviceId: serviceId,
          date: date,
          branchId: branchId,
          packageId: packageId,
        );

        return ServiceDateModel(
          date: date,
          isAvailable: slots.any((slot) => slot.isAvailable),
          unavailableReason:
          slots.any((slot) => slot.isAvailable)
              ? null
              : 'No available slots',
          slots: slots,
        );
      }),
    );

    debugPrint('AVAILABLE DATES RETURNED: ${results.length}');
    debugPrint(
      'DATES WITH AVAILABILITY: '
          '${results.where((date) => date.isAvailable).length}',
    );

    return results;
  }

  @override
  Future<List<TimeSlotModel>> getTimeSlots({
    required String serviceId,
    required DateTime date,
    required String branchId,
    String? packageId,
    String? categoryId,
    int? duration,
    String? stylistId,
  }) async {
    if (branchId.trim().isEmpty) {
      throw ArgumentError(
        'branchId is required to fetch available time slots.',
      );
    }

    final dateStr = _formatDate(date);

    debugPrint('========== SLOT API DEBUG ==========');
    debugPrint('SLOT API METHOD CALLED');
    debugPrint('SERVICE ID: $serviceId');
    debugPrint('BRANCH ID: $branchId');
    debugPrint('PACKAGE ID: $packageId');
    debugPrint('CATEGORY ID: $categoryId');
    debugPrint('SELECTED DATE: $dateStr');

    final queryParams = <String, dynamic>{
      'date': dateStr,
      if (duration != null) 'duration': duration,
      if (stylistId != null && stylistId.isNotEmpty && stylistId != 'any')
        'stylistId': stylistId,
    };

    final response = await apiService.get<List<TimeSlotModel>>(
      ApiConstants.availableSlots(branchId),
      queryParameters: queryParams,
      fromJson: (json) {
        final slotsJson = json is Map
            ? (json['availableSlots'] ??
                json['slots'] ??
                json['data']?['availableSlots'] ??
                json['data']?['slots'] ??
                json['data'])
            : json;

        if (slotsJson is! List) {
          throw const FormatException(
            'Invalid available-slots response: '
                'availableSlots list not found.',
          );
        }

        return slotsJson
            .whereType<Map>()
            .map(
              (item) => TimeSlotModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
            .toList();
      },
    );

    final slots = response.data ?? [];

    debugPrint('SLOTS RETURNED: ${slots.length}');
    debugPrint(
      'OPEN SLOTS: ${slots.where((slot) => slot.isAvailable).length}',
    );

    return slots;
  }
}

// TEMPORARY: Mock data source for UI testing only.
class MockDateTimeRemoteDataSource implements DateTimeRemoteDataSource {
  final Map<String, List<ServiceDateModel>> _cache = {};

  final List<Map<String, String>> _standardSlotTemplates = const [
    {'id': '10:00', 'start': '10:00', 'end': '11:00'},
    {'id': '11:00', 'start': '11:00', 'end': '12:00'},
    {'id': '13:00', 'start': '13:00', 'end': '14:00'},
    {'id': '14:00', 'start': '14:00', 'end': '15:00'},
    {'id': '15:00', 'start': '15:00', 'end': '16:00'},
    {'id': '17:00', 'start': '17:00', 'end': '18:00'},
    {'id': '18:00', 'start': '18:00', 'end': '19:00'},
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

      if (isDay4) {
        dates.add(
          ServiceDateModel(
            date: date,
            isAvailable: false,
            unavailableReason: 'Fully Booked',
            slots: _standardSlotTemplates.map((template) {
              return TimeSlotModel(
                id: template['id']!,
                startTime: template['start']!,
                endTime: template['end']!,
                isAvailable: false,
              );
            }).toList(),
          ),
        );
        continue;
      }

      final slots = <TimeSlotModel>[];

      for (int i = 0; i < _standardSlotTemplates.length; i++) {
        final template = _standardSlotTemplates[i];
        bool isSlotAvailable = true;

        if (dayOffset == 0) {
          if (i < 3) isSlotAvailable = false;
        } else if (isDay3) {
          isSlotAvailable = i == 2 || i == 5;
        } else if (isSunday) {
          if (i >= 5) isSlotAvailable = false;
        } else {
          if (i == 3) isSlotAvailable = false;
        }

        slots.add(
          TimeSlotModel(
            id: template['id']!,
            startTime: template['start']!,
            endTime: template['end']!,
            isAvailable: isSlotAvailable,
          ),
        );
      }

      dates.add(
        ServiceDateModel(
          date: date,
          isAvailable: slots.any((slot) => slot.isAvailable),
          slots: slots,
        ),
      );
    }

    return dates;
  }

  @override
  Future<List<ServiceDateModel>> getAvailableDates({
    required String serviceId,
    required String branchId,
    String? packageId,
  }) async {

    await Future.delayed(const Duration(milliseconds: 250));

    final cacheKey = '${branchId}_${serviceId}_${packageId ?? ''}';

    return _cache.putIfAbsent(
      cacheKey,
          () => _generateMockDates(),
    );
  }

  @override
  Future<List<TimeSlotModel>> getTimeSlots({
    required String serviceId,
    required DateTime date,
    required String branchId,
    String? packageId,
    String? categoryId,
    int? duration,
    String? stylistId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final dates = await getAvailableDates(
      serviceId: serviceId,
      branchId: branchId,
      packageId: packageId,
    );

    try {
      final matchingDate = dates.firstWhere(
            (item) =>
        item.date.year == date.year &&
            item.date.month == date.month &&
            item.date.day == date.day,
      );

      return matchingDate.slots;
    } catch (_) {
      return [];
    }
  }
}
