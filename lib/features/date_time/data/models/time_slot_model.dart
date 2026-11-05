
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

  // Exact timeSlot value expected by the booking API.
  String get bookingTimeSlot => id;

  String get formattedLabel => displayLabel ?? startTime;

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
    (json['timeSlot'] ?? json['slot24'] ?? '').toString();

    final capacity =
    (json['availableCapacity'] as num?)?.toInt();

    return TimeSlotModel(
      id: timeSlot,
      startTime: (json['startTime'] ?? timeSlot).toString(),
      endTime: (json['endTime'] ?? '').toString(),
      displayLabel: json['display']?.toString(),
      isAvailable: capacity == null || capacity > 0,
      availableCapacity: capacity,
    );
  }
}
