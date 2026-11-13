import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../constants/api_constants.dart';
import '../storage/storage_keys.dart';
import '../storage/storage_service.dart';

class AuthInterceptor extends Interceptor {
  final StorageService storageService;
  final void Function()? onUnauthorized;
  final Dio? dio;

  bool _isRefreshing = false;

  AuthInterceptor({
    required this.storageService,
    this.onUnauthorized,
    this.dio,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add common headers
    options.headers[ApiConstants.contentTypeHeader] =
        options.headers[ApiConstants.contentTypeHeader] ??
        ApiConstants.applicationJson;
    options.headers[ApiConstants.acceptHeader] = ApiConstants.applicationJson;
    options.headers[ApiConstants.clientTypeHeader] =
        ApiConstants.clientConsumer;

    try {
      options.headers[ApiConstants.clientVersionHeader] =
          AppConfig.instance.appVersion;
    } catch (_) {
      options.headers[ApiConstants.clientVersionHeader] = '1.0.0';
    }

    // Attach auth token if available, skipping public endpoints
    final path = options.path;
    final isPublicEndpoint =
        path.contains('/auth/register') ||
        path.contains('/auth/login') ||
        path.contains('/auth/refresh-token') ||
        path.contains('/auth/forgot-password') ||
        path.contains('/auth/reset-password') ||
        path.contains('/auth/send-otp') ||
        path.contains('/signup/send-otp') ||
        path.contains('/auth/password');

    if (!isPublicEndpoint) {
      final token = storageService.getString(StorageKeys.authToken);
      if (token != null && token.isNotEmpty) {
        options.headers[ApiConstants.authorizationHeader] =
            '${ApiConstants.bearerPrefix}$token';
      }
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final response = err.response;
    final path = err.requestOptions.path;

    final isAuthEndpoint =
        path.contains('/auth/login') ||
        path.contains('/auth/register') ||
        path.contains('/auth/refresh-token') ||
        path.contains('/auth/forgot-password') ||
        path.contains('/auth/reset-password');

    if (response?.statusCode == 401 &&
        !isAuthEndpoint &&
        dio != null &&
        !_isRefreshing) {
      final refreshToken = storageService.getString(StorageKeys.refreshToken);

      if (refreshToken != null && refreshToken.isNotEmpty) {
        _isRefreshing = true;

        try {
          // Attempt refreshing access token
          final refreshDio = Dio(
            BaseOptions(
              baseUrl: err.requestOptions.baseUrl,
              connectTimeout: ApiConstants.connectTimeout,
              receiveTimeout: ApiConstants.receiveTimeout,
            ),
          );

          final refreshResponse = await refreshDio.post(
            ApiConstants.refreshToken,
            data: {'refreshToken': refreshToken},
          );

          final rawData = refreshResponse.data;
          final responseMap = rawData is Map<String, dynamic>
              ? rawData
              : (rawData is Map ? Map<String, dynamic>.from(rawData) : null);

          final newAccessToken =
              responseMap?['accessToken'] as String? ??
              responseMap?['data']?['accessToken'] as String?;
          final newRefreshToken =
              responseMap?['refreshToken'] as String? ??
              responseMap?['data']?['refreshToken'] as String?;

          if (newAccessToken != null && newAccessToken.isNotEmpty) {
            await storageService.setString(
              StorageKeys.authToken,
              newAccessToken,
            );
            if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
              await storageService.setString(
                StorageKeys.refreshToken,
                newRefreshToken,
              );
            }

            // Retry the original failed request
            final opts = Options(
              method: err.requestOptions.method,
              headers: Map<String, dynamic>.from(err.requestOptions.headers)
                ..[ApiConstants.authorizationHeader] =
                    '${ApiConstants.bearerPrefix}$newAccessToken',
            );

            final retryResponse = await dio!.request(
              err.requestOptions.path,
              options: opts,
              data: err.requestOptions.data,
              queryParameters: err.requestOptions.queryParameters,
            );

            _isRefreshing = false;
            return handler.resolve(retryResponse);
          }
        } catch (e) {
          developer.log('Token refresh failed: $e', name: 'AuthInterceptor');
        } finally {
          _isRefreshing = false;
        }
      }

      onUnauthorized?.call();
    } else if (response?.statusCode == 401 && isAuthEndpoint) {
      // Don't auto-logout or loop on login/register 401
    } else if (response?.statusCode == 401) {
      onUnauthorized?.call();
    }

    return handler.next(err);
  }
}

class AppLoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    developer.log(
      '🌐 [HTTP REQUEST] ${options.method} -> ${options.uri}',
      name: 'Network',
    );

    if (options.data != null) {
      final sanitizedData = _sanitizeData(options.data);
      developer.log('📦 Payload: $sanitizedData', name: 'Network');
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    developer.log(
      '✅ [HTTP RESPONSE] [${response.statusCode}] <- '
      '${response.requestOptions.uri}',
      name: 'Network',
    );

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    developer.log(
      '❌ [HTTP ERROR] [${err.response?.statusCode}] <- '
      '${err.requestOptions.uri} : ${err.message}',
      name: 'Network',
      error: err,
    );

    handler.next(err);
  }

  dynamic _sanitizeData(dynamic data) {
    if (data is Map) {
      final sanitized = Map<String, dynamic>.from(data);

      for (final key in [
        'password',
        'confirmPassword',
        'currentPassword',
        'newPassword',
        'token',
        'accessToken',
        'refreshToken',
        'resetToken',
        'otp',
      ]) {
        if (sanitized.containsKey(key)) {
          sanitized[key] = '[PROTECTED]';
        }
      }

      return sanitized;
    }

    return data;
  }
}
