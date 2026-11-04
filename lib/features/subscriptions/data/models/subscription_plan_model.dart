
class SubscriptionPlanModel {
  final String id;
  final String name;
  final String tier;
  final String description;
  final double price;
  final int validityDays;
  final double discountPercentage;
  final List<String> benefits;
  final List<String> perks;
  final bool isGlobal;
  final String? branchId;
  final String? branchName;
  final String? branchCode;
  final String? branchCity;
  final bool isActive;

  const SubscriptionPlanModel({
    required this.id,
    required this.name,
    required this.tier,
    required this.description,
    required this.price,
    required this.validityDays,
    required this.discountPercentage,
    required this.benefits,
    required this.perks,
    required this.isGlobal,
    this.branchId,
    this.branchName,
    this.branchCode,
    this.branchCity,
    required this.isActive,
  });

  factory SubscriptionPlanModel.fromJson(
      Map<String, dynamic> json,
      ) {
    final branch = json['branchId'];

    return SubscriptionPlanModel(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      tier: json['tier']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      validityDays: (json['validityDays'] as num?)?.toInt() ?? 0,
      discountPercentage:
      (json['discountPercentage'] as num?)?.toDouble() ?? 0.0,
      benefits: (json['benefits'] as List<dynamic>?)
          ?.map((item) => item.toString())
          .toList() ??
          [],
      perks: (json['perks'] as List<dynamic>?)
          ?.map((item) => item.toString())
          .toList() ??
          [],
      isGlobal: json['isGlobal'] as bool? ?? false,
      branchId: branch is Map
          ? branch['_id']?.toString()
          : branch?.toString(),
      branchName:
      branch is Map ? branch['name']?.toString() : null,
      branchCode:
      branch is Map ? branch['code']?.toString() : null,
      branchCity:
      branch is Map ? branch['city']?.toString() : null,
      isActive: json['active'] as bool? ?? false,
    );
  }
}
