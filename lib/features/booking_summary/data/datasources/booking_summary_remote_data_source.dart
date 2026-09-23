import 'package:prop_crm/core/constants/api_constants.dart';
import 'package:prop_crm/core/networking/api_service.dart';
import 'package:prop_crm/features/addresses/data/models/address_model.dart';
import 'package:prop_crm/features/date_time/data/models/service_date_model.dart';
import 'package:prop_crm/features/date_time/data/models/time_slot_model.dart';
import 'package:prop_crm/features/services/data/models/service_model.dart';
import 'package:prop_crm/features/services/data/models/service_package_model.dart';
import '../models/booking_summary_model.dart';
import '../models/pricing_breakdown_model.dart';

abstract class BookingSummaryRemoteDataSource {
  Future<BookingSummaryModel> calculateSummary({
    required ServiceModel service,
    required ServicePackageModel package,
    required AddressModel address,
    required ServiceDateModel date,
    required TimeSlotModel timeSlot,
    double discount = 0.0,
    double taxRate = PricingBreakdown.defaultTaxRate,
  });
}

class BookingSummaryRemoteDataSourceImpl
    implements BookingSummaryRemoteDataSource {
  final ApiService apiService;

  BookingSummaryRemoteDataSourceImpl({required this.apiService});

  @override
  Future<BookingSummaryModel> calculateSummary({
    required ServiceModel service,
    required ServicePackageModel package,
    required AddressModel address,
    required ServiceDateModel date,
    required TimeSlotModel timeSlot,
    double discount = 0.0,
    double taxRate = PricingBreakdown.defaultTaxRate,
  }) async {
    final response = await apiService.post(
      ApiConstants.bookingSummary,
      data: {
        'serviceId': service.id,
        'packageId': package.id,
        'addressId': address.id,
        'scheduledDate': date.dateKey,
        'timeSlotId': timeSlot.id,
        'discount': discount,
      },
    );

    final data = response.data as Map<String, dynamic>;
    return BookingSummaryModel.fromJson(data);
  }
}

class MockBookingSummaryRemoteDataSource
    implements BookingSummaryRemoteDataSource {
  @override
  Future<BookingSummaryModel> calculateSummary({
    required ServiceModel service,
    required ServicePackageModel package,
    required AddressModel address,
    required ServiceDateModel date,
    required TimeSlotModel timeSlot,
    double discount = 0.0,
    double taxRate = PricingBreakdown.defaultTaxRate,
  }) async {
    // Simulate brief network latency
    await Future.delayed(const Duration(milliseconds: 150));

    final pricing = PricingBreakdown.calculate(
      packagePrice: package.price,
      discount: discount,
      taxRate: taxRate,
    );

    return BookingSummaryModel(
      service: service,
      package: package,
      address: address,
      scheduledDate: date,
      timeSlot: timeSlot,
      pricing: pricing,
    );
  }
}
