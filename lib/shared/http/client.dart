import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../app/router/routes.dart';
import '../../main.dart' show navigatorKey;

const _port = 5005;

String baseUrl() {
  if (kIsWeb) return 'http://localhost:$_port/api';
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return 'https://pay.bevingh.com/api';
    default:
      return 'https://pay.bevingh.com/api';
  }
}

Dio buildDio({String? token}) {
  final dio = Dio(BaseOptions(
    baseUrl: baseUrl(),
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
    sendTimeout: const Duration(seconds: 20),
  ));

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      options.headers['Content-Type'] = 'application/json';
      options.headers['x-correlation-id'] = const Uuid().v4();
      handler.next(options);
    },
    onError: (DioException error, handler) async {
      if (error.response?.statusCode == 401) {
        // Only treat as session expiry if it's NOT an API-key-related error.
        // /v1/* endpoints require an x-api-key header and return 401 with
        // INVALID_API_KEY when accessed with a Bearer token — we must NOT
        // clear the session in that case.
        final body   = error.response?.data;
        final errCode = (body is Map ? body['error']?.toString() ?? '' : '');
        final isApiKeyError = errCode.toUpperCase().contains('API_KEY') ||
            errCode.toUpperCase().contains('INVALID_KEY');

        if (!isApiKeyError) {
          // Real token expiry — clear session and redirect to login.
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('token');
          await prefs.remove('role');
          await prefs.remove('org_id');
          await prefs.remove('org_name');
          await prefs.remove('dev_mode');
          await prefs.remove('key_id');
          await prefs.remove('email');

          final nav = navigatorKey.currentState;
          if (nav != null) {
            nav.pushNamedAndRemoveUntil(Routes.login, (_) => false);
          }
          handler.reject(error);
          return;
        }
      }
      handler.next(error);
    },
  ));

  return dio;
}
