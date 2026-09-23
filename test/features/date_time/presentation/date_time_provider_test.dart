import 'package:flutter_test/flutter_test.dart';
import 'package:prop_crm/features/date_time/data/datasources/date_time_remote_data_source.dart';
import 'package:prop_crm/features/date_time/data/models/service_date_model.dart';
import 'package:prop_crm/features/date_time/data/models/time_slot_model.dart';
import 'package:prop_crm/features/date_time/data/repositories/date_time_repository_impl.dart';
import 'package:prop_crm/features/date_time/domain/repositories/date_time_repository.dart';
import 'package:prop_crm/features/date_time/presentation/providers/date_time_provider.dart';

class FailingDateTimeRepository implements DateTimeRepository {
  @override
  Future<List<ServiceDateModel>> getAvailableDates({
    required String serviceId,
    String? packageId,
  }) async {
    throw Exception('Failed to fetch dates');
  }

  @override
  Future<List<TimeSlotModel>> getTimeSlots({
    required String serviceId,
    required DateTime date,
    String? packageId,
  }) async {
    throw Exception('Failed to fetch slots');
  }
}

void main() {
  late MockDateTimeRemoteDataSource dataSource;
  late DateTimeRepositoryImpl repository;
  late DateTimeProvider provider;

  setUp(() {
    dataSource = MockDateTimeRemoteDataSource();
    repository = DateTimeRepositoryImpl(remoteDataSource: dataSource);
    provider = DateTimeProvider(repository: repository);
  });

  group('DateTimeProvider State Management Tests', () {
    test('initContext updates service and package details', () {
      provider.initContext(
        serviceId: 'srv_deep_clean',
        serviceName: 'Full Home Deep Clean',
        packageId: 'pkg_premium',
        packageName: 'Premium 3BHK',
      );

      expect(provider.serviceId, 'srv_deep_clean');
      expect(provider.serviceName, 'Full Home Deep Clean');
      expect(provider.packageId, 'pkg_premium');
      expect(provider.packageName, 'Premium 3BHK');
    });

    test('loadAvailableDates populates dates and auto-selects first available date',
        () async {
      expect(provider.datesState.isInitial, isTrue);

      await provider.loadAvailableDates(
        serviceId: 'srv_1',
        packageId: 'pkg_1',
      );

      expect(provider.datesState.isSuccess, isTrue);
      expect(provider.availableDates.length, 14);
      expect(provider.selectedDate, isNotNull);
      expect(provider.selectedDate!.isAvailable, isTrue);
      expect(provider.slotsState.isSuccess, isTrue);
      expect(provider.timeSlots.isNotEmpty, isTrue);
      expect(provider.isSelectionComplete, isFalse); // Slot not selected yet
    });

    test('selectDate updates selectedDate and resets previous slot selection',
        () async {
      await provider.loadAvailableDates(serviceId: 'srv_1');

      // Select an available slot on the first date
      final firstAvailableSlot =
          provider.timeSlots.firstWhere((s) => s.isAvailable);
      provider.selectTimeSlot(firstAvailableSlot);
      expect(provider.selectedTimeSlot, equals(firstAvailableSlot));
      expect(provider.isSelectionComplete, isTrue);

      // Select a different available date (e.g. index 1)
      final secondDate = provider.availableDates[1];
      await provider.selectDate(secondDate);

      expect(provider.selectedDate?.dateKey, secondDate.dateKey);
      expect(provider.selectedTimeSlot, isNull); // Cleared on date change
      expect(provider.isSelectionComplete, isFalse);
    });

    test('selectDate ignores unavailable / fully booked dates', () async {
      await provider.loadAvailableDates(serviceId: 'srv_1');
      final originalDate = provider.selectedDate;

      // Find an unavailable date (e.g. index 4)
      final unavailableDate =
          provider.availableDates.firstWhere((d) => !d.isAvailable);
      await provider.selectDate(unavailableDate);

      // Selection must not change
      expect(provider.selectedDate, equals(originalDate));
    });

    test('selectTimeSlot ignores unavailable slots', () async {
      await provider.loadAvailableDates(serviceId: 'srv_1');

      final unavailableSlot = provider.timeSlots.firstWhere(
        (s) => !s.isAvailable,
        orElse: () => const TimeSlotModel(
          id: 'mock_unavail',
          startTime: '10:00 AM',
          endTime: '11:00 AM',
          isAvailable: false,
        ),
      );

      provider.selectTimeSlot(unavailableSlot);
      expect(provider.selectedTimeSlot, isNull);
    });

    test('clearSelection resets both date and time slot', () async {
      await provider.loadAvailableDates(serviceId: 'srv_1');
      final availableSlot = provider.timeSlots.firstWhere((s) => s.isAvailable);
      provider.selectTimeSlot(availableSlot);
      expect(provider.isSelectionComplete, isTrue);

      provider.clearSelection();
      expect(provider.selectedDate, isNull);
      expect(provider.selectedTimeSlot, isNull);
      expect(provider.isSelectionComplete, isFalse);
    });

    test('Error handling in loadAvailableDates sets error state', () async {
      final failingRepo = FailingDateTimeRepository();
      final failingProvider = DateTimeProvider(repository: failingRepo);

      await failingProvider.loadAvailableDates(serviceId: 'srv_err');

      expect(failingProvider.datesState.isError, isTrue);
      expect(failingProvider.hasError, isTrue);
      expect(failingProvider.errorMessage, isNotNull);
    });
  });
}
