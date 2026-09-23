import 'dart:io';
import 'package:dio/dio.dart';
import 'api_exceptions.dart';
import 'api_response.dart';

abstract class ApiService {
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic json)? fromJson,
  });

  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic json)? fromJson,
  });

  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic json)? fromJson,
  });

  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic json)? fromJson,
  });

  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic json)? fromJson,
  });
}

class DioApiService implements ApiService {
  final Dio dio;

  DioApiService({required this.dio});

  @override
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
      throw UnexpectedException(message: e.toString());
    }
  }

  @override
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
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
      throw UnexpectedException(message: e.toString());
    }
  }

  @override
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
      throw UnexpectedException(message: e.toString());
    }
  }

  @override
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
      throw UnexpectedException(message: e.toString());
    }
  }

  @override
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
      throw UnexpectedException(message: e.toString());
    }
  }

  ApiResponse<T> _parseResponse<T>(
    Response response,
    T Function(dynamic json)? fromJson,
  ) {
    final rawData = response.data;
    final statusCode = response.statusCode ?? 200;

    if (rawData is Map<String, dynamic>) {
      // Check if wrapped in standard format
      if (rawData.containsKey('data') || rawData.containsKey('success')) {
        final success = rawData['success'] as bool? ?? true;
        final message = (rawData['message'] as String?) ?? '';
        final innerData = rawData['data'];
        final T? parsed = innerData != null
            ? (fromJson != null ? fromJson(innerData) : innerData as T)
            : null;

        return ApiResponse<T>(
          success: success,
          message: message,
          data: parsed,
          statusCode: statusCode,
          meta: rawData['meta'] as Map<String, dynamic>?,
        );
      }
    }

    // Direct object or list response
    final T? parsed = rawData != null
        ? (fromJson != null ? fromJson(rawData) : rawData as T)
        : null;

    return ApiResponse<T>(
      success: statusCode >= 200 && statusCode < 300,
      message: 'Success',
      data: parsed,
      statusCode: statusCode,
    );
  }

  ApiException _handleDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException();

      case DioExceptionType.connectionError:
        return const NetworkException();

      case DioExceptionType.badResponse:
        final response = error.response;
        final statusCode = response?.statusCode ?? 500;
        final responseData = response?.data;
        String errorMessage = 'Request failed with status: $statusCode';

        if (responseData is Map<String, dynamic>) {
          if (responseData['message'] != null) {
            errorMessage = responseData['message'].toString();
          } else if (responseData['error'] != null) {
            errorMessage = responseData['error'].toString();
          }
        }

        switch (statusCode) {
          case 400:
            return BadRequestException(message: errorMessage, details: responseData);
          case 401:
            return UnauthorizedException(message: errorMessage, details: responseData);
          case 403:
            return ForbiddenException(message: errorMessage, details: responseData);
          case 404:
            return NotFoundException(message: errorMessage, details: responseData);
          case 409:
            return ConflictException(message: errorMessage, details: responseData);
          case 422:
            Map<String, List<String>> fieldErrors = {};
            if (responseData is Map<String, dynamic> &&
                responseData['errors'] is Map) {
              final rawErrors = responseData['errors'] as Map;
              fieldErrors = rawErrors.map((key, val) => MapEntry(
                    key.toString(),
                    (val is List)
                        ? val.map((e) => e.toString()).toList()
                        : [val.toString()],
                  ));
            }
            return ValidationException(
              message: errorMessage,
              fieldErrors: fieldErrors,
              details: responseData,
            );
          case 500:
          case 502:
          case 503:
          case 504:
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

      case DioExceptionType.cancel:
        return const UnexpectedException(message: 'Request was cancelled.');

      case DioExceptionType.badCertificate:
        return const NetworkException(message: 'Invalid SSL certificate.');

      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return const NetworkException();
        }
        return UnexpectedException(
          message: error.message ?? 'An unknown network error occurred.',
        );
      default:
        return UnexpectedException(
          message: error.message ?? 'An unknown network error occurred.',
        );
    }
  }
}
