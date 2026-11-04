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
    final discountType = json['discountType']?.toString().toLowerCase();
    final discountValue = (json['discountValue'] as num?)?.toDouble();

    final expiryValue = json['validUntil'] ?? json['expiryDate'];

    final expiryDate = expiryValue != null
        ? DateTime.tryParse(expiryValue.toString()) ?? DateTime.now()
        : DateTime.now();

    return CouponModel(
      code: json['code']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',

      discountPercent: discountType == 'percentage'
          ? discountValue
          : (json['discountPercent'] as num?)?.toDouble(),

      flatDiscount: discountType == 'fixed'
          ? discountValue
          : (json['flatDiscount'] as num?)?.toDouble(),

      minBookingAmount:
      ((json['minOrderAmount'] ?? json['minBookingAmount']) as num?)
          ?.toDouble() ??
          0.0,

      maxDiscount: (json['maxDiscount'] as num?)?.toDouble(),

      expiryDate: expiryDate,

      isActive: json['isActive'] as bool? ?? expiryDate.isAfter(DateTime.now()),
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
