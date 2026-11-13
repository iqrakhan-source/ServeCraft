class LoyaltyWalletModel {
  final int loyaltyPoints;
  final double rupeeValue;
  final int lifetimeEarnedPoints;
  final String tier;
  final double cashbackRate;
  final double maxRedemptionPercentage;

  const LoyaltyWalletModel({
    required this.loyaltyPoints,
    required this.rupeeValue,
    required this.lifetimeEarnedPoints,
    required this.tier,
    required this.cashbackRate,
    required this.maxRedemptionPercentage,
  });

  factory LoyaltyWalletModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;

    return LoyaltyWalletModel(
      loyaltyPoints: (data['loyaltyPoints'] as num?)?.toInt() ?? 0,
      rupeeValue:
          (data['rupeeValue'] as num?)?.toDouble() ??
          ((data['loyaltyPoints'] as num?)?.toDouble() ?? 0.0),
      lifetimeEarnedPoints:
          (data['lifetimeEarnedPoints'] as num?)?.toInt() ?? 0,
      tier: (data['tier']?.toString() ?? 'Standard'),
      cashbackRate: (data['cashbackRate'] as num?)?.toDouble() ?? 5.0,
      maxRedemptionPercentage:
          (data['maxRedemptionPercentage'] as num?)?.toDouble() ?? 10.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'loyaltyPoints': loyaltyPoints,
      'rupeeValue': rupeeValue,
      'lifetimeEarnedPoints': lifetimeEarnedPoints,
      'tier': tier,
      'cashbackRate': cashbackRate,
      'maxRedemptionPercentage': maxRedemptionPercentage,
    };
  }
}
