import 'package:flutter_test/flutter_test.dart';
import 'package:prop_crm/features/date_time/data/models/service_date_model.dart';
import 'package:prop_crm/features/date_time/data/models/time_slot_model.dart';

void main() {
  group('TimeSlotModel Tests', () {
    const slot = TimeSlotModel(
      id: 'slot_1',
      startTime: '09:00 AM',
      endTime: '10:00 AM',
      isAvailable: true,
      displayLabel: '09:00 AM - 10:00 AM',
    );

    test('Properties and formattedLabel', () {
      expect(slot.id, 'slot_1');
      expect(slot.startTime, '09:00 AM');
      expect(slot.endTime, '10:00 AM');
      expect(slot.isAvailable, isTrue);
      expect(slot.formattedLabel, '09:00 AM - 10:00 AM');

      const fallbackSlot = TimeSlotModel(
        id: 'slot_2',
        startTime: '10:00 AM',
        endTime: '11:00 AM',
      );
      expect(fallbackSlot.formattedLabel, '10:00 AM - 11:00 AM');
    });

    test('copyWith works correctly', () {
      final updated = slot.copyWith(
        isAvailable: false,
        displayLabel: 'Unavailable Slot',
      );
      expect(updated.id, 'slot_1');
      expect(updated.isAvailable, isFalse);
      expect(updated.displayLabel, 'Unavailable Slot');
      expect(updated.startTime, '09:00 AM');
    });

    test('JSON serialization roundtrip', () {
      final json = slot.toJson();
      expect(json['id'], 'slot_1');
      expect(json['startTime'], '09:00 AM');
      expect(json['endTime'], '10:00 AM');
      expect(json['isAvailable'], isTrue);
      expect(json['displayLabel'], '09:00 AM - 10:00 AM');

      final deserialized = TimeSlotModel.fromJson(json);
      expect(deserialized, equals(slot));
      expect(deserialized.hashCode, equals(slot.hashCode));
    });

    test('Equality and inequality', () {
      const identicalSlot = TimeSlotModel(
        id: 'slot_1',
        startTime: '09:00 AM',
        endTime: '10:00 AM',
        isAvailable: true,
        displayLabel: '09:00 AM - 10:00 AM',
      );
      const differentSlot = TimeSlotModel(
        id: 'slot_diff',
        startTime: '09:00 AM',
        endTime: '10:00 AM',
      );

      expect(slot, equals(identicalSlot));
      expect(slot == differentSlot, isFalse);
    });
  });

  group('ServiceDateModel Tests', () {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final futureDate = today.add(const Duration(days: 5));

    const slot1 = TimeSlotModel(
      id: 's1',
      startTime: '09:00 AM',
      endTime: '10:00 AM',
      isAvailable: true,
    );
    const slot2 = TimeSlotModel(
      id: 's2',
      startTime: '10:00 AM',
      endTime: '11:00 AM',
      isAvailable: false,
    );

    test('isToday and isTomorrow getters', () {
      final todayModel = ServiceDateModel(date: today);
      final tomorrowModel = ServiceDateModel(date: tomorrow);
      final futureModel = ServiceDateModel(date: futureDate);

      expect(todayModel.isToday, isTrue);
      expect(todayModel.isTomorrow, isFalse);
      expect(todayModel.dayName, 'Today');

      expect(tomorrowModel.isToday, isFalse);
      expect(tomorrowModel.isTomorrow, isTrue);
      expect(tomorrowModel.dayName, 'Tomorrow');

      expect(futureModel.isToday, isFalse);
      expect(futureModel.isTomorrow, isFalse);
      expect(
        ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
        contains(futureModel.dayName),
      );
    });

    test('Date presentation getters and key format', () {
      final testDate = DateTime(2026, 9, 25);
      final dateModel = ServiceDateModel(
        date: testDate,
        isAvailable: true,
        slots: const [slot1, slot2],
      );

      expect(dateModel.dayNumber, '25');
      expect(dateModel.monthName, 'Sep');
      expect(dateModel.dateKey, '2026-09-25');
      expect(dateModel.availableSlotsCount, 1);
    });

    test('copyWith works correctly', () {
      final dateModel = ServiceDateModel(
        date: today,
        isAvailable: true,
        slots: const [slot1],
      );

      final updated = dateModel.copyWith(
        isAvailable: false,
        unavailableReason: 'Fully Booked',
        slots: const [slot1, slot2],
      );

      expect(updated.isAvailable, isFalse);
      expect(updated.unavailableReason, 'Fully Booked');
      expect(updated.slots.length, 2);
      expect(updated.date, today);
    });

    test('JSON serialization roundtrip', () {
      final dateModel = ServiceDateModel(
        date: DateTime(2026, 9, 25),
        isAvailable: false,
        unavailableReason: 'Fully booked',
        slots: const [slot1, slot2],
      );

      final json = dateModel.toJson();
      expect(json['isAvailable'], isFalse);
      expect(json['unavailableReason'], 'Fully booked');
      expect((json['slots'] as List).length, 2);

      final deserialized = ServiceDateModel.fromJson(json);
      expect(deserialized.dateKey, dateModel.dateKey);
      expect(deserialized.isAvailable, dateModel.isAvailable);
      expect(deserialized.unavailableReason, dateModel.unavailableReason);
      expect(deserialized.slots.length, 2);
      expect(deserialized, equals(dateModel));
    });

    test('Equality based on date, availability and reason', () {
      final date1 = ServiceDateModel(
        date: DateTime(2026, 9, 25, 8, 0),
        isAvailable: true,
      );
      final date2 = ServiceDateModel(
        date: DateTime(2026, 9, 25, 14, 0), // Same day
        isAvailable: true,
      );
      final dateDiff = ServiceDateModel(
        date: DateTime(2026, 9, 26),
        isAvailable: true,
      );

      expect(date1, equals(date2));
      expect(date1 == dateDiff, isFalse);
    });
  });
}
