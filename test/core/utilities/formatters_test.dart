import 'package:flutter_test/flutter_test.dart';
import 'package:prop_crm/core/utilities/formatters.dart';

void main() {
  group('AppFormatters', () {
    test('formatCurrency formats Indian Rupee correctly', () {
      final formatted = AppFormatters.formatCurrency(499);
      expect(formatted.contains('499'), isTrue);
      expect(formatted.contains('₹'), isTrue);
    });

    test('formatPhone formats 10-digit number with spaces', () {
      final formatted = AppFormatters.formatPhone('9876543210');
      expect(formatted, equals('+91 98765 43210'));
    });

    test('formatDate formats DateTime into dd MMM yyyy', () {
      final date = DateTime(2026, 9, 23);
      final formatted = AppFormatters.formatDate(date);
      expect(formatted, equals('23 Sep 2026'));
    });
  });
}
