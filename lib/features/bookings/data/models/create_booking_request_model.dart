
import 'package:prop_crm/features/booking_summary/data/models/booking_summary_model.dart';
import 'package:prop_crm/features/payment/data/models/payment_method_model.dart';

class CreateBookingRequestModel {
  final String branchId;
  final String date;
  final String timeSlot;
  final String paymentMethod;
  final String serviceId;
  final String productId;
  final int productQuantity;

  const CreateBookingRequestModel({
    required this.branchId,
    required this.date,
    required this.timeSlot,
    required this.paymentMethod,
    required this.serviceId,
    required this.productId,
    this.productQuantity = 1,
  });

  factory CreateBookingRequestModel.fromSummaryAndPayment({
    required BookingSummaryModel summary,
    required PaymentMethodModel paymentMethod,
    required String branchId,
    required String productId,
    int productQuantity = 1,
  }) {
    final dateStr =
        summary.scheduledDate.date.toIso8601String().split('T').first;

    return CreateBookingRequestModel(
      branchId: branchId,
      date: dateStr,
      timeSlot: summary.timeSlot.startTime,
      paymentMethod: paymentMethod.title,
      serviceId: summary.service.id,
      productId: productId,
      productQuantity: productQuantity,
    );
  }

  CreateBookingRequestModel copyWith({
    String? branchId,
    String? date,
    String? timeSlot,
    String? paymentMethod,
    String? serviceId,
    String? productId,
    int? productQuantity,
  }) {
    return CreateBookingRequestModel(
      branchId: branchId ?? this.branchId,
      date: date ?? this.date,
      timeSlot: timeSlot ?? this.timeSlot,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      serviceId: serviceId ?? this.serviceId,
      productId: productId ?? this.productId,
      productQuantity: productQuantity ?? this.productQuantity,
    );
  }

  factory CreateBookingRequestModel.fromJson(Map<String, dynamic> json) {
    final bookingItem =
        json['bookingItem'] as Map<String, dynamic>? ?? {};

    return CreateBookingRequestModel(
      branchId: json['branchId'] as String? ?? '',
      date: json['date'] as String? ?? '',
      timeSlot: json['timeSlot'] as String? ?? '',
      paymentMethod: json['paymentMethod'] as String? ?? '',
      serviceId: bookingItem['serviceId'] as String? ?? '',
      productId: bookingItem['productId'] as String? ?? '',
      productQuantity:
      (bookingItem['productQuantity'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'branchId': branchId,
      'date': date,
      'timeSlot': timeSlot,
      'paymentMethod': paymentMethod,
      'bookingItem': {
        'serviceId': serviceId,
        'productId': productId,
        'productQuantity': productQuantity,
      },
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
              productQuantity == other.productQuantity;

  @override
  int get hashCode => Object.hash(
    branchId,
    date,
    timeSlot,
    paymentMethod,
    serviceId,
    productId,
    productQuantity,
  );
}
