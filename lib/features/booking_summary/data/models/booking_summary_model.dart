import 'package:prop_crm/features/addresses/data/models/address_model.dart';
import 'package:prop_crm/features/branches/data/models/branch_model.dart';
import 'package:prop_crm/features/date_time/data/models/service_date_model.dart';
import 'package:prop_crm/features/date_time/data/models/time_slot_model.dart';
import 'package:prop_crm/features/offers/data/models/coupon_model.dart';
import 'package:prop_crm/features/services/data/models/service_model.dart';
import 'package:prop_crm/features/services/data/models/service_package_model.dart';
import 'pricing_breakdown_model.dart';

class BookingSummaryModel {
  final ServiceModel service;
  final ServicePackageModel package;
  final AddressModel address;
  final BranchModel? branch;
  final ServiceDateModel scheduledDate;
  final TimeSlotModel timeSlot;
  final PricingBreakdown pricing;
  final CouponModel? appliedCoupon;
  final String? specialInstructions;

  const BookingSummaryModel({
    required this.service,
    required this.package,
    required this.address,
    this.branch,
    required this.scheduledDate,
    required this.timeSlot,
    required this.pricing,
    this.appliedCoupon,
    this.specialInstructions,
  });

  /// Validates that all required booking summary items are complete and sound
  bool get isValid =>
      service.id.isNotEmpty &&
      package.id.isNotEmpty &&
      (branch != null || address.id.isNotEmpty) &&
      timeSlot.id.isNotEmpty &&
      scheduledDate.isAvailable &&
      timeSlot.isAvailable &&
      pricing.totalAmount > 0;

  /// Helper for schedule summary display: "Saturday, 26 September • 10:00 AM - 11:00 AM"
  String get formattedSchedule =>
      '${scheduledDate.dayName}, ${scheduledDate.dayNumber} ${scheduledDate.monthName} • ${timeSlot.formattedLabel}';

  BookingSummaryModel copyWith({
    ServiceModel? service,
    ServicePackageModel? package,
    AddressModel? address,
    BranchModel? branch,
    ServiceDateModel? scheduledDate,
    TimeSlotModel? timeSlot,
    PricingBreakdown? pricing,
    CouponModel? appliedCoupon,
    String? specialInstructions,
  }) {
    return BookingSummaryModel(
      service: service ?? this.service,
      package: package ?? this.package,
      address: address ?? this.address,
      branch: branch ?? this.branch,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      timeSlot: timeSlot ?? this.timeSlot,
      pricing: pricing ?? this.pricing,
      appliedCoupon: appliedCoupon ?? this.appliedCoupon,
      specialInstructions: specialInstructions ?? this.specialInstructions,
    );
  }

  factory BookingSummaryModel.fromJson(Map<String, dynamic> json) {
    return BookingSummaryModel(
      service: ServiceModel.fromJson(json['service'] as Map<String, dynamic>),
      package: ServicePackageModel.fromJson(
          json['package'] as Map<String, dynamic>),
      address: json['address'] != null
          ? AddressModel.fromJson(json['address'] as Map<String, dynamic>)
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
          ? BranchModel.fromJson(json['branch'] as Map<String, dynamic>)
          : null,
      scheduledDate: ServiceDateModel.fromJson(
          json['scheduledDate'] as Map<String, dynamic>),
      timeSlot:
          TimeSlotModel.fromJson(json['timeSlot'] as Map<String, dynamic>),
      pricing: PricingBreakdown.fromJson(
          json['pricing'] as Map<String, dynamic>),
      appliedCoupon: json['appliedCoupon'] != null
          ? CouponModel.fromJson(json['appliedCoupon'] as Map<String, dynamic>)
          : null,
      specialInstructions: json['specialInstructions'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'service': service.toJson(),
      'package': package.toJson(),
      'address': address.toJson(),
      if (branch != null) 'branch': branch!.toJson(),
      'scheduledDate': scheduledDate.toJson(),
      'timeSlot': timeSlot.toJson(),
      'pricing': pricing.toJson(),
      if (appliedCoupon != null) 'appliedCoupon': appliedCoupon!.toJson(),
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
          pricing == other.pricing;

  @override
  int get hashCode =>
      service.hashCode ^
      package.hashCode ^
      (branch?.hashCode ?? 0) ^
      address.hashCode ^
      scheduledDate.hashCode ^
      timeSlot.hashCode ^
      pricing.hashCode;
}
