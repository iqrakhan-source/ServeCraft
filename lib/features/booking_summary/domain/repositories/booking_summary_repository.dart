import 'package:prop_crm/features/addresses/data/models/address_model.dart';
import 'package:prop_crm/features/date_time/data/models/service_date_model.dart';
import 'package:prop_crm/features/date_time/data/models/time_slot_model.dart';
import 'package:prop_crm/features/services/data/models/service_model.dart';
import 'package:prop_crm/features/services/data/models/service_package_model.dart';
import '../../data/models/booking_summary_model.dart';
import '../../data/models/pricing_breakdown_model.dart';

abstract class BookingSummaryRepository {
  Future<BookingSummaryModel> getBookingSummary({
    required ServiceModel service,
    required ServicePackageModel package,
    required AddressModel address,
    required ServiceDateModel date,
    required TimeSlotModel timeSlot,
    double discount = 0.0,
    double taxRate = PricingBreakdown.defaultTaxRate,
  });
}
