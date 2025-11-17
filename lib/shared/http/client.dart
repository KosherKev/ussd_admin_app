import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

const _port = 5005;

String baseUrl() {
  if (kIsWeb) return 'https://ussd-service-api-165745695590.europe-west1.run.app:$_port/api';
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return 'https://ussd-service-api-165745695590.europe-west1.run.app/api';
    default:
      return 'https://ussd-service-api-165745695590.europe-west1.run.app/api';
  }
}

Dio buildDio({String? token}) {
  final dio = Dio(BaseOptions(baseUrl: baseUrl(), connectTimeout: const Duration(seconds: 10)));
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      options.headers['Content-Type'] = 'application/json';
      options.headers['x-correlation-id'] = const Uuid().v4();
      handler.next(options);
    },
  ));
  return dio;
}