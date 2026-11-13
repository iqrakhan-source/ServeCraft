class BookingPricingResponseModel {
  final List<BookingPricingItemModel> items;
  final double subtotal;
  final double couponDiscount;
  final double subscriptionDiscount;
  final double loyaltyPointsDiscount;
  final double discount;
  final double tax;
  final double total;
  final int totalDurationMinutes;
  final int potentialCashbackPoints;

  const BookingPricingResponseModel({
    required this.items,
    required this.subtotal,
    this.couponDiscount = 0.0,
    this.subscriptionDiscount = 0.0,
    this.loyaltyPointsDiscount = 0.0,
    required this.discount,
    required this.tax,
    required this.total,
    required this.totalDurationMinutes,
    this.potentialCashbackPoints = 0,
  });

  double get finalAmount => total;

  factory BookingPricingResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;

    final subtotal = (data['subtotal'] as num?)?.toDouble() ?? 0.0;
    final couponDiscount = (data['couponDiscount'] as num?)?.toDouble() ?? 0.0;
    final subscriptionDiscount =
        (data['subscriptionDiscount'] as num?)?.toDouble() ?? 0.0;
    final loyaltyPointsDiscount =
        (data['loyaltyPointsDiscount'] as num?)?.toDouble() ?? 0.0;

    final parsedDiscount =
        (data['totalDiscount'] as num?)?.toDouble() ??
        (data['discount'] as num?)?.toDouble() ??
        (couponDiscount + subscriptionDiscount + loyaltyPointsDiscount);

    final tax = (data['tax'] as num?)?.toDouble() ?? 0.0;
    final total =
        (data['finalAmount'] as num?)?.toDouble() ??
        (data['total'] as num?)?.toDouble() ??
        (subtotal - parsedDiscount + tax).clamp(0.0, double.infinity);

    final duration =
        (data['totalDurationMinutes'] as num?)?.toInt() ??
        (data['totalDuration'] as num?)?.toInt() ??
        0;

    final cashback = (data['potentialCashbackPoints'] as num?)?.toInt() ?? 0;

    return BookingPricingResponseModel(
      items: (data['items'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(BookingPricingItemModel.fromJson)
          .toList(),
      subtotal: subtotal,
      couponDiscount: couponDiscount,
      subscriptionDiscount: subscriptionDiscount,
      loyaltyPointsDiscount: loyaltyPointsDiscount,
      discount: parsedDiscount,
      tax: tax,
      total: total,
      totalDurationMinutes: duration,
      potentialCashbackPoints: cashback,
    );
  }
}

class BookingPricingItemModel {
  final String serviceId;
  final String serviceName;
  final String? productId;
  final String productBrand;
  final double productPriceModifier;
  final String stylistId;
  final String stylistName;
  final double itemPrice;
  final int itemDuration;

  const BookingPricingItemModel({
    required this.serviceId,
    required this.serviceName,
    required this.productId,
    required this.productBrand,
    required this.productPriceModifier,
    required this.stylistId,
    required this.stylistName,
    required this.itemPrice,
    required this.itemDuration,
  });

  factory BookingPricingItemModel.fromJson(Map<String, dynamic> json) {
    return BookingPricingItemModel(
      serviceId: json['serviceId']?.toString() ?? '',
      serviceName: json['serviceName']?.toString() ?? '',
      productId: json['productId']?.toString(),
      productBrand: json['productBrand']?.toString() ?? '',
      productPriceModifier:
          (json['productPriceModifier'] as num?)?.toDouble() ?? 0,
      stylistId: (json['stylistId'] ?? json['stylist'])?.toString() ?? '',
      stylistName: json['stylistName']?.toString() ?? '',
      itemPrice: (json['itemPrice'] as num?)?.toDouble() ?? 0,
      itemDuration: (json['itemDuration'] as num?)?.toInt() ?? 0,
    );
  }
}
