import 'package:prop_crm/core/utilities/formatters.dart';
import 'package:prop_crm/features/addresses/data/models/address_model.dart';
import 'package:prop_crm/features/branches/data/models/branch_model.dart';
import 'package:prop_crm/features/booking_summary/data/models/pricing_breakdown_model.dart';
import 'package:prop_crm/features/date_time/data/models/service_date_model.dart';
import 'package:prop_crm/features/date_time/data/models/time_slot_model.dart';
import 'package:prop_crm/features/payment/data/models/payment_method_model.dart';
import 'package:prop_crm/features/services/data/models/service_model.dart';
import 'package:prop_crm/features/services/data/models/service_package_model.dart';

enum BookingStatus {
  confirmed,
  pending,
  cancelled,
  completed,
  rescheduled;

  static BookingStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'pending':
        return BookingStatus.pending;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'completed':
        return BookingStatus.completed;
      case 'rescheduled':
        return BookingStatus.rescheduled;
      default:
        return BookingStatus.confirmed;
    }
  }

  String toFormattedString() {
    switch (this) {
      case BookingStatus.confirmed:
        return 'confirmed';
      case BookingStatus.pending:
        return 'pending';
      case BookingStatus.cancelled:
        return 'cancelled';
      case BookingStatus.completed:
        return 'completed';
      case BookingStatus.rescheduled:
        return 'rescheduled';
    }
  }

  String get displayName {
    switch (this) {
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.rescheduled:
        return 'Rescheduled';
    }
  }
}

class BookingModel {
  final String id;
  final String bookingReference;
  final BookingStatus status;
  final ServiceModel service;
  final ServicePackageModel package;
  final AddressModel address;
  final BranchModel? branch;
  final ServiceDateModel scheduledDate;
  final TimeSlotModel timeSlot;
  final PaymentMethodModel paymentMethod;
  final String paymentStatus;
  final PricingBreakdown pricing;
  final DateTime createdAt;
  final String? cancellationReason;
  final String? cancellationNote;
  final DateTime? cancelledAt;
  final DateTime? rescheduledAt;
  final int? durationMinutes;

  const BookingModel({
    required this.id,
    required this.bookingReference,
    required this.status,
    required this.service,
    required this.package,
    required this.address,
    this.branch,
    required this.scheduledDate,
    required this.timeSlot,
    required this.paymentMethod,
    this.paymentStatus = 'pending',
    required this.pricing,
    required this.createdAt,
    this.cancellationReason,
    this.cancellationNote,
    this.cancelledAt,
    this.rescheduledAt,
    this.durationMinutes,
  });

  /// Whether payment has been successfully captured/paid
  bool get isPaid =>
      paymentStatus.toLowerCase() == 'paid' ||
      paymentStatus.toLowerCase() == 'completed' ||
      paymentStatus.toLowerCase() == 'success';

  /// Whether payment is still pending/unpaid
  bool get isPaymentPending => !isPaid;

  /// Convenient getter for branch ID
  String? get branchId => branch?.id;

  /// Formatted booking reference (e.g. GLM-2026-000001)
  String get formattedBookingReference => bookingReference;

  /// Helper for schedule summary display: "Saturday, 26 September • 10:00 AM - 11:00 AM"
  String get formattedSchedule =>
      '${scheduledDate.dayName}, ${scheduledDate.dayNumber} ${scheduledDate.monthName} • ${timeSlot.formattedLabel}';

  /// Formatted final total amount (e.g. ₹1,061)
  String get formattedTotal =>
      AppFormatters.formatCurrency(pricing.totalAmount);

  /// Check whether booking is confirmed or rescheduled
  bool get isConfirmed =>
      status == BookingStatus.confirmed || status == BookingStatus.rescheduled;

  /// Precise scheduled DateTime combining date and slot time
  DateTime get scheduledDateTime {
    try {
      final raw = timeSlot.startTime.trim().toUpperCase();
      final isPm = raw.contains('PM');
      final isAm = raw.contains('AM');
      final clean = raw.replaceAll('AM', '').replaceAll('PM', '').trim();
      final parts = clean.split(':');
      var hour = int.parse(parts[0]);
      final minute = parts.length > 1 ? int.parse(parts[1]) : 0;
      if (isPm && hour < 12) hour += 12;
      if (isAm && hour == 12) hour = 0;
      return DateTime(
        scheduledDate.date.year,
        scheduledDate.date.month,
        scheduledDate.date.day,
        hour,
        minute,
      );
    } catch (_) {
      return scheduledDate.date;
    }
  }

  /// Salon Business Rule: Check if appointment is in the future and within 2 hours of starting time
  bool get isWithin2HoursOfAppointment {
    final now = DateTime.now();
    final difference = scheduledDateTime.difference(now);
    return !difference.isNegative && difference.inMinutes < 120;
  }

