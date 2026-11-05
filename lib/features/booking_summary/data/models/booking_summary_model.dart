
import 'package:prop_crm/features/addresses/data/models/address_model.dart';
import 'package:prop_crm/features/branches/data/models/branch_model.dart';
import 'package:prop_crm/features/date_time/data/models/service_date_model.dart';
import 'package:prop_crm/features/date_time/data/models/time_slot_model.dart';
import 'package:prop_crm/features/offers/model/models/coupon_model.dart';
import 'package:prop_crm/features/services/data/models/service_model.dart';
import 'package:prop_crm/features/services/data/models/service_package_model.dart';

import 'pricing_breakdown_model.dart';

class BookingSummaryModel {
  final ServiceModel service;
  final ServicePackageModel? package;
  final AddressModel address;
  final BranchModel? branch;
  final ServiceDateModel scheduledDate;
  final TimeSlotModel timeSlot;
  final PricingBreakdown pricing;
  final CouponModel? appliedCoupon;
  final String? specialInstructions;

  const BookingSummaryModel({
    required this.service,
    this.package,
    required this.address,
    this.branch,
    required this.scheduledDate,
    required this.timeSlot,
    required this.pricing,
    this.appliedCoupon,
    this.specialInstructions,
  });

  // Package and address are optional.
  // Service, branch, date, time slot and valid pricing are required.
  bool get isValid =>
      service.id.trim().isNotEmpty &&
          branch != null &&
          branch!.id.trim().isNotEmpty &&
          timeSlot.id.trim().isNotEmpty &&
          scheduledDate.isAvailable &&
          timeSlot.isAvailable &&
          pricing.totalAmount > 0;

  // Formatted appointment schedule
  String get formattedSchedule =>
      '${scheduledDate.dayName}, ${scheduledDate.dayNumber} '
          '${scheduledDate.monthName} • ${timeSlot.formattedLabel}';

  BookingSummaryModel copyWith({
    ServiceModel? service,
    ServicePackageModel? package,
    bool clearPackage = false,
    AddressModel? address,
    BranchModel? branch,
    bool clearBranch = false,
    ServiceDateModel? scheduledDate,
    TimeSlotModel? timeSlot,
    PricingBreakdown? pricing,
    CouponModel? appliedCoupon,
    bool clearAppliedCoupon = false,
    String? specialInstructions,
    bool clearSpecialInstructions = false,
  }) {
    return BookingSummaryModel(
      service: service ?? this.service,
      package: clearPackage ? null : (package ?? this.package),
      address: address ?? this.address,
      branch: clearBranch ? null : (branch ?? this.branch),
      scheduledDate: scheduledDate ?? this.scheduledDate,
      timeSlot: timeSlot ?? this.timeSlot,
      pricing: pricing ?? this.pricing,
      appliedCoupon: clearAppliedCoupon
          ? null
          : (appliedCoupon ?? this.appliedCoupon),
      specialInstructions: clearSpecialInstructions
          ? null
          : (specialInstructions ?? this.specialInstructions),
    );
  }

  factory BookingSummaryModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return BookingSummaryModel(
      service: ServiceModel.fromJson(
        json['service'] as Map<String, dynamic>,
      ),

      package: json['package'] != null
          ? ServicePackageModel.fromJson(
        json['package'] as Map<String, dynamic>,
      )
          : null,

      address: json['address'] != null
          ? AddressModel.fromJson(
        json['address'] as Map<String, dynamic>,
      )
          : const AddressModel(
        id: 'branch_loc',
        userId: 'salon',
        label: 'Salon Branch',
        houseNumber: '',
        addressLine: 'Salon Branch Location',
        city: '',
        state: '',
        pincode: '',
      ),

      branch: json['branch'] != null
          ? BranchModel.fromJson(
        json['branch'] as Map<String, dynamic>,
      )
          : null,

      scheduledDate: ServiceDateModel.fromJson(
        json['scheduledDate'] as Map<String, dynamic>,
      ),

      timeSlot: TimeSlotModel.fromJson(
        json['timeSlot'] as Map<String, dynamic>,
      ),

      pricing: PricingBreakdown.fromJson(
        json['pricing'] as Map<String, dynamic>,
      ),

      appliedCoupon: json['appliedCoupon'] != null
          ? CouponModel.fromJson(
        json['appliedCoupon'] as Map<String, dynamic>,
      )
          : null,

      specialInstructions:
      json['specialInstructions'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'service': service.toJson(),

      if (package != null)
        'package': package!.toJson(),

      'address': address.toJson(),

      if (branch != null)
        'branch': branch!.toJson(),

      'scheduledDate': scheduledDate.toJson(),
      'timeSlot': timeSlot.toJson(),
      'pricing': pricing.toJson(),

      if (appliedCoupon != null)
        'appliedCoupon': appliedCoupon!.toJson(),

      if (specialInstructions != null)
        'specialInstructions': specialInstructions,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is BookingSummaryModel &&
              runtimeType == other.runtimeType &&
              service == other.service &&
              package == other.package &&
              branch == other.branch &&
              address == other.address &&
              scheduledDate == other.scheduledDate &&
              timeSlot == other.timeSlot &&
              pricing == other.pricing &&
              appliedCoupon == other.appliedCoupon &&
              specialInstructions == other.specialInstructions;

  @override
  int get hashCode => Object.hash(
    service,
    package,
    branch,
    address,
    scheduledDate,
    timeSlot,
    pricing,
    appliedCoupon,
    specialInstructions,
  );
}
