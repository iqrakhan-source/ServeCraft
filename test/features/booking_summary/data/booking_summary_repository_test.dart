import 'package:flutter_test/flutter_test.dart';
import 'package:prop_crm/features/addresses/data/models/address_model.dart';
import 'package:prop_crm/features/booking_summary/data/datasources/booking_summary_remote_data_source.dart';
import 'package:prop_crm/features/booking_summary/data/repositories/booking_summary_repository_impl.dart';
import 'package:prop_crm/features/date_time/data/models/service_date_model.dart';
import 'package:prop_crm/features/date_time/data/models/time_slot_model.dart';
import 'package:prop_crm/features/services/data/models/service_model.dart';
import 'package:prop_crm/features/services/data/models/service_package_model.dart';

void main() {
  late MockBookingSummaryRemoteDataSource dataSource;
  late BookingSummaryRepositoryImpl repository;

  const service = ServiceModel(
    id: 'srv_1',
    categoryId: 'cat_1',
    name: 'Full Home Deep Clean',
    description: 'Deep house cleaning',
    startingPrice: 999.0,
  );

  const package = ServicePackageModel(
    id: 'pkg_1',
    serviceId: 'srv_1',
    name: 'Premium 3BHK',
    description: '3BHK complete',
    price: 999.0,
    duration: '2 hrs',
    features: ['Deep wash', 'Dusting'],
  );

  const address = AddressModel(
    id: 'addr_1',
    userId: 'user_1',
    label: 'Home',
    houseNumber: 'Flat 302',
    addressLine: 'Royal Palms, Vaishali Nagar',
    city: 'Jaipur',
    state: 'Rajasthan',
    pincode: '302021',
  );

  final scheduledDate = ServiceDateModel(
    date: DateTime(2026, 9, 26),
    isAvailable: true,
  );

  const timeSlot = TimeSlotModel(
    id: 'slot_1',
    startTime: '10:00 AM',
    endTime: '11:00 AM',
    isAvailable: true,
  );

  setUp(() {
    dataSource = MockBookingSummaryRemoteDataSource();
    repository = BookingSummaryRepositoryImpl(remoteDataSource: dataSource);
  });

  group('BookingSummaryRepository Tests', () {
    test('getBookingSummary computes pricing and returns valid summary',
        () async {
      final summary = await repository.getBookingSummary(
        service: service,
        package: package,
        address: address,
        date: scheduledDate,
        timeSlot: timeSlot,
        discount: 100.0,
      );

      expect(summary.isValid, isTrue);
      expect(summary.service.id, 'srv_1');
      expect(summary.package.id, 'pkg_1');
      expect(summary.address.id, 'addr_1');
      expect(summary.pricing.packagePrice, 999.0);
      expect(summary.pricing.discount, 100.0);
      expect(summary.pricing.taxAmount, 162.0);
      expect(summary.pricing.totalAmount, 1061.0);
    });

    test('getBookingSummary without discount computes 18% tax correctly',
        () async {
      final summary = await repository.getBookingSummary(
        service: service,
        package: package,
        address: address,
        date: scheduledDate,
        timeSlot: timeSlot,
        discount: 0.0,
      );

      expect(summary.pricing.discount, 0.0);
      expect(summary.pricing.taxAmount, 180.0);
      expect(summary.pricing.totalAmount, 1179.0);
    });
  });
}
