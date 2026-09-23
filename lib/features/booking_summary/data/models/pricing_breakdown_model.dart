class PricingBreakdown {
  final double packagePrice;
  final double discount;
  final double taxRate;
  final double taxAmount;
  final double totalAmount;

  const PricingBreakdown({
    required this.packagePrice,
    required this.discount,
    required this.taxRate,
    required this.taxAmount,
    required this.totalAmount,
  });

  /// Check if a discount is applied
  bool get hasDiscount => discount > 0.0;

  /// Default mock tax rate (18% GST)
  static const double defaultTaxRate = 0.18;

  /// Calculates pricing with exact integer rupee precision to eliminate floating-point inaccuracies
  factory PricingBreakdown.calculate({
    required double packagePrice,
    double discount = 0.0,
    double taxRate = defaultTaxRate,
  }) {
    // 1. Sanitize inputs to 2 decimal places to avoid IEEE 754 precision issues
    final cleanPackagePrice = (packagePrice * 100).round() / 100.0;
    final cleanDiscount = (discount * 100).round() / 100.0;

    // 2. Compute taxable amount
    final taxableAmount = (cleanPackagePrice - cleanDiscount > 0)
        ? (cleanPackagePrice - cleanDiscount)
        : 0.0;

    // 3. Compute tax amount and round to the nearest whole rupee for consumer-facing INR
    final calculatedTax = taxableAmount * taxRate;
    final roundedTax = calculatedTax.roundToDouble();

    // 4. Compute final total: package price - discount + tax
    final calculatedTotal = cleanPackagePrice - cleanDiscount + roundedTax;
    final cleanTotal = calculatedTotal > 0 ? calculatedTotal.roundToDouble() : 0.0;

    return PricingBreakdown(
      packagePrice: cleanPackagePrice.roundToDouble(),
      discount: cleanDiscount.roundToDouble(),
      taxRate: taxRate,
      taxAmount: roundedTax,
      totalAmount: cleanTotal,
    );
  }

  PricingBreakdown copyWith({
    double? packagePrice,
    double? discount,
    double? taxRate,
    double? taxAmount,
    double? totalAmount,
  }) {
    return PricingBreakdown(
      packagePrice: packagePrice ?? this.packagePrice,
      discount: discount ?? this.discount,
      taxRate: taxRate ?? this.taxRate,
      taxAmount: taxAmount ?? this.taxAmount,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }

  factory PricingBreakdown.fromJson(Map<String, dynamic> json) {
    return PricingBreakdown(
      packagePrice: (json['packagePrice'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      taxRate: (json['taxRate'] as num?)?.toDouble() ?? defaultTaxRate,
      taxAmount: (json['taxAmount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'packagePrice': packagePrice,
      'discount': discount,
      'taxRate': taxRate,
      'taxAmount': taxAmount,
      'totalAmount': totalAmount,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PricingBreakdown &&
          runtimeType == other.runtimeType &&
          packagePrice == other.packagePrice &&
          discount == other.discount &&
          taxRate == other.taxRate &&
          taxAmount == other.taxAmount &&
          totalAmount == other.totalAmount;

  @override
  int get hashCode =>
      packagePrice.hashCode ^
      discount.hashCode ^
      taxRate.hashCode ^
      taxAmount.hashCode ^
      totalAmount.hashCode;
}
