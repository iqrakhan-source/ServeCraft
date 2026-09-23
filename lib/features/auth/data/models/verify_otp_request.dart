class VerifyOtpRequest {
  final String phone;
  final String otp;

  const VerifyOtpRequest({
    required this.phone,
    required this.otp,
  });

  Map<String, dynamic> toJson() => {
        'phone': phone,
        'otp': otp,
      };
}
