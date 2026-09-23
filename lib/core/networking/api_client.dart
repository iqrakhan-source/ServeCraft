import 'package:dio/dio.dart';
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
      // Use defaults if config not initialized
    }

    final baseOptions = BaseOptions(
      baseUrl: resolvedBaseUrl,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      sendTimeout: ApiConstants.sendTimeout,
      responseType: ResponseType.json,
      headers: {
        ApiConstants.contentTypeHeader: ApiConstants.applicationJson,
        ApiConstants.acceptHeader: ApiConstants.applicationJson,
      },
    );

    final dio = Dio(baseOptions);

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
}
