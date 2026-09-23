import 'package:flutter_test/flutter_test.dart';
import 'package:prop_crm/features/date_time/data/datasources/date_time_remote_data_source.dart';
import 'package:prop_crm/features/date_time/data/repositories/date_time_repository_impl.dart';

void main() {
  late MockDateTimeRemoteDataSource dataSource;
  late DateTimeRepositoryImpl repository;

  setUp(() {
    dataSource = MockDateTimeRemoteDataSource();
    repository = DateTimeRepositoryImpl(remoteDataSource: dataSource);
  });

  group('DateTimeRepository & MockDataSource Tests', () {
    test('getAvailableDates returns 14 rolling days', () async {
      final dates = await repository.getAvailableDates(
        serviceId: 'srv_1',
        packageId: 'pkg_1',
      );

      expect(dates.length, 14);

      // Verify first date is today
      final now = DateTime.now();
      expect(dates.first.date.year, now.year);
      expect(dates.first.date.month, now.month);
      expect(dates.first.date.day, now.day);
      expect(dates.first.isToday, isTrue);

      // Verify second date is tomorrow
      expect(dates[1].isTomorrow, isTrue);

      // Verify Day 4 is fully booked/unavailable
      expect(dates[4].isAvailable, isFalse);
      expect(dates[4].unavailableReason, 'Fully Booked');

      // Verify available days contain slots
      expect(dates[1].slots.isNotEmpty, isTrue);
    });

    test('getTimeSlots returns slots for available date and empty for unavailable date',
        () async {
      final dates = await repository.getAvailableDates(
        serviceId: 'srv_1',
        packageId: 'pkg_1',
      );

      final availableDate = dates[1]; // Tomorrow
      final slots = await repository.getTimeSlots(
        date: availableDate.date,
        serviceId: 'srv_1',
        packageId: 'pkg_1',
      );

      expect(slots.isNotEmpty, isTrue);
      expect(slots.any((s) => s.isAvailable), isTrue);

      // Test unavailable date (Day 4) - returns slots with isAvailable false
      final unavailableDate = dates[4];
      final unavailableSlots = await repository.getTimeSlots(
        date: unavailableDate.date,
        serviceId: 'srv_1',
        packageId: 'pkg_1',
      );

      expect(unavailableSlots.isNotEmpty, isTrue);
      expect(unavailableSlots.every((s) => !s.isAvailable), isTrue);

      // Test non-existent date returns empty list
      final nonExistentSlots = await repository.getTimeSlots(
        date: DateTime(2045, 1, 1),
        serviceId: 'srv_1',
        packageId: 'pkg_1',
      );
      expect(nonExistentSlots.isEmpty, isTrue);
    });

    test('Session cache maintains identical slots for repeated calls', () async {
      final datesCall1 = await repository.getAvailableDates(
        serviceId: 'srv_cache_test',
        packageId: 'pkg_cache_test',
      );

      final datesCall2 = await repository.getAvailableDates(
        serviceId: 'srv_cache_test',
        packageId: 'pkg_cache_test',
      );

      expect(datesCall1.length, datesCall2.length);
      expect(
        datesCall1[1].slots.first.id,
        datesCall2[1].slots.first.id,
      );
    });
  });
}