  /// Salon Business Rule: Cancellation allowed ONLY up to 2 hours before appointment
  bool get isCancellable {
    if (status == BookingStatus.cancelled ||
        status == BookingStatus.completed) {
      return false;
    }
    return !isWithin2HoursOfAppointment;
  }

  /// Salon Business Rule: Rescheduling allowed ONLY up to 2 hours before appointment
  bool get isReschedulable {
    if (status == BookingStatus.cancelled ||
        status == BookingStatus.completed) {
      return false;
    }
    return !isWithin2HoursOfAppointment;
  }

  BookingModel copyWith({
    String? id,
    String? bookingReference,
    BookingStatus? status,
    ServiceModel? service,
    ServicePackageModel? package,
    AddressModel? address,
    BranchModel? branch,
    ServiceDateModel? scheduledDate,
    TimeSlotModel? timeSlot,
    PaymentMethodModel? paymentMethod,
    String? paymentStatus,
    PricingBreakdown? pricing,
    DateTime? createdAt,
    String? cancellationReason,
    String? cancellationNote,
    DateTime? cancelledAt,
    DateTime? rescheduledAt,
    int? durationMinutes,
  }) {
    return BookingModel(
      id: id ?? this.id,
      bookingReference: bookingReference ?? this.bookingReference,
      status: status ?? this.status,
      service: service ?? this.service,
      package: package ?? this.package,
      address: address ?? this.address,
      branch: branch ?? this.branch,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      timeSlot: timeSlot ?? this.timeSlot,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      pricing: pricing ?? this.pricing,
      createdAt: createdAt ?? this.createdAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      cancellationNote: cancellationNote ?? this.cancellationNote,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      rescheduledAt: rescheduledAt ?? this.rescheduledAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
    );
  }

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    // Safely convert a value to a map.
    Map<String, dynamic> asMap(dynamic value) {
      if (value is Map) {
        return Map<String, dynamic>.from(value);
      }
      return <String, dynamic>{};
    }

    // Unwrap root booking object if wrapped in { "booking": ... } or { "data": { "booking": ... } }
    final Map<String, dynamic> root = (json['booking'] is Map)
        ? asMap(json['booking'])
        : (json['data'] is Map && (json['data'] as Map)['booking'] is Map)
        ? asMap((json['data'] as Map)['booking'])
        : (json['data'] is Map)
        ? asMap(json['data'])
        : json;

    String serviceId = '';
    String serviceName = 'Salon Service';
    String serviceCategory = '';
    String serviceDescription = '';
    double servicePrice = 0.0;
    int? serviceDurationMinutes;

    // Check items or cartItems first (from booking details API)
    final itemsList = root['items'] is List
        ? root['items'] as List
        : root['cartItems'] is List
        ? root['cartItems'] as List
        : <dynamic>[];

    final servicesList = root['services'] is List
        ? root['services'] as List
        : <dynamic>[];

    if (itemsList.isNotEmpty) {
      final firstItem = itemsList.first;
      if (firstItem is Map) {
        final itemMap = asMap(firstItem);
        if (itemMap['service'] is Map) {
          final sMap = asMap(itemMap['service']);
          serviceId = (sMap['_id'] ?? sMap['id'] ?? '').toString();
          serviceName = (sMap['name'] ?? itemMap['serviceName'] ?? serviceName)
              .toString();
          serviceCategory = (sMap['categoryId'] ?? sMap['category'] ?? '')
              .toString();
          serviceDescription = (sMap['description'] ?? '').toString();
          if (sMap['price'] is num) {
            servicePrice = (sMap['price'] as num).toDouble();
          }
          if (sMap['duration'] is num) {
            serviceDurationMinutes = (sMap['duration'] as num).toInt();
          }
        } else if (itemMap['service'] is String &&
            (itemMap['service'] as String).isNotEmpty) {
          serviceId = itemMap['service'].toString();
          serviceName =
              (itemMap['serviceName'] ?? itemMap['name'] ?? serviceName)
                  .toString();
        } else if (itemMap['serviceId'] != null &&
            itemMap['serviceId'].toString().isNotEmpty) {
          serviceId = itemMap['serviceId'].toString();
          serviceName =
              (itemMap['serviceName'] ?? itemMap['name'] ?? serviceName)
                  .toString();
        }

        if (servicePrice == 0.0 && itemMap['price'] is num) {
          servicePrice = (itemMap['price'] as num).toDouble();
        }
        if (serviceDurationMinutes == null && itemMap['duration'] is num) {
          serviceDurationMinutes = (itemMap['duration'] as num).toInt();
        }
      }
    }

