class CreateBookingResponseModel {
  final AppointmentModel appointment;
  final PaymentOrderModel? paymentOrder;

  const CreateBookingResponseModel({
    required this.appointment,
    this.paymentOrder,
  });

  factory CreateBookingResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;

    final appointmentJson =
        data['appointment'] ??
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
  final String branchId;
  final String date;
  final String timeSlot;
  final int totalDuration;
  final String status;
  final double subtotal;
  final double discount;
  final int pointsRedeemed;
  final double tax;
  final double finalAmount;
  final String paymentStatus;
  final String paymentMethod;
  final String? chairNumber;
  final String? stylistName;

  const AppointmentModel({
    required this.id,
    required this.appointmentCode,
    this.customerName = '',
    this.customerPhone = '',
    this.branchName = '',
    this.branchId = '',
    required this.date,
    required this.timeSlot,
    this.totalDuration = 0,
    required this.status,
    this.subtotal = 0.0,
    this.discount = 0.0,
    this.pointsRedeemed = 0,
    this.tax = 0.0,
    required this.finalAmount,
    this.paymentStatus = 'pending',
    this.paymentMethod = 'online',
    this.chairNumber,
    this.stylistName,
  });

  double get totalAmount => finalAmount;

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    String branchId = '';
    String branchName = '';
    if (json['branch'] is Map) {
      final bMap = Map<String, dynamic>.from(json['branch'] as Map);
      branchId = (bMap['_id'] ?? bMap['id'])?.toString() ?? '';
      branchName = (bMap['name'])?.toString() ?? '';
    } else if (json['branch'] is String) {
      branchId = json['branch'] as String;
    }
    if (branchName.isEmpty && json['branchName'] != null) {
      branchName = json['branchName'].toString();
    }

    String customerName = '';
    String customerPhone = '';
    if (json['customer'] is Map) {
      final cMap = Map<String, dynamic>.from(json['customer'] as Map);
      customerName = (cMap['name'])?.toString() ?? '';
      customerPhone = (cMap['phone'] ?? cMap['mobileNumber'])?.toString() ?? '';
    }
    if (customerName.isEmpty && json['customerName'] != null) {
      customerName = json['customerName'].toString();
    }
    if (customerPhone.isEmpty && json['customerPhone'] != null) {
      customerPhone = json['customerPhone'].toString();
    }

    final finalAmt =
        (json['finalAmount'] as num?)?.toDouble() ??
        (json['totalAmount'] as num?)?.toDouble() ??
        (json['total'] as num?)?.toDouble() ??
        0.0;

    String resolvedPaymentMethod = 'online';
    if (json['paymentMethod'] is String) {
      resolvedPaymentMethod = json['paymentMethod'].toString();
    } else if (json['paymentMethod'] is Map) {
      final pMap = json['paymentMethod'] as Map;
      resolvedPaymentMethod =
          (pMap['title'] ?? pMap['type'] ?? pMap['method'] ?? 'online')
              .toString();
    } else if (json['payment_method'] != null) {
      resolvedPaymentMethod = json['payment_method'].toString();
    }

    final resolvedPaymentStatus =
        (json['paymentStatus'] ??
                json['payment_status'] ??
                (json['payment'] is Map
                    ? (json['payment'] as Map)['status']
                    : null) ??
                'pending')
            .toString();

    return AppointmentModel(
      id: (json['_id'] ?? json['id'])?.toString() ?? '',
      appointmentCode:
          (json['appointmentCode'] ?? json['bookingReference'])?.toString() ??
          '',
      customerName: customerName,
      customerPhone: customerPhone,
      branchName: branchName,
      branchId: branchId,
      date: json['date']?.toString() ?? '',
      timeSlot: json['timeSlot']?.toString() ?? '',
      totalDuration: (json['totalDuration'] as num?)?.toInt() ?? 0,
      status: json['status']?.toString() ?? 'confirmed',
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? finalAmt,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      pointsRedeemed: (json['pointsRedeemed'] as num?)?.toInt() ?? 0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
      finalAmount: finalAmt,
      paymentStatus: resolvedPaymentStatus,
      paymentMethod: resolvedPaymentMethod,
      chairNumber: json['chairNumber']?.toString(),
      stylistName: json['stylistName']?.toString(),
    );
  }
}

class PaymentOrderModel {
  final String orderId;
  final int amount;
  final String currency;

  const PaymentOrderModel({
    required this.orderId,
    required this.amount,
    required this.currency,
  });

  factory PaymentOrderModel.fromJson(Map<String, dynamic> json) {
    return PaymentOrderModel(
      orderId: (json['orderId'] ?? json['id'])?.toString() ?? '',
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      currency: json['currency']?.toString() ?? 'INR',
    );
  }
}
