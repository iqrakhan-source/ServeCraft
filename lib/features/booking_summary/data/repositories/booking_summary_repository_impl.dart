import 'package:prop_crm/features/addresses/data/models/address_model.dart';
import 'package:prop_crm/features/date_time/data/models/service_date_model.dart';
import 'package:prop_crm/features/date_time/data/models/time_slot_model.dart';
import 'package:prop_crm/features/services/data/models/service_model.dart';
import 'package:prop_crm/features/services/data/models/service_package_model.dart';
import '../../domain/repositories/booking_summary_repository.dart';
import '../datasources/booking_summary_remote_data_source.dart';
import '../models/booking_summary_model.dart';
import '../models/pricing_breakdown_model.dart';

class BookingSummaryRepositoryImpl implements BookingSummaryRepository {
  final BookingSummaryRemoteDataSource remoteDataSource;

  BookingSummaryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<BookingSummaryModel> getBookingSummary({
    required ServiceModel service,
    required ServicePackageModel package,
    required AddressModel address,
    required ServiceDateModel date,
    required TimeSlotModel timeSlot,
    double discount = 0.0,
    double taxRate = PricingBreakdown.defaultTaxRate,
  }) async {
    return await remoteDataSource.calculateSummary(
      service: service,
      package: package,
      address: address,
      date: date,
      timeSlot: timeSlot,
      discount: discount,
      taxRate: taxRate,
    );
  }
}