    if (serviceId.isEmpty && servicesList.isNotEmpty) {
      final firstService = servicesList.first;
      if (firstService is Map) {
        final sMap = asMap(firstService);
        serviceId = (sMap['_id'] ?? sMap['id'] ?? '').toString();
        serviceName = (sMap['name'] ?? serviceName).toString();
        serviceCategory = (sMap['categoryId'] ?? sMap['category'] ?? '')
            .toString();
        serviceDescription = (sMap['description'] ?? '').toString();
        if (sMap['price'] is num) {
          servicePrice = (sMap['price'] as num).toDouble();
        }
        if (sMap['duration'] is num) {
          serviceDurationMinutes = (sMap['duration'] as num).toInt();
        }
      } else if (firstService is String && firstService.isNotEmpty) {
        serviceId = firstService;
      }
    }

    if (serviceId.isEmpty && root['service'] != null) {
      if (root['service'] is Map) {
        final sMap = asMap(root['service']);
        serviceId = (sMap['_id'] ?? sMap['id'] ?? '').toString();
        serviceName = (sMap['name'] ?? serviceName).toString();
        serviceCategory = (sMap['categoryId'] ?? sMap['category'] ?? '')
            .toString();
        serviceDescription = (sMap['description'] ?? '').toString();
        if (sMap['price'] is num) {
          servicePrice = (sMap['price'] as num).toDouble();
        }
        if (sMap['duration'] is num) {
          serviceDurationMinutes = (sMap['duration'] as num).toInt();
        }
      } else if (root['service'] is String &&
          (root['service'] as String).isNotEmpty) {
        serviceId = root['service'].toString();
      }
    }

    if (serviceId.isEmpty && root['serviceId'] != null) {
      serviceId = root['serviceId'].toString();
    }
    if (root['serviceName'] != null && serviceName == 'Salon Service') {
      serviceName = root['serviceName'].toString();
    }

    // Branch extraction supporting nested object or ID
    BranchModel? branch;
    String? explicitBranchId;

    if (root['branch'] is Map) {
      final bMap = asMap(root['branch']);
      if (bMap.isNotEmpty) {
        branch = BranchModel.fromJson(bMap);
        explicitBranchId = branch.id;
      }
    } else if (root['branch'] is String &&
        (root['branch'] as String).isNotEmpty) {
      explicitBranchId = root['branch'] as String;
    }

    if (explicitBranchId == null || explicitBranchId.isEmpty) {
      if (root['branchId'] is String &&
          (root['branchId'] as String).isNotEmpty) {
        explicitBranchId = root['branchId'] as String;
      }
    }

    if (branch == null &&
        explicitBranchId != null &&
        explicitBranchId.isNotEmpty) {
      branch = BranchModel(
        id: explicitBranchId,
        name: (root['branchName'] ?? 'Salon Branch').toString(),
        address: (root['branchAddress'] ?? '').toString(),
        phone: (root['branchPhone'] ?? '').toString(),
      );
    }

    final rawDate = root['scheduledDate'] ?? root['date'];
    final parsedDate = rawDate is String
        ? DateTime.tryParse(rawDate) ?? DateTime.now()
        : DateTime.now();

    final rawTimeSlot = root['timeSlot'];
    final timeSlotJson = asMap(rawTimeSlot);

    final timeValue = rawTimeSlot is String
        ? rawTimeSlot
        : (timeSlotJson['timeSlot'] ?? timeSlotJson['startTime'] ?? '09:00')
              .toString();

    final endTimeValue = (timeSlotJson['endTime'] ?? timeValue).toString();

    final rawTotal =
        root['finalAmount'] ??
        root['total'] ??
        root['totalAmount'] ??
        asMap(root['pricing'])['totalAmount'];

    final total = rawTotal is num
        ? rawTotal.toDouble()
        : double.tryParse(rawTotal?.toString() ?? '') ??
              (servicePrice > 0 ? servicePrice : 0.0);

    final int? durationMinutes = (root['duration'] is num)
        ? (root['duration'] as num).toInt()
        : (root['totalDuration'] is num)
        ? (root['totalDuration'] as num).toInt()
        : serviceDurationMinutes;

    final service = ServiceModel(
      id: serviceId,
      categoryId: serviceCategory,
      name: serviceName,
      description: serviceDescription,
      startingPrice: servicePrice > 0 ? servicePrice : total,
      duration: durationMinutes != null ? '$durationMinutes mins' : '45 mins',
    );

    final dateModel = ServiceDateModel(date: parsedDate);

    final timeSlotModel = TimeSlotModel(
      id: timeValue,
      startTime: timeValue,
      endTime: endTimeValue,
    );

    final rawPayment =
        root['paymentMethod'] ??
        root['payment_method'] ??
        root['payment'] ??
        root['paymentDetails'];

    final paymentMethod = PaymentMethodModel.fromDynamic(rawPayment);

