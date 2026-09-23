import 'package:prop_crm/features/booking_summary/data/models/booking_summary_model.dart';
import 'package:prop_crm/features/payment/data/models/payment_method_model.dart';

class CreateBookingRequestModel {
  final String serviceId;
  final String packageId;
  final String addressId;
  final String scheduledDate;
  final String timeSlotId;
  final String paymentMethodId;
  final double totalAmount;

  const CreateBookingRequestModel({
    required this.serviceId,
    required this.packageId,
    required this.addressId,
    required this.scheduledDate,
    required this.timeSlotId,
    required this.paymentMethodId,
    required this.totalAmount,
  });

  factory CreateBookingRequestModel.fromSummaryAndPayment({
    required BookingSummaryModel summary,
    required PaymentMethodModel paymentMethod,
  }) {
    final dateStr = summary.scheduledDate.date.toIso8601String().split('T').first;
    return CreateBookingRequestModel(
      serviceId: summary.service.id,
      packageId: summary.package.id,
      addressId: summary.address.id,
      scheduledDate: dateStr,
      timeSlotId: summary.timeSlot.id,
      paymentMethodId: paymentMethod.id,
      totalAmount: summary.pricing.totalAmount,
    );
  }

  CreateBookingRequestModel copyWith({
    String? serviceId,
    String? packageId,
    String? addressId,
    String? scheduledDate,
    String? timeSlotId,
    String? paymentMethodId,
    double? totalAmount,
  }) {
    return CreateBookingRequestModel(
      serviceId: serviceId ?? this.serviceId,
      packageId: packageId ?? this.packageId,
      addressId: addressId ?? this.addressId,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      timeSlotId: timeSlotId ?? this.timeSlotId,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }

  factory CreateBookingRequestModel.fromJson(Map<String, dynamic> json) {
    return CreateBookingRequestModel(
      serviceId: json['serviceId'] as String? ?? '',
      packageId: json['packageId'] as String? ?? '',
      addressId: json['addressId'] as String? ?? '',
      scheduledDate: json['scheduledDate'] as String? ?? '',
      timeSlotId: json['timeSlotId'] as String? ?? '',
      paymentMethodId: json['paymentMethodId'] as String? ?? '',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serviceId': serviceId,
      'packageId': packageId,
      'addressId': addressId,
      'scheduledDate': scheduledDate,
      'timeSlotId': timeSlotId,
      'paymentMethodId': paymentMethodId,
      'totalAmount': totalAmount,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateBookingRequestModel &&
          runtimeType == other.runtimeType &&
          serviceId == other.serviceId &&
          packageId == other.packageId &&
          addressId == other.addressId &&
          scheduledDate == other.scheduledDate &&
          timeSlotId == other.timeSlotId &&
          paymentMethodId == other.paymentMethodId &&
          totalAmount == other.totalAmount;

  @override
  int get hashCode =>
      serviceId.hashCode ^
      packageId.hashCode ^
      addressId.hashCode ^
      scheduledDate.hashCode ^
      timeSlotId.hashCode ^
      paymentMethodId.hashCode ^
      totalAmount.hashCode;
}
