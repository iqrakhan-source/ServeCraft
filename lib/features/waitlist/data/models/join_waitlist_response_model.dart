class JoinWaitlistResponseModel {
  final bool success;
  final String message;
  final int queuePosition;

  const JoinWaitlistResponseModel({
    required this.success,
    required this.message,
    required this.queuePosition,
  });

  factory JoinWaitlistResponseModel.fromJson(Map<String, dynamic> json) {
    return JoinWaitlistResponseModel(
      success: json['success'] == true,
      message:
          json['message']?.toString() ?? 'Successfully joined the waitlist',
      queuePosition: (json['queuePosition'] as num?)?.toInt() ?? 1,
    );
  }
}
