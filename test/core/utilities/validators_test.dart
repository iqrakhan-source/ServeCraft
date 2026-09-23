import 'package:flutter_test/flutter_test.dart';
import 'package:prop_crm/core/utilities/validators.dart';

void main() {
  group('AppValidators', () {
    test('validatePhone correctly validates Indian 10-digit mobile numbers', () {
      expect(AppValidators.validatePhone(''), isNotNull);
      expect(AppValidators.validatePhone(null), isNotNull);
      expect(AppValidators.validatePhone('1234567890'), isNotNull); // Doesn't start with 6-9
      expect(AppValidators.validatePhone('98765'), isNotNull); // Too short
      expect(AppValidators.validatePhone('98765432101'), isNotNull); // Too long
      expect(AppValidators.validatePhone('9876543210'), isNull); // Valid
      expect(AppValidators.validatePhone('8876543210'), isNull); // Valid
      expect(AppValidators.validatePhone('7876543210'), isNull); // Valid
      expect(AppValidators.validatePhone('6876543210'), isNull); // Valid
    });

    test('validateOtp validates 6-digit PIN', () {
      expect(AppValidators.validateOtp(''), isNotNull);
      expect(AppValidators.validateOtp('12345'), isNotNull);
      expect(AppValidators.validateOtp('1234567'), isNotNull);
      expect(AppValidators.validateOtp('12345a'), isNotNull);
      expect(AppValidators.validateOtp('123456'), isNull);
    });

    test('validateName validates minimum 2 characters', () {
      expect(AppValidators.validateName(''), isNotNull);
      expect(AppValidators.validateName('A'), isNotNull);
      expect(AppValidators.validateName('Al'), isNull);
      expect(AppValidators.validateName('Alex Morgan'), isNull);
    });

    test('validateEmail validates email formats', () {
      expect(AppValidators.validateEmail(null, isRequired: false), isNull);
      expect(AppValidators.validateEmail('', isRequired: false), isNull);
      expect(AppValidators.validateEmail('invalid-email'), isNotNull);
      expect(AppValidators.validateEmail('user@test'), isNotNull);
      expect(AppValidators.validateEmail('user@test.com'), isNull);
    });

    test('validatePincode validates 6-digit pincode', () {
      expect(AppValidators.validatePincode(''), isNotNull);
      expect(AppValidators.validatePincode('12345'), isNotNull);
      expect(AppValidators.validatePincode('560001'), isNull);
    });
  });
}
