import 'package:prop_crm/core/utilities/formatters.dart';

class TimeSlotModel {
  final String id;
  final String startTime;
  final String endTime;
  final bool isAvailable;
  final String? displayLabel;
  final int? availableCapacity;

  const TimeSlotModel({
    required this.id,
    required this.startTime,
    required this.endTime,
    this.isAvailable = true,
    this.displayLabel,
    this.availableCapacity,
  });

  // Exact timeSlot value expected by the booking API (e.g. "09:00", "11:00").
  String get bookingTimeSlot => id;

  String get formattedLabel =>
      displayLabel ??
      (startTime.isNotEmpty ? formatTime12Hour(startTime) : startTime);

  Map<String, dynamic> toJson() {
    return {
      'timeSlot': bookingTimeSlot,
      'startTime': startTime,
      'endTime': endTime,
      'display': displayLabel,
      'availableCapacity': availableCapacity,
    };
  }

  factory TimeSlotModel.fromJson(Map<String, dynamic> json) {
    final timeSlot =
        (json['timeSlot'] ??
                json['slot24'] ??
                json['slot'] ??
                json['startTime'] ??
                json['time'] ??
                '')
            .toString();

    final capacity =
        (json['availableCapacity'] as num?)?.toInt() ??
        (json['availableCount'] as num?)?.toInt();

    final bool? isAvailBool = json['available'] is bool
        ? json['available'] as bool
        : (json['isAvailable'] is bool
              ? json['isAvailable'] as bool
              : (json['status'] != null
                    ? json['status'].toString().toLowerCase() == 'available'
                    : null));

    final bool isAvailable = isAvailBool ?? (capacity == null || capacity > 0);

    final display =
        json['display']?.toString() ??
        json['displayLabel']?.toString() ??
        json['label']?.toString() ??
        (timeSlot.isNotEmpty ? formatTime12Hour(timeSlot) : null);

    final start = (json['startTime'] ?? timeSlot).toString();
    final end = (json['endTime'] ?? '').toString();

    return TimeSlotModel(
      id: timeSlot,
      startTime: start,
      endTime: end,
      displayLabel: display,
      isAvailable: isAvailable,
      availableCapacity: capacity,
    );
  }

  static String formatTime12Hour(String time24) =>
      AppFormatters.formatTime12Hour(time24);
}
