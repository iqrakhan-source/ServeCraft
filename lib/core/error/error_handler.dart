import '../constants/app_strings.dart';
import '../networking/api_exceptions.dart';
import 'app_error.dart';

abstract class ErrorHandler {
  /// Transforms any dynamic exception or error into an AppError with a human-readable message.
  static AppError handleError(dynamic error) {
    if (error is NetworkException) {
      return AppError(
        message: AppStrings.networkError,
        statusCode: error.statusCode,
        code: 'NETWORK_ERROR',
        originalError: error,
      );
    }

    if (error is TimeoutException) {
      return AppError(
        message: AppStrings.timeoutError,
        statusCode: error.statusCode,
        code: 'TIMEOUT',
        originalError: error,
      );
    }

    if (error is UnauthorizedException) {
      return AppError(
        message: error.message.isNotEmpty
            ? error.message
            : AppStrings.sessionExpired,
        statusCode: 401,
        code: 'UNAUTHORIZED',
        originalError: error,
      );
    }

    if (error is ValidationException) {
      final firstFieldError = error.fieldErrors.values.isNotEmpty &&
              error.fieldErrors.values.first.isNotEmpty
          ? error.fieldErrors.values.first.first
          : error.message;

      return AppError(
        message: firstFieldError,
        statusCode: 422,
        code: 'VALIDATION_ERROR',
        originalError: error,
      );
    }

    if (error is ApiException) {
      return AppError(
        message: error.message.isNotEmpty
            ? error.message
            : AppStrings.commonError,
        statusCode: error.statusCode,
        code: 'API_ERROR',
        originalError: error,
      );
    }

    if (error is FormatException) {
      return AppError(
        message: 'Invalid data format received.',
        code: 'FORMAT_ERROR',
        originalError: error,
      );
    }

    return AppError(
      message: error?.toString().isNotEmpty == true &&
              !error.toString().startsWith('Instance of')
          ? error.toString()
          : AppStrings.commonError,
      code: 'UNKNOWN',
      originalError: error,
    );
  }
}
