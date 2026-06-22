import 'package:captain/core/config/app_config.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

Dio createApiClient({String? baseUrl}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl ?? AppConfig.visionApiBaseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      headers: const {
        'Accept': 'application/json',
      },
    ),
  );

  if (kDebugMode) {
    dio.interceptors.add(_LoggingInterceptor());
  }

  return dio;
}

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('→ ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    debugPrint('← ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint(
      '✕ ${err.requestOptions.method} ${err.requestOptions.uri} '
      '(${err.response?.statusCode ?? err.type.name})',
    );
    handler.next(err);
  }
}
