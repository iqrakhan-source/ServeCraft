/// Base class for all API and Network exceptions across the application.
abstract class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  const ApiException({
    required this.message,
    this.statusCode,
    this.details,
  });

  @override
  String toString() => '$runtimeType: [Status: $statusCode] $message';
}

/// Thrown when there is no internet connection or hostname resolution fails.
class NetworkException extends ApiException {
  const NetworkException({
    super.message = 'No internet connection. Please check your network and try again.',
    super.statusCode,
    super.details,
  });
}

/// Thrown when an API request times out (connection, send, or receive).
class TimeoutException extends ApiException {
  const TimeoutException({
    super.message = 'The request timed out. Please try again.',
    super.statusCode = 408,
    super.details,
  });
}

/// Thrown on HTTP 400 Bad Request.
class BadRequestException extends ApiException {
  const BadRequestException({
    super.message = 'Bad request. Please verify your input.',
    super.statusCode = 400,
    super.details,
  });
}

/// Thrown on HTTP 401 Unauthorized (session expired or invalid credentials).
class UnauthorizedException extends ApiException {
  const UnauthorizedException({
    super.message = 'Session expired. Please sign in again.',
    super.statusCode = 401,
    super.details,
  });
}

/// Thrown on HTTP 403 Forbidden.
class ForbiddenException extends ApiException {
  const ForbiddenException({
    super.message = 'You do not have permission to perform this action.',
    super.statusCode = 403,
    super.details,
  });
}

/// Thrown on HTTP 404 Not Found.
class NotFoundException extends ApiException {
  const NotFoundException({
    super.message = 'Requested resource was not found.',
    super.statusCode = 404,
    super.details,
  });
}

/// Thrown on HTTP 409 Conflict.
class ConflictException extends ApiException {
  const ConflictException({
    super.message = 'A conflict occurred with existing data.',
    super.statusCode = 409,
    super.details,
  });
}

/// Thrown on HTTP 422 Unprocessable Entity (e.g. form validation errors).
class ValidationException extends ApiException {
  final Map<String, List<String>> fieldErrors;

  const ValidationException({
    super.message = 'Validation failed for one or more fields.',
    super.statusCode = 422,
    this.fieldErrors = const {},
    super.details,
  });
}

/// Thrown on HTTP 500+ Internal Server Error.
class ServerException extends ApiException {
  const ServerException({
    super.message = 'Server encountered an error. Please try again later.',
    super.statusCode = 500,
    super.details,
  });
}

/// Thrown on any unhandled or unknown exception.
class UnexpectedException extends ApiException {
  const UnexpectedException({
    super.message = 'An unexpected error occurred. Please try again.',
    super.statusCode,
    super.details,
  });
}
