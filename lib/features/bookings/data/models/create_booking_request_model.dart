import 'package:prop_crm/features/booking_summary/data/models/booking_summary_model.dart';
import 'package:prop_crm/features/payment/data/models/payment_method_model.dart';

class CreateBookingRequestModel {
  final String branchId;
  final String date;
  final String timeSlot;
  final String? chairNumber;
  final String paymentMethod;
  final String serviceId;
  final String? productId;
  final String stylistId;
  final String? couponCode;
  final int? pointsRedeemed;
  final String? notes;

  const CreateBookingRequestModel({
    required this.branchId,
    required this.date,
    required this.timeSlot,
    this.chairNumber,
    required this.paymentMethod,
    required this.serviceId,
    this.productId,
    this.stylistId = 'any',
    this.couponCode,
    this.pointsRedeemed,
    this.notes,
  });

  static String normalizePaymentMethod(dynamic method) {
    if (method is PaymentMethodModel) {
      if (method.type == PaymentMethodType.cod) return 'cash';
      if (method.type == PaymentMethodType.card) return 'card';
      if (method.type == PaymentMethodType.upi) return 'upi';
      return normalizePaymentMethod(method.title);
    }
    final str = method?.toString() ?? '';
    final lower = str.trim().toLowerCase();
    if (lower.contains('cash') ||
        lower.contains('salon') ||
        lower.contains('cod') ||
        lower.contains('reception') ||
        lower.contains('desk') ||
        lower.contains('offline')) {
      return 'cash';
    }
    if (lower.contains('card')) return 'card';
    if (lower.contains('upi')) return 'upi';
    if (lower.contains('online') || lower.contains('gateway')) return 'online';
    return 'online';
  }

  factory CreateBookingRequestModel.fromSummaryAndPayment({
    required BookingSummaryModel summary,
    required PaymentMethodModel paymentMethod,
    required String branchId,
    String? chairNumber,
    String? productId,
    String stylistId = 'any',
    String? couponCode,
    int? pointsRedeemed,
    String? notes,
  }) {
    final dateStr = summary.scheduledDate.date
        .toIso8601String()
        .split('T')
        .first;

    return CreateBookingRequestModel(
      branchId: branchId,
      date: dateStr,
      timeSlot: summary.timeSlot.bookingTimeSlot,
      chairNumber: chairNumber ?? summary.chairNumber,
      paymentMethod: normalizePaymentMethod(paymentMethod),
      serviceId: summary.service.id,
      productId: productId ?? summary.productId,
      stylistId: stylistId != 'any' ? stylistId : (summary.stylistId ?? 'any'),
      couponCode: couponCode ?? summary.appliedCoupon?.code,
      pointsRedeemed: pointsRedeemed,
      notes: notes ?? summary.specialInstructions,
    );
  }

  CreateBookingRequestModel copyWith({
    String? branchId,
    String? date,
    String? timeSlot,
    String? chairNumber,
    String? paymentMethod,
    String? serviceId,
    String? productId,
    bool clearProductId = false,
    String? stylistId,
    String? couponCode,
    int? pointsRedeemed,
    String? notes,
  }) {
    return CreateBookingRequestModel(
      branchId: branchId ?? this.branchId,
      date: date ?? this.date,
      timeSlot: timeSlot ?? this.timeSlot,
      chairNumber: chairNumber ?? this.chairNumber,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      serviceId: serviceId ?? this.serviceId,
      productId: clearProductId ? null : productId ?? this.productId,
      stylistId: stylistId ?? this.stylistId,
      couponCode: couponCode ?? this.couponCode,
      pointsRedeemed: pointsRedeemed ?? this.pointsRedeemed,
      notes: notes ?? this.notes,
    );
  }

  factory CreateBookingRequestModel.fromJson(Map<String, dynamic> json) {
    final cartList = json['cartItems'] as List? ?? json['items'] as List? ?? [];
    final item = cartList.isNotEmpty && cartList.first is Map
        ? Map<String, dynamic>.from(cartList.first as Map)
        : <String, dynamic>{};

    final rawProductId = item['productId'] as String?;

    return CreateBookingRequestModel(
      branchId: json['branchId'] as String? ?? '',
      date: json['date'] as String? ?? '',
      timeSlot: json['timeSlot'] as String? ?? '',
      chairNumber: json['chairNumber'] as String?,
      paymentMethod: json['paymentMethod'] as String? ?? 'online',
      serviceId: item['serviceId'] as String? ?? '',
      productId: rawProductId?.trim().isNotEmpty == true ? rawProductId : null,
      stylistId: (item['stylist'] ?? item['stylistId']) as String? ?? 'any',
      couponCode: json['couponCode'] as String?,
      pointsRedeemed: (json['pointsRedeemed'] as num?)?.toInt(),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final cartItem = <String, dynamic>{'serviceId': serviceId};
    if (stylistId.isNotEmpty && stylistId != 'any') {
      cartItem['stylist'] = stylistId;
    }

    final legacyItem = <String, dynamic>{
      'serviceId': serviceId,
      'stylistId': stylistId,
    };
    if (productId != null && productId!.trim().isNotEmpty) {
      legacyItem['productId'] = productId!.trim();
    }

    return {
      'branchId': branchId,
      'branch': branchId,
      'serviceId': serviceId,
      'service': serviceId,
      'date': date,
      'timeSlot': timeSlot,
      if (chairNumber != null && chairNumber!.trim().isNotEmpty)
        'chairNumber': chairNumber!.trim(),
      // Primary contract spec: cartItems: [{ serviceId, stylist }]
      'cartItems': [cartItem],
      // Backward-compatible legacy items
      'items': [legacyItem],
      'paymentMethod': normalizePaymentMethod(paymentMethod),
      if (couponCode != null && couponCode!.trim().isNotEmpty)
        'couponCode': couponCode,
      if (pointsRedeemed != null && pointsRedeemed! > 0)
        'pointsRedeemed': pointsRedeemed,
      if (notes != null && notes!.trim().isNotEmpty) 'notes': notes,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateBookingRequestModel &&
          branchId == other.branchId &&
          date == other.date &&
          timeSlot == other.timeSlot &&
          paymentMethod == other.paymentMethod &&
          serviceId == other.serviceId &&
          productId == other.productId &&
          stylistId == other.stylistId &&
          couponCode == other.couponCode &&
          pointsRedeemed == other.pointsRedeemed &&
          notes == other.notes;

  @override
  int get hashCode => Object.hash(
    branchId,
    date,
    timeSlot,
    paymentMethod,
    serviceId,
    productId,
    stylistId,
    couponCode,
    pointsRedeemed,
    notes,
  );
}
