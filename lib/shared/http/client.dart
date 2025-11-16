import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

const _port = 5005;

String baseUrl() {
  if (kIsWeb) return 'http://localhost:$_port/api';
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return 'http://10.0.2.2:$_port/api';
    default:
      return 'http://localhost:$_port/api';
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