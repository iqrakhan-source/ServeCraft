
class BookingPricingResponseModel {
  final List<BookingPricingItemModel> items;
  final double subtotal;
  final double discount;
  final double tax;
  final double total;
  final int totalDurationMinutes;

  const BookingPricingResponseModel({
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.total,
    required this.totalDurationMinutes,
  });

  factory BookingPricingResponseModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return BookingPricingResponseModel(
      items: (json['items'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(BookingPricingItemModel.fromJson)
          .toList(),
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0,
      totalDurationMinutes:
      (json['totalDurationMinutes'] as num?)?.toInt() ?? 0,
    );
  }
}

class BookingPricingItemModel {
  final String serviceId;
  final String serviceName;
  final String productId;
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

  factory BookingPricingItemModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return BookingPricingItemModel(
      serviceId: json['serviceId']?.toString() ?? '',
      serviceName: json['serviceName']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      productBrand: json['productBrand']?.toString() ?? '',
      productPriceModifier:
      (json['productPriceModifier'] as num?)?.toDouble() ?? 0,
      stylistId: json['stylistId']?.toString() ?? '',
      stylistName: json['stylistName']?.toString() ?? '',
      itemPrice: (json['itemPrice'] as num?)?.toDouble() ?? 0,
      itemDuration: (json['itemDuration'] as num?)?.toInt() ?? 0,
    );
  }
}
