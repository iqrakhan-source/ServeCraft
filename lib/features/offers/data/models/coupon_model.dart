class CouponModel {
  final String code;
  final String title;
  final String description;
  final double? discountPercent;
  final double? flatDiscount;
  final double minBookingAmount;
  final double? maxDiscount;
  final DateTime expiryDate;
  final bool isActive;

  const CouponModel({
    required this.code,
    required this.title,
    required this.description,
    this.discountPercent,
    this.flatDiscount,
    this.minBookingAmount = 0,
    this.maxDiscount,
    required this.expiryDate,
    this.isActive = true,
  });

  /// Calculate discount for given booking total
  double calculateDiscount(double subtotal) {
    if (subtotal < minBookingAmount) return 0.0;
    if (flatDiscount != null) {
      return flatDiscount! > subtotal ? subtotal : flatDiscount!;
    }
    if (discountPercent != null) {
      double discount = subtotal * (discountPercent! / 100.0);
      if (maxDiscount != null && discount > maxDiscount!) {
        discount = maxDiscount!;
      }
      return discount;
    }
    return 0.0;
  }

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      code: json['code'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      discountPercent: (json['discountPercent'] as num?)?.toDouble(),
      flatDiscount: (json['flatDiscount'] as num?)?.toDouble(),
      minBookingAmount: (json['minBookingAmount'] as num?)?.toDouble() ?? 0.0,
      maxDiscount: (json['maxDiscount'] as num?)?.toDouble(),
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'] as String)
          : DateTime.now().add(const Duration(days: 30)),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'title': title,
      'description': description,
      'discountPercent': discountPercent,
      'flatDiscount': flatDiscount,
      'minBookingAmount': minBookingAmount,
      'maxDiscount': maxDiscount,
      'expiryDate': expiryDate.toIso8601String(),
      'isActive': isActive,
    };
  }
}
