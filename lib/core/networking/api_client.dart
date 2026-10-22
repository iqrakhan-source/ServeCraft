import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import '../config/app_config.dart';
import '../constants/api_constants.dart';
import '../storage/storage_service.dart';
import 'api_interceptors.dart';

class ApiClient {
  final Dio dio;

  ApiClient._(this.dio);

  factory ApiClient.create({
    required StorageService storageService,
    String? baseUrl,
    void Function()? onUnauthorized,
  }) {
    String resolvedBaseUrl = baseUrl ?? ApiConstants.defaultBaseUrl;
    Duration connectTimeout = ApiConstants.connectTimeout;
    Duration receiveTimeout = ApiConstants.receiveTimeout;
    bool enableLogging = true;

    try {
      final config = AppConfig.instance;

      resolvedBaseUrl = baseUrl ?? config.apiBaseUrl;
      connectTimeout = config.connectTimeout;
      receiveTimeout = config.receiveTimeout;
      enableLogging = config.enableLogging;
    } catch (_) {
      // Use default values if AppConfig is not initialized.
    }

    debugPrint('API BASE URL: $resolvedBaseUrl');

    final options = BaseOptions(
      baseUrl: resolvedBaseUrl,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      sendTimeout: ApiConstants.sendTimeout,
      responseType: ResponseType.json,
      headers: {
        ApiConstants.contentTypeHeader:
        ApiConstants.applicationJson,
        ApiConstants.acceptHeader:
        ApiConstants.applicationJson,
      },
    );

    final dio = Dio(options);

    dio.interceptors.add(
      AuthInterceptor(
        storageService: storageService,
        onUnauthorized: onUnauthorized,
      ),
    );

    if (enableLogging) {
      dio.interceptors.add(AppLoggingInterceptor());
    }

    return ApiClient._(dio);
  }

  // ─────────────────────────────────────────────
  // GET
  // ─────────────────────────────────────────────

  Future<ApiResponse<T>> get<T>(
      String path, {
        Map<String, dynamic>? queryParameters,
        Options? options,
        T Function(dynamic json)? fromJson,
      }) async {
    try {
      final response = await dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );

      return _parseResponse<T>(response, fromJson);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;

      throw UnexpectedException(
        message: e.toString(),
      );
    }
  }

  // ─────────────────────────────────────────────
  // POST
  // ─────────────────────────────────────────────


  Future<ApiResponse<T>> post<T>(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        T Function(dynamic json)? fromJson,
      }) async {
    try {
      // Debug only the Create Account request.
      if (path == ApiConstants.registerCustomer) {
        debugPrint('========== REGISTER REQUEST ==========');
        debugPrint('POST URL: ${dio.options.baseUrl}$path');

        if (data is Map) {
          debugPrint('POST body keys: ${data.keys.toList()}');
          debugPrint('POST phone present: ${data.containsKey('phone')}');
          debugPrint('POST phone value: ${data['phone']}');
        }

        debugPrint('======================================');
      }

      final response = await dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return _parseResponse<T>(response, fromJson);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;

      throw UnexpectedException(
        message: e.toString(),
      );
    }
  }

  // ─────────────────────────────────────────────
  // PUT
  // ─────────────────────────────────────────────

  Future<ApiResponse<T>> put<T>(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        T Function(dynamic json)? fromJson,
      }) async {
    try {
      final response = await dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return _parseResponse<T>(response, fromJson);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;

      throw UnexpectedException(
        message: e.toString(),
      );
    }
  }

  // ─────────────────────────────────────────────
  // PATCH
  // ─────────────────────────────────────────────

  Future<ApiResponse<T>> patch<T>(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        T Function(dynamic json)? fromJson,
      }) async {
    try {
      final response = await dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return _parseResponse<T>(response, fromJson);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;

      throw UnexpectedException(
        message: e.toString(),
      );
    }
  }

  // ─────────────────────────────────────────────
  // DELETE
  // ─────────────────────────────────────────────

  Future<ApiResponse<T>> delete<T>(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        T Function(dynamic json)? fromJson,
      }) async {
    try {
      final response = await dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return _parseResponse<T>(response, fromJson);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      if (e is ApiException) rethrow;

      throw UnexpectedException(
        message: e.toString(),
      );
    }
  }

  // ─────────────────────────────────────────────
  // RESPONSE PARSER
  // ─────────────────────────────────────────────

  ApiResponse<T> _parseResponse<T>(
      Response response,
      T Function(dynamic json)? fromJson,
      ) {
    final rawData = response.data;
    final statusCode = response.statusCode ?? 200;

    // Wrapped response:
    // {
    //   "success": true,
    //   "message": "...",
    //   "data": {...}
    // }

    if (rawData is Map<String, dynamic> &&
        (rawData.containsKey('data') ||
            rawData.containsKey('success'))) {
      final success = rawData['success'] as bool? ?? true;

      final message = rawData['message']?.toString() ?? '';

      final innerData = rawData['data'];

      T? parsedData;

      if (innerData != null) {
        parsedData = fromJson != null
            ? fromJson(innerData)
            : innerData as T;
      } else if (fromJson != null) {
        try {
          parsedData = fromJson(rawData);
        } catch (_) {
          parsedData = null;
        }
      }

      return ApiResponse<T>(
        success: success,
        message: message,
        data: parsedData,
        statusCode: statusCode,
        meta: rawData['meta'] is Map<String, dynamic>
            ? rawData['meta'] as Map<String, dynamic>
            : null,
      );
    }

    // Direct response:
    // {...}
    // or
    // [...]

    final T? parsedData = rawData != null
        ? (fromJson != null
        ? fromJson(rawData)
        : rawData as T)
        : null;

    return ApiResponse<T>(
      success: statusCode >= 200 && statusCode < 300,
      message: 'Success',
      data: parsedData,
      statusCode: statusCode,
    );
  }

  // ─────────────────────────────────────────────
  // ERROR HANDLER
  // ─────────────────────────────────────────────

  ApiException _handleDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException();

      case DioExceptionType.connectionError:
        return const NetworkException();

      case DioExceptionType.badCertificate:
        return const NetworkException(
          message: 'Invalid SSL certificate.',
        );

      case DioExceptionType.cancel:
        return const UnexpectedException(
          message: 'Request was cancelled.',
        );

      case DioExceptionType.badResponse:
        return _handleBadResponse(error);

      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return const NetworkException();
        }

        return UnexpectedException(
          message:
          error.message ?? 'An unknown network error occurred.',
        );
      case DioExceptionType.transformTimeout:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  ApiException _handleBadResponse(DioException error) {
    final response = error.response;

    final statusCode = response?.statusCode ?? 500;
    final responseData = response?.data;

    String errorMessage =
        'Request failed with status: $statusCode';

    if (responseData is Map<String, dynamic>) {
      if (responseData['message'] != null) {
        errorMessage = responseData['message'].toString();
      } else if (responseData['error'] != null) {
        errorMessage = responseData['error'].toString();
      }
    }

    switch (statusCode) {
      case 400:
        return BadRequestException(
          message: errorMessage,
          details: responseData,
        );

      case 401:
        return UnauthorizedException(
          message: errorMessage,
          details: responseData,
        );

      case 403:
        return ForbiddenException(
          message: errorMessage,
          details: responseData,
        );

      case 404:
        return NotFoundException(
          message: errorMessage,
          details: responseData,
        );

      case 409:
        return ConflictException(
          message: errorMessage,
          details: responseData,
        );

      case 422:
        return ValidationException(
          message: errorMessage,
          fieldErrors: _extractFieldErrors(responseData),
          details: responseData,
        );

      case >= 500:
        return ServerException(
          message: errorMessage,
          statusCode: statusCode,
          details: responseData,
        );

      default:
        return UnexpectedException(
          message: errorMessage,
          statusCode: statusCode,
          details: responseData,
        );
    }
  }

  Map<String, List<String>> _extractFieldErrors(
      dynamic responseData,
      ) {
    if (responseData is! Map<String, dynamic>) {
      return {};
    }

    final errors = responseData['errors'];

    if (errors is! Map) {
      return {};
    }

    return errors.map(
          (key, value) {
        return MapEntry(
          key.toString(),
          value is List
              ? value.map((e) => e.toString()).toList()
              : [value.toString()],
        );
      },
    );
  }
}


