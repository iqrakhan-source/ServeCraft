class SendOtpResponse {
  final bool success;
  final String message;
  final int expiresInSeconds;
  final String? resendToken;

  const SendOtpResponse({
    required this.success,
    required this.message,
    this.expiresInSeconds = 60,
    this.resendToken,
  });

  factory SendOtpResponse.fromJson(Map<String, dynamic> json) {
    return SendOtpResponse(
      success: json['success'] as bool? ?? true,
      message: (json['message'] as String?) ?? 'OTP sent successfully',
      expiresInSeconds: json['expiresInSeconds'] as int? ?? 60,
      resendToken: json['resendToken'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'expiresInSeconds': expiresInSeconds,
      'resendToken': resendToken,
    };
  }
}
