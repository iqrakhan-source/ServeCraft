class RescheduleBookingResponseModel {
  final bool success;
  final String message;
  final String date;
  final String timeSlot;

  const RescheduleBookingResponseModel({
    required this.success,
    required this.message,
    required this.date,
    required this.timeSlot,
  });

  factory RescheduleBookingResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;

    return RescheduleBookingResponseModel(
      success: json['success'] == true,
      message:
          json['message']?.toString() ?? 'Appointment rescheduled successfully',
      date: data['date']?.toString() ?? '',
      timeSlot: data['timeSlot']?.toString() ?? '',
    );
  }
}
