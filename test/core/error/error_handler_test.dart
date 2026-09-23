import 'package:flutter_test/flutter_test.dart';
import 'package:prop_crm/core/constants/app_strings.dart';
import 'package:prop_crm/core/error/error_handler.dart';
import 'package:prop_crm/core/networking/api_exceptions.dart';

void main() {
  group('ErrorHandler', () {
    test('transforms NetworkException into AppError with network message', () {
      const exception = NetworkException();
      final appError = ErrorHandler.handleError(exception);
      expect(appError.code, equals('NETWORK_ERROR'));
      expect(appError.message, equals(AppStrings.networkError));
    });

    test('transforms TimeoutException into AppError with timeout message', () {
      const exception = TimeoutException();
      final appError = ErrorHandler.handleError(exception);
      expect(appError.code, equals('TIMEOUT'));
      expect(appError.message, equals(AppStrings.timeoutError));
    });

    test('transforms UnauthorizedException into AppError', () {
      const exception = UnauthorizedException();
      final appError = ErrorHandler.handleError(exception);
      expect(appError.code, equals('UNAUTHORIZED'));
      expect(appError.statusCode, equals(401));
    });

    test('extracts field errors from ValidationException', () {
      const exception = ValidationException(
        fieldErrors: {
          'phone': ['Mobile number is invalid']
        },
      );
      final appError = ErrorHandler.handleError(exception);
      expect(appError.code, equals('VALIDATION_ERROR'));
      expect(appError.message, equals('Mobile number is invalid'));
    });
  });
}
