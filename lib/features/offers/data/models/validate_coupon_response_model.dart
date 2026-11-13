class ValidateCouponResponseModel {
  final bool success;
  final double discountAmount;
  final double finalSubtotal;
  final String? message;

  const ValidateCouponResponseModel({
    required this.success,
    required this.discountAmount,
    required this.finalSubtotal,
    this.message,
  });

  factory ValidateCouponResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;
    return ValidateCouponResponseModel(
      success: json['success'] == true,
      discountAmount: (data['discountAmount'] as num?)?.toDouble() ?? 0.0,
      finalSubtotal: (data['finalSubtotal'] as num?)?.toDouble() ?? 0.0,
      message: json['message']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'discountAmount': discountAmount,
      'finalSubtotal': finalSubtotal,
      if (message != null) 'message': message,
    };
  }
}

