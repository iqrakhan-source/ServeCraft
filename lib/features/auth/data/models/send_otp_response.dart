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
    final Map<String, dynamic> data = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;

    return SendOtpResponse(
      success: (json['success'] as bool?) ?? (data['success'] as bool?) ?? true,
      message:
          (data['message'] as String?) ??
          (json['message'] as String?) ??
          'Verification code sent successfully',
      expiresInSeconds:
          (data['expiresInSeconds'] as int?) ??
          (data['expiresIn'] as int?) ??
          (json['expiresInSeconds'] as int?) ??
          (json['expiresIn'] as int?) ??
          60,
      resendToken:
          (data['resendToken'] as String?) ?? (json['resendToken'] as String?),
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