// ═══════════════════════════════════════════════
// API RESPONSE
// ═══════════════════════════════════════════════

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int statusCode;
  final Map<String, dynamic>? meta;

  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
    required this.statusCode,
    this.meta,
  });

  bool get isSuccess => success;

  bool get isFailure => !success;
}


// ═══════════════════════════════════════════════
// API EXCEPTIONS
// ═══════════════════════════════════════════════

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
  String toString() {
    return '$runtimeType: [Status: $statusCode] $message';
  }
}

class NetworkException extends ApiException {
  const NetworkException({
    super.message =
    'No internet connection. Please check your network and try again.',
    super.statusCode,
    super.details,
  });
}

class TimeoutException extends ApiException {
  const TimeoutException({
    super.message =
    'The request timed out. Please try again.',
    super.statusCode = 408,
    super.details,
  });
}

class BadRequestException extends ApiException {
  const BadRequestException({
    super.message =
    'Bad request. Please verify your input.',
    super.statusCode = 400,
    super.details,
  });
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException({
    super.message =
    'Session expired. Please sign in again.',
    super.statusCode = 401,
    super.details,
  });
}

class ForbiddenException extends ApiException {
  const ForbiddenException({
    super.message =
    'You do not have permission to perform this action.',
    super.statusCode = 403,
    super.details,
  });
}

class NotFoundException extends ApiException {
  const NotFoundException({
    super.message =
    'Requested resource was not found.',
    super.statusCode = 404,
    super.details,
  });
}

class ConflictException extends ApiException {
  const ConflictException({
    super.message =
    'A conflict occurred with existing data.',
    super.statusCode = 409,
    super.details,
  });
}

class ValidationException extends ApiException {
  final Map<String, List<String>> fieldErrors;

  const ValidationException({
    super.message =
    'Validation failed for one or more fields.',
    super.statusCode = 422,
    this.fieldErrors = const {},
    super.details,
  });
}

class ServerException extends ApiException {
  const ServerException({
    super.message =
    'Server encountered an error. Please try again later.',
    super.statusCode = 500,
    super.details,
  });
}

class UnexpectedException extends ApiException {
  const UnexpectedException({
    super.message =
    'An unexpected error occurred. Please try again.',
    super.statusCode,
    super.details,
  });
}