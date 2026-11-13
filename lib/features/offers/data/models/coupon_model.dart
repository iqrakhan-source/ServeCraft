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

    final rawPercentage =
        (json['discountPercentage'] ?? json['discountPercent']) as num?;
    final discountPercent = discountType == 'percentage'
        ? discountValue
        : rawPercentage?.toDouble();

    final flatDiscount = discountType == 'fixed'
        ? discountValue
        : (json['flatDiscount'] as num?)?.toDouble();

    final expiryValue = json['expiryDate'] ?? json['validUntil'];
    final expiryDate = expiryValue != null
        ? DateTime.tryParse(expiryValue.toString()) ?? DateTime.now()
        : DateTime.now();

    final code = json['code']?.toString() ?? '';
    var title = json['title']?.toString() ?? '';
    if (title.isEmpty) {
      if (discountPercent != null && discountPercent > 0) {
        title = '${discountPercent.toInt()}% OFF';
      } else if (flatDiscount != null && flatDiscount > 0) {
        title = '₹${flatDiscount.toInt()} OFF';
      } else {
        title = code;
      }
    }

    var description = json['description']?.toString() ?? '';
    final maxDisc = (json['maxDiscount'] as num?)?.toDouble();
    final minOrder =
        ((json['minOrderAmount'] ?? json['minBookingAmount']) as num?)
            ?.toDouble() ??
        0.0;

    if (description.isEmpty) {
      if (maxDisc != null && maxDisc > 0) {
        description =
            'Save up to ₹${maxDisc.toInt()} on orders above ₹${minOrder.toInt()}';
      } else if (minOrder > 0) {
        description = 'Applicable on orders above ₹${minOrder.toInt()}';
      } else {
        description = 'Special salon discount on your booking';
      }
    }

    return CouponModel(
      code: code,
      title: title,
      description: description,
      discountPercent: discountPercent,
      flatDiscount: flatDiscount,
      minBookingAmount: minOrder,
      maxDiscount: maxDisc,
      expiryDate: expiryDate,
      isActive: json['isActive'] as bool? ?? expiryDate.isAfter(DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'title': title,
      'description': description,
      'discountPercentage': discountPercent,
      'discountPercent': discountPercent,
      'flatDiscount': flatDiscount,
      'minBookingAmount': minBookingAmount,
      'minOrderAmount': minBookingAmount,
      'maxDiscount': maxDiscount,
      'expiryDate': expiryDate.toIso8601String(),
      'isActive': isActive,
    };
  }
}
