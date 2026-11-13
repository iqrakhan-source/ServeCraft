
class CreateBookingResponseModel {
  final AppointmentModel appointment;
  final PaymentOrderModel? paymentOrder;

  const CreateBookingResponseModel({
    required this.appointment,
    this.paymentOrder,
  });

  factory CreateBookingResponseModel.fromJson(
      Map<String, dynamic> json,
      ) {
    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;

    final appointmentJson = data['appointment'] ??
        data['booking'] ??
        data['appointmentData'] ??
        (data['_id'] != null || data['id'] != null ? data : null);

    if (appointmentJson is! Map) {
      throw const FormatException(
        'Appointment data is missing from booking response.',
      );
    }

    final paymentOrderJson = data['paymentOrder'] ?? json['paymentOrder'];

    return CreateBookingResponseModel(
      appointment: AppointmentModel.fromJson(
        Map<String, dynamic>.from(appointmentJson),
      ),
      paymentOrder: paymentOrderJson is Map
          ? PaymentOrderModel.fromJson(
        Map<String, dynamic>.from(paymentOrderJson),
      )
          : null,
    );
  }
}

class AppointmentModel {
  final String id;
  final String appointmentCode;
  final String customerName;
  final String customerPhone;
  final String branchName;
  final String date;
  final String timeSlot;
  final int totalDuration;
  final String status;
  final double totalAmount;
  final String paymentStatus;
  final String paymentMethod;
  final String? chairNumber;
  final String? stylistName;

  const AppointmentModel({
    required this.id,
    required this.appointmentCode,
    required this.customerName,
    required this.customerPhone,
    required this.branchName,
    required this.date,
    required this.timeSlot,
    required this.totalDuration,
    required this.status,
    required this.totalAmount,
    required this.paymentStatus,
    required this.paymentMethod,
    this.chairNumber,
    this.stylistName,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: (json['_id'] ?? json['id'])?.toString() ?? '',
      appointmentCode: json['appointmentCode']?.toString() ?? '',
      customerName: json['customerName']?.toString() ?? '',
      customerPhone: json['customerPhone']?.toString() ?? '',
      branchName: json['branchName']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      timeSlot: json['timeSlot']?.toString() ?? '',
      totalDuration: (json['totalDuration'] as num?)?.toInt() ?? 0,
      status: json['status']?.toString() ?? '',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      paymentStatus: json['paymentStatus']?.toString() ?? '',
      paymentMethod: json['paymentMethod']?.toString() ?? '',
      chairNumber: json['chairNumber']?.toString(),
      stylistName: json['stylistName']?.toString(),
    );
  }
}

class PaymentOrderModel {
  final String orderId;
  final int amount;
  final String currency;
  final String key;

  const PaymentOrderModel({
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.key,
  });

  factory PaymentOrderModel.fromJson(Map<String, dynamic> json) {
    return PaymentOrderModel(
      orderId: json['orderId']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      currency: json['currency']?.toString() ?? 'INR',
      key: json['key']?.toString() ?? '',
    );
  }
}
