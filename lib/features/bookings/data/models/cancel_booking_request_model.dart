class CancelBookingRequestModel {
  final String bookingId;
  final String reason;
  final String? reasonNote;

  static const List<String> defaultReasons = [
    'Changed my plans',
    'Booked by mistake',
    'Found another service',
    'Schedule no longer works',
    'Service no longer required',
    'Other',
  ];

  const CancelBookingRequestModel({
    required this.bookingId,
    required this.reason,
    this.reasonNote,
  });

  CancelBookingRequestModel copyWith({
    String? bookingId,
    String? reason,
    String? reasonNote,
  }) {
    return CancelBookingRequestModel(
      bookingId: bookingId ?? this.bookingId,
      reason: reason ?? this.reason,
      reasonNote: reasonNote ?? this.reasonNote,
    );
  }

  factory CancelBookingRequestModel.fromJson(Map<String, dynamic> json) {
    return CancelBookingRequestModel(
      bookingId: json['bookingId'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      reasonNote: json['reasonNote'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'reason': reason,
      if (reasonNote != null && reasonNote!.trim().isNotEmpty)
        'reasonNote': reasonNote!.trim(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CancelBookingRequestModel &&
          runtimeType == other.runtimeType &&
          bookingId == other.bookingId &&
          reason == other.reason &&
          reasonNote == other.reasonNote;

  @override
  int get hashCode =>
      bookingId.hashCode ^ reason.hashCode ^ (reasonNote?.hashCode ?? 0);
}
