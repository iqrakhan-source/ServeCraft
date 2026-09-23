import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../constants/api_constants.dart';
import '../storage/storage_keys.dart';
import '../storage/storage_service.dart';

class AuthInterceptor extends Interceptor {
  final StorageService storageService;
  final void Function()? onUnauthorized;

  AuthInterceptor({
    required this.storageService,
    this.onUnauthorized,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add common headers
    options.headers[ApiConstants.contentTypeHeader] = ApiConstants.applicationJson;
    options.headers[ApiConstants.acceptHeader] = ApiConstants.applicationJson;
    options.headers[ApiConstants.clientTypeHeader] = ApiConstants.clientConsumer;
    
    try {
      options.headers[ApiConstants.clientVersionHeader] =
          AppConfig.instance.appVersion;
    } catch (_) {
      // Fallback if AppConfig isn't initialized yet
      options.headers[ApiConstants.clientVersionHeader] = '1.0.0';
    }

    // Attach auth token if available
    final token = storageService.getString(StorageKeys.authToken);
    if (token != null && token.isNotEmpty) {
      options.headers[ApiConstants.authorizationHeader] =
          '${ApiConstants.bearerPrefix}$token';
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
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
      developer.log('📦 Payload: ${options.data}', name: 'Network');
    }
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    developer.log(
      '✅ [HTTP RESPONSE] [${response.statusCode}] <- ${response.requestOptions.uri}',
      name: 'Network',
    );
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    developer.log(
      '❌ [HTTP ERROR] [${err.response?.statusCode}] <- ${err.requestOptions.uri} : ${err.message}',
      name: 'Network',
      error: err,
    );
    return handler.next(err);
  }
}
