class CancelBookingResponseModel {
  final bool success;
  final String message;
  final double refundAmount;
  final int pointsRestored;

  const CancelBookingResponseModel({
    required this.success,
    required this.message,
    this.refundAmount = 0.0,
    this.pointsRestored = 0,
  });

  factory CancelBookingResponseModel.fromJson(Map<String, dynamic> json) {
    return CancelBookingResponseModel(
      success: json['success'] == true,
      message:
          json['message']?.toString() ?? 'Appointment cancelled successfully.',
      refundAmount: (json['refundAmount'] as num?)?.toDouble() ?? 0.0,
      pointsRestored: (json['pointsRestored'] as num?)?.toInt() ?? 0,
    );
  }
}
