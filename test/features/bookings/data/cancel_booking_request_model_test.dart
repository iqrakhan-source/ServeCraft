import 'package:flutter_test/flutter_test.dart';
import 'package:prop_crm/features/bookings/data/models/cancel_booking_request_model.dart';

void main() {
  group('CancelBookingRequestModel Tests', () {
    test('Constructor instantiates correct fields', () {
      const model = CancelBookingRequestModel(
        bookingId: 'bk_123',
        reason: 'Changed my plans',
        reasonNote: 'Need to travel',
      );

      expect(model.bookingId, 'bk_123');
      expect(model.reason, 'Changed my plans');
      expect(model.reasonNote, 'Need to travel');
    });

    test('defaultReasons contains comprehensive deterministic choices', () {
      expect(CancelBookingRequestModel.defaultReasons, contains('Changed my plans'));
      expect(CancelBookingRequestModel.defaultReasons, contains('Booked by mistake'));
      expect(CancelBookingRequestModel.defaultReasons, contains('Found another service'));
      expect(CancelBookingRequestModel.defaultReasons, contains('Schedule no longer works'));
      expect(CancelBookingRequestModel.defaultReasons, contains('Service no longer required'));
      expect(CancelBookingRequestModel.defaultReasons, contains('Other'));
    });

    test('copyWith creates new instance with overridden values', () {
      const original = CancelBookingRequestModel(
        bookingId: 'bk_123',
        reason: 'Changed my plans',
      );

      final copy = original.copyWith(
        reason: 'Other',
        reasonNote: 'Unexpected event',
      );

      expect(copy.bookingId, 'bk_123');
      expect(copy.reason, 'Other');
      expect(copy.reasonNote, 'Unexpected event');
    });

    test('toJson and fromJson serialize and deserialize accurately', () {
      const model = CancelBookingRequestModel(
        bookingId: 'bk_999',
        reason: 'Other',
        reasonNote: 'Family emergency',
      );

      final json = model.toJson();
      expect(json['bookingId'], 'bk_999');
      expect(json['reason'], 'Other');
      expect(json['reasonNote'], 'Family emergency');

      final deserialized = CancelBookingRequestModel.fromJson(json);
      expect(deserialized, equals(model));
    });

    test('toJson omits empty or null reasonNote', () {
      const modelWithNull = CancelBookingRequestModel(
        bookingId: 'bk_111',
        reason: 'Booked by mistake',
      );
      expect(modelWithNull.toJson().containsKey('reasonNote'), isFalse);

      const modelWithWhitespace = CancelBookingRequestModel(
        bookingId: 'bk_222',
        reason: 'Booked by mistake',
        reasonNote: '   ',
      );
      expect(modelWithWhitespace.toJson().containsKey('reasonNote'), isFalse);
    });

    test('Value equality and hashCode work as expected', () {
      const model1 = CancelBookingRequestModel(
        bookingId: 'bk_1',
        reason: 'Reason A',
        reasonNote: 'Note',
      );
      const model2 = CancelBookingRequestModel(
        bookingId: 'bk_1',
        reason: 'Reason A',
        reasonNote: 'Note',
      );
      const model3 = CancelBookingRequestModel(
        bookingId: 'bk_2',
        reason: 'Reason B',
      );

      expect(model1, equals(model2));
      expect(model1.hashCode, equals(model2.hashCode));
      expect(model1, isNot(equals(model3)));
    });
  });
}
