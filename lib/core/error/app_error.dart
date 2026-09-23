/// UI-friendly representation of errors across the application.
class AppError {
  final String message;
  final int? statusCode;
  final String? code;
  final dynamic originalError;

  const AppError({
    required this.message,
    this.statusCode,
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'AppError: $message (code: $code, status: $statusCode)';
}
