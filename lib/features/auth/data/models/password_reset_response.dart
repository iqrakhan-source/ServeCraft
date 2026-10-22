class PasswordResetResponse {
  final bool success;
  final String message;
  final String? resetToken;

  const PasswordResetResponse({
    required this.success,
    required this.message,
    this.resetToken,
  });

  factory PasswordResetResponse.fromJson(
      Map<String, dynamic> json,
      ) {
    return PasswordResetResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      resetToken: json['resetToken']?.toString(),
    );
  }
}