import 'package:flutter_test/flutter_test.dart';
import 'package:prop_crm/features/addresses/data/models/address_model.dart';
import 'package:prop_crm/features/booking_summary/data/datasources/booking_summary_remote_data_source.dart';
import 'package:prop_crm/features/booking_summary/data/models/booking_summary_model.dart';
import 'package:prop_crm/features/booking_summary/data/repositories/booking_summary_repository_impl.dart';
import 'package:prop_crm/features/booking_summary/domain/repositories/booking_summary_repository.dart';
import 'package:prop_crm/features/booking_summary/presentation/providers/booking_summary_provider.dart';
import 'package:prop_crm/features/date_time/data/models/service_date_model.dart';
import 'package:prop_crm/features/date_time/data/models/time_slot_model.dart';
import 'package:prop_crm/features/services/data/models/service_model.dart';
import 'package:prop_crm/features/services/data/models/service_package_model.dart';

class FailingBookingSummaryRepository implements BookingSummaryRepository {
  @override
  Future<BookingSummaryModel> getBookingSummary({
    required ServiceModel service,
    required ServicePackageModel package,
    required AddressModel address,
    required ServiceDateModel date,
    required TimeSlotModel timeSlot,
    double discount = 0.0,
    double taxRate = 0.18,
  }) async {
    throw Exception('Failed to calculate summary');
  }
}

void main() {
  late MockBookingSummaryRemoteDataSource dataSource;
  late BookingSummaryRepositoryImpl repository;
  late BookingSummaryProvider provider;

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
    provider = BookingSummaryProvider(repository: repository);
  });

  group('BookingSummaryProvider State Management Tests', () {
    test('loadSummary populates summary and calculates pricing', () async {
      expect(provider.summaryState.isInitial, isTrue);
      expect(provider.isValid, isFalse);

      await provider.loadSummary(
        service: service,
        package: package,
        address: address,
        date: scheduledDate,
        timeSlot: timeSlot,
        discount: 100.0,
      );

      expect(provider.summaryState.isSuccess, isTrue);
      expect(provider.isValid, isTrue);
      expect(provider.service?.id, 'srv_1');
      expect(provider.package?.id, 'pkg_1');
      expect(provider.address?.id, 'addr_1');
      expect(provider.scheduledDate?.dateKey, scheduledDate.dateKey);
      expect(provider.timeSlot?.id, 'slot_1');
      expect(provider.pricing?.totalAmount, 1061.0);
    });

    test('updateAddress updates address in summary preserving other details',
        () async {
      await provider.loadSummary(
        service: service,
        package: package,
        address: address,
        date: scheduledDate,
        timeSlot: timeSlot,
      );

      const newAddress = AddressModel(
        id: 'addr_work',
        userId: 'user_1',
        label: 'Work',
        houseNumber: 'Office 402',
        addressLine: 'World Trade Park, JLN Marg',
        city: 'Jaipur',
        state: 'Rajasthan',
        pincode: '302017',
      );

      provider.updateAddress(newAddress);

      expect(provider.address?.id, 'addr_work');
      expect(provider.address?.label, 'Work');
      expect(provider.service?.id, 'srv_1');
      expect(provider.package?.id, 'pkg_1');
    });

    test('updateSchedule updates scheduled date and time slot in summary',
        () async {
      await provider.loadSummary(
        service: service,
        package: package,
        address: address,
        date: scheduledDate,
        timeSlot: timeSlot,
      );

      final newDate = ServiceDateModel(
        date: DateTime(2026, 9, 28),
        isAvailable: true,
      );
      const newSlot = TimeSlotModel(
        id: 'slot_afternoon',
        startTime: '02:00 PM',
        endTime: '03:00 PM',
        isAvailable: true,
      );

      provider.updateSchedule(newDate, newSlot);

      expect(provider.scheduledDate?.dateKey, '2026-09-28');
      expect(provider.timeSlot?.id, 'slot_afternoon');
      expect(provider.timeSlot?.startTime, '02:00 PM');
    });

    test('updatePackage recalculates pricing for new package', () async {
      await provider.loadSummary(
        service: service,
        package: package,
        address: address,
        date: scheduledDate,
        timeSlot: timeSlot,
      );

      const upgradedPackage = ServicePackageModel(
        id: 'pkg_villa',
        serviceId: 'srv_1',
        name: 'Villa Package',
        description: 'Complete villa deep clean',
        price: 1999.0,
        duration: '4 hrs',
        features: ['Full villa', 'Terrace'],
      );

      await provider.updatePackage(upgradedPackage);

      expect(provider.package?.id, 'pkg_villa');
      expect(provider.pricing?.packagePrice, 1999.0);
      // 18% of 1999 = 359.82 -> rounds to 360
      expect(provider.pricing?.taxAmount, 360.0);
      // Total = 1999 + 360 = 2359
      expect(provider.pricing?.totalAmount, 2359.0);
    });

    test('clear resets provider state to initial', () async {
      await provider.loadSummary(
        service: service,
        package: package,
        address: address,
        date: scheduledDate,
        timeSlot: timeSlot,
      );
      expect(provider.isValid, isTrue);

      provider.clear();
      expect(provider.summaryState.isInitial, isTrue);
      expect(provider.summary, isNull);
      expect(provider.isValid, isFalse);
    });

    test('Error handling in loadSummary sets error state', () async {
      final failingRepo = FailingBookingSummaryRepository();
      final failingProvider = BookingSummaryProvider(repository: failingRepo);

      await failingProvider.loadSummary(
        service: service,
        package: package,
        address: address,
        date: scheduledDate,
        timeSlot: timeSlot,
      );

      expect(failingProvider.summaryState.isError, isTrue);
      expect(failingProvider.hasError, isTrue);
      expect(failingProvider.errorMessage, isNotNull);
    });
  });
}
