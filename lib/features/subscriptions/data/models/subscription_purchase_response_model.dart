class SubscriptionPurchaseResponseModel {
  final bool success;
  final String message;
  final String subscriptionId;
  final String invoiceNumber;
  final String membershipTier;
  final DateTime? expiryDate;

  const SubscriptionPurchaseResponseModel({
    required this.success,
    required this.message,
    required this.subscriptionId,
    required this.invoiceNumber,
    required this.membershipTier,
    this.expiryDate,
  });

  factory SubscriptionPurchaseResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;
    final expStr = data['expiryDate']?.toString();

    return SubscriptionPurchaseResponseModel(
      success: json['success'] == true,
      message:
          json['message']?.toString() ?? 'Subscription purchased successfully',
      subscriptionId:
          (data['subscriptionId'] ?? data['_id'] ?? data['id'] ?? '')
              .toString(),
      invoiceNumber: (data['invoiceNumber'] ?? '').toString(),
      membershipTier: (data['membershipTier'] ?? data['tier'] ?? '').toString(),
      expiryDate: expStr != null ? DateTime.tryParse(expStr) : null,
    );
  }
}