    final rawPaymentStatus =
        (root['paymentStatus'] ??
                root['payment_status'] ??
                (root['payment'] is Map
                    ? (root['payment'] as Map)['status']
                    : null) ??
                (root['paymentDetails'] is Map
                    ? (root['paymentDetails'] as Map)['status']
                    : null) ??
                'pending')
            .toString()
            .trim();

    final paymentStatus = rawPaymentStatus.isNotEmpty
        ? rawPaymentStatus
        : 'pending';

    final pricingJson = asMap(root['pricing']);

    final discount = (pricingJson['discount'] as num?)?.toDouble() ?? 0.0;
    final taxAmount = (pricingJson['taxAmount'] as num?)?.toDouble() ?? 0.0;

    final pricing = PricingBreakdown(
      packagePrice:
          (pricingJson['packagePrice'] as num?)?.toDouble() ??
          (total - taxAmount + discount),
      discount: discount,
      taxRate: (pricingJson['taxRate'] as num?)?.toDouble() ?? 0.0,
      taxAmount: taxAmount,
      totalAmount: total,
    );

    final addressJson = asMap(root['address']);

    final address = addressJson.isNotEmpty
        ? AddressModel.fromJson(addressJson)
        : AddressModel(
            id: 'branch_loc',
            userId: 'salon',
            label: 'Salon Branch',
            houseNumber: '',
            addressLine: (branch?.name ?? root['branchName'] ?? 'Salon Branch')
                .toString(),
            city: (branch?.city ?? root['city'] ?? '').toString(),
            state: '',
            pincode: '',
          );

    return BookingModel(
      id: (root['_id'] ?? root['id'] ?? '').toString(),
      bookingReference:
          (root['appointmentCode'] ?? root['bookingReference'] ?? '')
              .toString(),
      status: BookingStatus.fromString(
        (root['status'] ?? 'pending').toString(),
      ),
      service: service,
      package: const ServicePackageModel(
        id: '',
        serviceId: '',
        name: 'Standard',
        description: '',
        price: 0,
        duration: '45 mins',
        features: [],
      ),
      address: address,
      branch: branch,
      scheduledDate: dateModel,
      timeSlot: timeSlotModel,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus,
      pricing: pricing,
      createdAt:
          DateTime.tryParse((root['createdAt'] ?? '').toString()) ??
          DateTime.now(),
      cancellationReason: root['cancellationReason']?.toString(),
      cancellationNote: root['cancellationNote']?.toString(),
      cancelledAt: DateTime.tryParse((root['cancelledAt'] ?? '').toString()),
      rescheduledAt: DateTime.tryParse(
        (root['rescheduledAt'] ?? '').toString(),
      ),
      durationMinutes: durationMinutes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingReference': bookingReference,
      'status': status.toFormattedString(),
      'service': service.toJson(),
      'package': package.toJson(),
      'address': address.toJson(),
      if (branch != null) 'branch': branch!.toJson(),
      'scheduledDate': scheduledDate.toJson(),
      'timeSlot': timeSlot,
      'paymentMethod': paymentMethod.toJson(),
      'paymentStatus': paymentStatus,
      'pricing': pricing.toJson(),
      'createdAt': createdAt.toIso8601String(),
      if (cancellationReason != null) 'cancellationReason': cancellationReason,
      if (cancellationNote != null) 'cancellationNote': cancellationNote,
      if (cancelledAt != null) 'cancelledAt': cancelledAt!.toIso8601String(),
      if (rescheduledAt != null)
        'rescheduledAt': rescheduledAt!.toIso8601String(),
      if (durationMinutes != null) 'duration': durationMinutes,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookingModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          bookingReference == other.bookingReference &&
          status == other.status &&
          service == other.service &&
          package == other.package &&
          branch == other.branch &&
          address == other.address &&
          scheduledDate == other.scheduledDate &&
          timeSlot == other.timeSlot &&
          paymentMethod == other.paymentMethod &&
          pricing == other.pricing &&
          createdAt == other.createdAt &&
          cancellationReason == other.cancellationReason &&
          cancellationNote == other.cancellationNote &&
          cancelledAt == other.cancelledAt &&
          rescheduledAt == other.rescheduledAt &&
          durationMinutes == other.durationMinutes;

  @override
  int get hashCode =>
      id.hashCode ^
      bookingReference.hashCode ^
      status.hashCode ^
      service.hashCode ^
      package.hashCode ^
      (branch?.hashCode ?? 0) ^
      address.hashCode ^
      scheduledDate.hashCode ^
      timeSlot.hashCode ^
      paymentMethod.hashCode ^
      pricing.hashCode ^
      createdAt.hashCode ^
      (cancellationReason?.hashCode ?? 0) ^
      (cancellationNote?.hashCode ?? 0) ^
      (cancelledAt?.hashCode ?? 0) ^
      (rescheduledAt?.hashCode ?? 0) ^
      (durationMinutes?.hashCode ?? 0);
}
