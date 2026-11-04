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
  final PricingBreakdown pricing;
  final DateTime createdAt;
  final String? cancellationReason;
  final String? cancellationNote;
  final DateTime? cancelledAt;
  final DateTime? rescheduledAt;


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
    required this.pricing,
    required this.createdAt,
    this.cancellationReason,
    this.cancellationNote,
    this.cancelledAt,
    this.rescheduledAt,
  });

  /// Formatted booking reference (e.g. GLM-2026-000001)
  String get formattedBookingReference => bookingReference;

  /// Helper for schedule summary display: "Saturday, 26 September • 10:00 AM - 11:00 AM"
  String get formattedSchedule =>
      '${scheduledDate.dayName}, ${scheduledDate.dayNumber} ${scheduledDate.monthName} • ${timeSlot.formattedLabel}';

  /// Formatted final total amount (e.g. ₹1,061)
  String get formattedTotal => AppFormatters.formatCurrency(pricing.totalAmount);

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
    if (status == BookingStatus.cancelled || status == BookingStatus.completed) {
      return false;
    }
    return !isWithin2HoursOfAppointment;
  }

  /// Salon Business Rule: Rescheduling allowed ONLY up to 2 hours before appointment
  bool get isReschedulable {
    if (status == BookingStatus.cancelled || status == BookingStatus.completed) {
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
    PricingBreakdown? pricing,
    DateTime? createdAt,
    String? cancellationReason,
    String? cancellationNote,
    DateTime? cancelledAt,
    DateTime? rescheduledAt,
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
      pricing: pricing ?? this.pricing,
      createdAt: createdAt ?? this.createdAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      cancellationNote: cancellationNote ?? this.cancellationNote,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      rescheduledAt: rescheduledAt ?? this.rescheduledAt,
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

    final services = json['services'] is List
        ? json['services'] as List
        : <dynamic>[];

    final firstService = services.isNotEmpty
        ? asMap(services.first)
        : <String, dynamic>{};

    final branchJson = asMap(json['branch']);

    final rawDate = json['scheduledDate'] ?? json['date'];
    final parsedDate = rawDate is String
        ? DateTime.tryParse(rawDate) ?? DateTime.now()
        : DateTime.now();

    final rawTimeSlot = json['timeSlot'];
    final timeSlotJson = asMap(rawTimeSlot);

    final timeValue = rawTimeSlot is String
        ? rawTimeSlot
        : (timeSlotJson['timeSlot'] ??
        timeSlotJson['startTime'] ??
        '09:00')
        .toString();

    final rawTotal = json['total'] ??
        json['totalAmount'] ??
        asMap(json['pricing'])['totalAmount'];

    final total = rawTotal is num
        ? rawTotal.toDouble()
        : double.tryParse(rawTotal?.toString() ?? '') ?? 0.0;

    final service = ServiceModel(
      id: (firstService['_id'] ?? firstService['id'] ?? '').toString(),
      categoryId: (firstService['categoryId'] ?? '').toString(),
      name: (firstService['name'] ?? 'Salon Service').toString(),
      description: (firstService['description'] ?? '').toString(),
      startingPrice: ((firstService['price'] ?? total) as num).toDouble(),
      duration: '${firstService['duration'] ?? 45} mins',
    );

    final dateModel = ServiceDateModel(
      date: parsedDate,
    );

    final timeSlotModel = TimeSlotModel(
      id: timeValue,
      startTime: timeValue,
      endTime: timeValue,
    );

    final paymentJson = asMap(json['paymentMethod']);

    final paymentMethod = PaymentMethodModel(
      id: (paymentJson['id'] ?? '').toString(),
      title: (paymentJson['title'] ?? 'Payment').toString(),
      subtitle: (paymentJson['subtitle'] ?? '').toString(),
      type: PaymentMethodType.fromString(
        (paymentJson['type'] ?? 'upi').toString(),
      ),
    );

    final pricingJson = asMap(json['pricing']);

    final discount = (pricingJson['discount'] as num?)?.toDouble() ?? 0.0;
    final taxAmount = (pricingJson['taxAmount'] as num?)?.toDouble() ?? 0.0;

    final pricing = PricingBreakdown(
      packagePrice: (pricingJson['packagePrice'] as num?)?.toDouble() ??
          (total - taxAmount + discount),
      discount: discount,
      taxRate: (pricingJson['taxRate'] as num?)?.toDouble() ?? 0.18,
      taxAmount: taxAmount,
      totalAmount: total,
    );

    final addressJson = asMap(json['address']);

    final address = addressJson.isNotEmpty
        ? AddressModel.fromJson(addressJson)
        : AddressModel(
      id: 'branch_loc',
      userId: 'salon',
      label: 'Salon Branch',
      houseNumber: '',
      addressLine: (branchJson['name'] ?? 'Salon Branch').toString(),
      city: (branchJson['city'] ?? '').toString(),
      state: '',
      pincode: '',
    );

    return BookingModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      bookingReference:
      (json['appointmentCode'] ?? json['bookingReference'] ?? '').toString(),
      status: BookingStatus.fromString(
        (json['status'] ?? 'pending').toString(),
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
      branch: branchJson.isNotEmpty
          ? BranchModel.fromJson(branchJson)
          : null,
      scheduledDate: dateModel,
      timeSlot: timeSlotModel,
      paymentMethod: paymentMethod,
      pricing: pricing,
      createdAt: DateTime.tryParse(
        (json['createdAt'] ?? '').toString(),
      ) ??
          DateTime.now(),
      cancellationReason: json['cancellationReason']?.toString(),
      cancellationNote: json['cancellationNote']?.toString(),
      cancelledAt: DateTime.tryParse(
        (json['cancelledAt'] ?? '').toString(),
      ),
      rescheduledAt: DateTime.tryParse(
        (json['rescheduledAt'] ?? '').toString(),
      ),
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
      'pricing': pricing.toJson(),
      'createdAt': createdAt.toIso8601String(),
      if (cancellationReason != null) 'cancellationReason': cancellationReason,
      if (cancellationNote != null) 'cancellationNote': cancellationNote,
      if (cancelledAt != null) 'cancelledAt': cancelledAt!.toIso8601String(),
      if (rescheduledAt != null) 'rescheduledAt': rescheduledAt!.toIso8601String(),
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
          rescheduledAt == other.rescheduledAt;

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
      (rescheduledAt?.hashCode ?? 0);
}
