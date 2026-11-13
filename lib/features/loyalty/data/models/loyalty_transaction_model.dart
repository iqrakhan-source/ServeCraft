class LoyaltyTransactionModel {
  final String id;
  final String type; // 'EARN' | 'REDEEM' | 'REFUND'
  final int points;
  final int balanceAfter;
  final String description;
  final DateTime createdAt;

  const LoyaltyTransactionModel({
    required this.id,
    required this.type,
    required this.points,
    required this.balanceAfter,
    required this.description,
    required this.createdAt,
  });

  bool get isEarn => type.toUpperCase() == 'EARN';
  bool get isRedeem => type.toUpperCase() == 'REDEEM';
  bool get isRefund => type.toUpperCase() == 'REFUND';

  factory LoyaltyTransactionModel.fromJson(Map<String, dynamic> json) {
    return LoyaltyTransactionModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      type: (json['type'] ?? 'EARN').toString(),
      points: (json['points'] as num?)?.toInt() ?? 0,
      balanceAfter: (json['balanceAfter'] as num?)?.toInt() ?? 0,
      description: (json['description'] ?? '').toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'points': points,
      'balanceAfter': balanceAfter,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
