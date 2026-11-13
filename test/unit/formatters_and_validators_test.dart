import 'package:flutter_test/flutter_test.dart';
import 'package:prop_crm/core/utilities/formatters.dart';
import 'package:prop_crm/core/utilities/validators.dart';

void main() {
  group('AppFormatters Tests', () {
    test('formatIndianDate formats to dd/MM/yyyy', () {
      final date = DateTime(2026, 11, 14);
      expect(AppFormatters.formatIndianDate(date), '14/11/2026');
    });

    test('formatBackendDate formats to yyyy-MM-dd', () {
      final date = DateTime(2026, 11, 14);
      expect(AppFormatters.formatBackendDate(date), '2026-11-14');
    });

    test('formatDob handles yyyy-MM-dd, dd/MM/yyyy, and ISO8601', () {
      expect(AppFormatters.formatDob('1999-01-05'), '05/01/1999');
      expect(AppFormatters.formatDob('05/01/1999'), '05/01/1999');
      expect(AppFormatters.formatDob('1999-01-05T00:00:00.000Z'), '05/01/1999');
      expect(AppFormatters.formatDob(null, fallback: 'Not set'), 'Not set');
      expect(AppFormatters.formatDob('', fallback: 'Not set'), 'Not set');
    });

    test('parseDob correctly parses date formats', () {
      final parsed1 = AppFormatters.parseDob('05/01/1999');
      expect(parsed1?.year, 1999);
      expect(parsed1?.month, 1);
      expect(parsed1?.day, 5);

      final parsed2 = AppFormatters.parseDob('1999-01-05');
      expect(parsed2?.year, 1999);
      expect(parsed2?.month, 1);
      expect(parsed2?.day, 5);

      expect(AppFormatters.parseDob(null), isNull);
      expect(AppFormatters.parseDob('invalid'), isNull);
    });

    test('formatCurrency formats Indian rupee correctly', () {
      expect(AppFormatters.formatCurrency(499), '₹499');
      expect(AppFormatters.formatCurrency(1250), '₹1,250');
      expect(AppFormatters.formatCurrency(1250, showDecimals: true), '₹1,250.00');
    });

    test('formatTime12Hour converts 24h string to 12h AM/PM', () {
      expect(AppFormatters.formatTime12Hour('09:00'), '09:00 AM');
      expect(AppFormatters.formatTime12Hour('14:30'), '02:30 PM');
      expect(AppFormatters.formatTime12Hour('12:00'), '12:00 PM');
      expect(AppFormatters.formatTime12Hour('00:15'), '12:15 AM');
    });

    test('parseDurationMinutes parses strings with numbers', () {
      expect(AppFormatters.parseDurationMinutes('45 mins'), 45);
      expect(AppFormatters.parseDurationMinutes('90 minutes'), 90);
      expect(AppFormatters.parseDurationMinutes('120'), 120);
      expect(AppFormatters.parseDurationMinutes(null), 45);
    });
  });

  group('AppValidators Tests', () {
    test('validateEmail validates format', () {
      expect(AppValidators.validateEmail('', isRequired: true), isNotNull);
      expect(AppValidators.validateEmail('invalid-email'), isNotNull);
      expect(AppValidators.validateEmail('user@test.com'), isNull);
    });

    test('validatePhone validates 10 digits', () {
      expect(AppValidators.validatePhone(''), isNotNull);
      expect(AppValidators.validatePhone('12345'), isNotNull);
      expect(AppValidators.validatePhone('9876543210'), isNull);
    });

    test('validatePassword validates length', () {
      expect(AppValidators.validatePassword('123'), isNotNull);
      expect(AppValidators.validatePassword('123456'), isNull);
    });

    test('validateName validates minimum length', () {
      expect(AppValidators.validateName('A'), isNotNull);
      expect(AppValidators.validateName('John Doe'), isNull);
    });
  });
}
