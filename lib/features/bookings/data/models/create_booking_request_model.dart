import 'package:prop_crm/features/booking_summary/data/models/booking_summary_model.dart';
import 'package:prop_crm/features/payment/data/models/payment_method_model.dart';

class CreateBookingRequestModel {
  final String branchId;
  final String date;
  final String timeSlot;
  final String paymentMethod;
  final String serviceId;
  final String productId;
  final String stylistId;
  final String? couponCode;
  final String? notes;

  const CreateBookingRequestModel({
    required this.branchId,
    required this.date,
    required this.timeSlot,
    required this.paymentMethod,
    required this.serviceId,
    required this.productId,
    this.stylistId = 'any',
    this.couponCode,
    this.notes,
  });

  factory CreateBookingRequestModel.fromSummaryAndPayment({
    required BookingSummaryModel summary,
    required PaymentMethodModel paymentMethod,
    required String branchId,
    required String productId,
    String stylistId = 'any',
    String? couponCode,
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
      paymentMethod: paymentMethod.title,
      serviceId: summary.service.id,
      productId: productId,
      stylistId: stylistId,
      couponCode: couponCode,
      notes: notes,
    );
  }

  CreateBookingRequestModel copyWith({
    String? branchId,
    String? date,
    String? timeSlot,
    String? paymentMethod,
    String? serviceId,
    String? productId,
    String? stylistId,
    String? couponCode,
    String? notes,
  }) {
    return CreateBookingRequestModel(
      branchId: branchId ?? this.branchId,
      date: date ?? this.date,
      timeSlot: timeSlot ?? this.timeSlot,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      serviceId: serviceId ?? this.serviceId,
      productId: productId ?? this.productId,
      stylistId: stylistId ?? this.stylistId,
      couponCode: couponCode ?? this.couponCode,
      notes: notes ?? this.notes,
    );
  }

  factory CreateBookingRequestModel.fromJson(Map<String, dynamic> json) {
    final items = json['items'] as List? ?? [];
    final item = items.isNotEmpty && items.first is Map
        ? Map<String, dynamic>.from(items.first as Map)
        : <String, dynamic>{};

    return CreateBookingRequestModel(
      branchId: json['branchId'] as String? ?? '',
      date: json['date'] as String? ?? '',
      timeSlot: json['timeSlot'] as String? ?? '',
      paymentMethod: json['paymentMethod'] as String? ?? '',
      serviceId: item['serviceId'] as String? ?? '',
      productId: item['productId'] as String? ?? '',
      stylistId: item['stylistId'] as String? ?? 'any',
      couponCode: json['couponCode'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'branchId': branchId,
      'date': date,
      'timeSlot': timeSlot,
      'items': [
        {
          'serviceId': serviceId,
          'productId': productId,
          'stylistId': stylistId,
        },
      ],
      'paymentMethod': paymentMethod,
      if (couponCode != null && couponCode!.trim().isNotEmpty)
        'couponCode': couponCode,
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
    notes,
  );
}
