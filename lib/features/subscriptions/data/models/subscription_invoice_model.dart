class SubscriptionInvoiceModel {
  final String id;
  final String invoiceNumber;
  final String planName;
  final double amount;
  final double tax; // ZERO GST
  final double finalAmount;
  final String paymentStatus;
  final DateTime createdAt;

  const SubscriptionInvoiceModel({
    required this.id,
    required this.invoiceNumber,
    required this.planName,
    required this.amount,
    this.tax = 0.0,
    required this.finalAmount,
    required this.paymentStatus,
    required this.createdAt,
  });

  factory SubscriptionInvoiceModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionInvoiceModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      invoiceNumber: (json['invoiceNumber'] ?? '').toString(),
      planName: (json['planName'] ?? 'Membership').toString(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
      finalAmount:
          (json['finalAmount'] as num?)?.toDouble() ??
          ((json['amount'] as num?)?.toDouble() ?? 0.0),
      paymentStatus: (json['paymentStatus'] ?? 'paid').toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoiceNumber': invoiceNumber,
      'planName': planName,
      'amount': amount,
      'tax': tax,
      'finalAmount': finalAmount,
      'paymentStatus': paymentStatus,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
