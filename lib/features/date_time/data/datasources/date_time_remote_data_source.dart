import 'package:flutter/foundation.dart';
import 'package:prop_crm/core/constants/api_constants.dart';
import 'package:prop_crm/core/networking/api_client.dart';
import 'package:prop_crm/core/utilities/formatters.dart';

import '../models/service_date_model.dart';
import '../models/time_slot_model.dart';

abstract class DateTimeRemoteDataSource {
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

  String _formatDate(DateTime date) => AppFormatters.formatBackendDate(date);

  List<TimeSlotModel> _parseSlots(dynamic json) {
    if (json == null) return [];

    final root = json is Map && json.containsKey('data') && json['data'] != null
        ? json['data']
        : json;

    dynamic slotsRaw;
    if (root is Map) {
      slotsRaw =
          root['availableSlots'] ??
          root['slots'] ??
          root['timeSlots'] ??
          root['data'];
    } else if (root is List) {
      slotsRaw = root;
    }

    if (slotsRaw is List) {
      return slotsRaw
          .whereType<Map>()
          .map(
            (item) => TimeSlotModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    }

    return [];
  }

  List<TimeSlotModel> _generateDefaultSlots(
    DateTime date, {
    int? duration,
    bool isBranchFull = false,
  }) {
    final now = DateTime.now();
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;

    final stepMinutes = duration != null && duration >= 15 ? duration : 30;
    final List<TimeSlotModel> defaultSlots = [];

    // Operating hours 09:00 to 20:00 (8:00 PM)
    int currentMinutes = 9 * 60; // 09:00
    const endMinutes = 20 * 60; // 20:00

    while (currentMinutes + stepMinutes <= endMinutes) {
      final startH = currentMinutes ~/ 60;
      final startM = currentMinutes % 60;
      final endH = (currentMinutes + stepMinutes) ~/ 60;
      final endM = (currentMinutes + stepMinutes) % 60;

      final startStr =
          '${startH.toString().padLeft(2, '0')}:${startM.toString().padLeft(2, '0')}';
      final endStr =
          '${endH.toString().padLeft(2, '0')}:${endM.toString().padLeft(2, '0')}';

      bool isAvailable = !isBranchFull;
      if (isToday) {
        final slotTime = DateTime(
          date.year,
          date.month,
          date.day,
          startH,
          startM,
        );
        if (slotTime.isBefore(now.add(const Duration(minutes: 10)))) {
          isAvailable = false;
        }
      }

      defaultSlots.add(
        TimeSlotModel(
          id: startStr,
          startTime: startStr,
          endTime: endStr,
          displayLabel: TimeSlotModel.formatTime12Hour(startStr),
          isAvailable: isAvailable,
        ),
      );

      currentMinutes += stepMinutes;
    }

    return defaultSlots;
  }

  List<TimeSlotModel> _filterPastSlots(
    List<TimeSlotModel> slots,
    DateTime date,
  ) {
    final now = DateTime.now();
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;

    if (!isToday) return slots;

    final cutoff = now.add(const Duration(minutes: 10));

    return slots.map((slot) {
      final parts = slot.startTime.split(':');
      if (parts.length >= 2) {
        final h = int.tryParse(parts[0]) ?? 0;
        final m = int.tryParse(parts[1]) ?? 0;
        final slotTime = DateTime(date.year, date.month, date.day, h, m);
        if (slotTime.isBefore(cutoff)) {
          return TimeSlotModel(
            id: slot.id,
            startTime: slot.startTime,
            endTime: slot.endTime,
            displayLabel: slot.displayLabel,
            isAvailable: false,
            availableCapacity: 0,
          );
        }
      }
      return slot;
    }).toList();
  }

  @override
  Future<List<ServiceDateModel>> getAvailableDates({
    required String serviceId,
    required String branchId,
    String? packageId,
    String? categoryId,
    int? duration,
    String? stylistId,
  }) async {
    if (branchId.trim().isEmpty) {
      throw ArgumentError('branchId is required to fetch available dates.');
    }

    debugPrint('========== AVAILABLE DATES API ==========');
    debugPrint('SERVICE ID: $serviceId');
    debugPrint('BRANCH ID: $branchId');
    debugPrint('PACKAGE ID: $packageId');

    // Generate the next 14 calendar dates.
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final dates = List.generate(
      14,
      (index) => today.add(Duration(days: index)),
    );

    // Fetch real availability for each date in parallel.
    final results = await Future.wait(
      dates.map((date) async {
        try {
          final slots = await getTimeSlots(
            serviceId: serviceId,
            date: date,
            branchId: branchId,
            packageId: packageId,
            categoryId: categoryId,
            duration: duration,
            stylistId: stylistId,
          );

          final hasAvailableSlots = slots.any((slot) => slot.isAvailable);

          return ServiceDateModel(
            date: date,
            isAvailable: hasAvailableSlots,
            unavailableReason: hasAvailableSlots ? null : 'No available slots',
            slots: slots,
          );
        } catch (e) {
          debugPrint('Error fetching slots for date $date: $e');
          final fallbackSlots = _generateDefaultSlots(date, duration: duration);
          final hasAvailable = fallbackSlots.any((s) => s.isAvailable);
          return ServiceDateModel(
            date: date,
            isAvailable: hasAvailable,
            unavailableReason: hasAvailable ? null : 'No available slots',
            slots: fallbackSlots,
          );
        }
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
    debugPrint('SLOT API METHOD CALLED: GET');
    debugPrint('ENDPOINT: ${ApiConstants.availableSlots(branchId)}');
    debugPrint('SERVICE ID: $serviceId');
    debugPrint('BRANCH ID: $branchId');
    debugPrint('PACKAGE ID: $packageId');
    debugPrint('CATEGORY ID: $categoryId');
    debugPrint('SELECTED DATE: $dateStr');
    debugPrint('DURATION: $duration');
    debugPrint('====================================');

    List<TimeSlotModel> slots = [];
    bool isOffDay = false;

    // 1. Primary Documented Endpoint: GET /api/customer/branches/:branchId/available-slots?date=YYYY-MM-DD
    if (branchId.trim().isNotEmpty) {
      try {
        final queryParams = <String, dynamic>{
          'date': dateStr,
          if (serviceId.trim().isNotEmpty) 'serviceId': serviceId.trim(),
          'duration': ?duration,
          if (stylistId != null && stylistId.isNotEmpty && stylistId != 'any')
            'stylistId': stylistId,
        };

        final response = await apiService.get<dynamic>(
          ApiConstants.availableSlots(branchId.trim()),
          queryParameters: queryParams,
        );

        if (response.success && response.data != null) {
          final data = response.data;
          if (data is Map && data['isOffDay'] == true) {
            isOffDay = true;
            debugPrint('[SLOT API] Branch is closed on $dateStr (off-day).');
          } else {
            final parsed = _parseSlots(data);
            if (parsed.isNotEmpty) {
              slots = parsed;
              debugPrint(
                '[SLOT API] Retrieved ${slots.length} slots from branch available-slots API.',
              );
            }
          }
        }
      } catch (e) {
        debugPrint('[SLOT API] available-slots API call error: $e');
      }
    }

    // 2. Secondary Fallback: GET /api/customer/services/:serviceId/availability?date=...
    if (slots.isEmpty && !isOffDay && serviceId.trim().isNotEmpty) {
      try {
        final queryParams = <String, dynamic>{
          'date': dateStr,
          if (branchId.isNotEmpty) 'branch': branchId,
          if (branchId.isNotEmpty) 'branchId': branchId,
          'duration': ?duration,
          if (stylistId != null && stylistId.isNotEmpty && stylistId != 'any')
            'stylistId': stylistId,
        };

        final response = await apiService.get<List<TimeSlotModel>>(
          ApiConstants.serviceAvailability(serviceId.trim()),
          queryParameters: queryParams,
          fromJson: (json) => _parseSlots(json),
        );

        if (response.data != null && response.data!.isNotEmpty) {
          slots = response.data!;
          debugPrint(
            '[SLOT API] Retrieved ${slots.length} slots from service availability API.',
          );
        }
      } catch (e) {
        debugPrint('[SLOT API] serviceAvailability fallback error: $e');
      }
    }

    // 3. Tertiary Fallback: Query branch chair availability
    if (slots.isEmpty && !isOffDay) {
      try {
        final chairResponse = await apiService.get<Map<String, dynamic>>(
          ApiConstants.branchChairAvailability(branchId),
          queryParameters: {'date': dateStr},
          fromJson: (json) {
            if (json is Map) return Map<String, dynamic>.from(json);
            return <String, dynamic>{};
          },
        );

        final chairData = chairResponse.data;
        if (chairData != null && chairData.isNotEmpty) {
          final parsed = _parseSlots(chairData);
          if (parsed.isNotEmpty) {
            slots = parsed;
          } else {
            final isFull = chairData['isFull'] as bool? ?? false;
            final availCount =
                (chairData['availableCount'] as num?)?.toInt() ??
                (chairData['availableChairs'] is List
                    ? (chairData['availableChairs'] as List).length
                    : 1);

            slots = _generateDefaultSlots(
              date,
              duration: duration,
              isBranchFull: isFull || availCount <= 0,
            );
          }
        }
      } catch (e) {
        debugPrint('branchChairAvailability API fallback error: $e');
      }
    }

    // 4. Default Fallback only if not explicitly an off-day
    if (slots.isEmpty && !isOffDay) {
      slots = _generateDefaultSlots(date, duration: duration);
    }

    // Filter past slots for today
    slots = _filterPastSlots(slots, date);

    debugPrint('SLOTS RETURNED: ${slots.length}');
    debugPrint('OPEN SLOTS: ${slots.where((slot) => slot.isAvailable).length}');

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
    String? categoryId,
    int? duration,
    String? stylistId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));

    final cacheKey = '${branchId}_${serviceId}_${packageId ?? ''}';

    return _cache.putIfAbsent(cacheKey, () => _generateMockDates());
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
