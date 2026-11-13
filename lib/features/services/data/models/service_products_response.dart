
class ServiceProductsResponse {
  final bool success;
  final ServiceProductInfo? service;
  final List<ConsumableProduct> products;

  const ServiceProductsResponse({
    required this.success,
    this.service,
    required this.products,
  });

  factory ServiceProductsResponse.fromJson(
      Map<String, dynamic> json,
      ) {
    // Actual API response: { count: 2, data: { products: [] } }
    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : <String, dynamic>{};

    final rawProducts = (data['products'] ?? json['products']) as List? ?? [];

    return ServiceProductsResponse(
      success: json['success'] == true,
      service: json['service'] is Map
          ? ServiceProductInfo.fromJson(
        Map<String, dynamic>.from(json['service'] as Map),
      )
          : null,
      products: rawProducts
          .where((item) => item is Map)
          .map(
            (item) => ConsumableProduct.fromJson(
          Map<String, dynamic>.from(item as Map),
        ),
      )
          .toList(),
    );
  }
}

class ServiceProductInfo {
  final String id;
  final String name;
  final double basePrice;
  final int duration;

  const ServiceProductInfo({
    required this.id,
    required this.name,
    required this.basePrice,
    required this.duration,
  });

  factory ServiceProductInfo.fromJson(
      Map<String, dynamic> json,
      ) {
    return ServiceProductInfo(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      basePrice: (json['basePrice'] as num?)?.toDouble() ?? 0,
      duration: (json['duration'] as num?)?.toInt() ?? 0,
    );
  }
}

class ConsumableProduct {
  final String id;
  final String name;
  final String brand;
  final String description;
  final double addedPrice;
  final int addedDuration;
  final double price;

  const ConsumableProduct({
    required this.id,
    required this.name,
    required this.brand,
    required this.description,
    required this.addedPrice,
    required this.addedDuration,
    required this.price,
  });

  factory ConsumableProduct.fromJson(
      Map<String, dynamic> json,
      ) {
    return ConsumableProduct(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      brand: json['brand']?.toString() ?? '',
      description: json['category']?.toString() ?? '',
      addedPrice:
      (json['servicePriceModifier'] as num?)?.toDouble() ?? 0,
      addedDuration:
      (json['durationModifier'] as num?)?.toInt() ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0,
    );
  }
}
