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
        // Token expired or invalid — clear session and redirect to login.
        // This runs at the Dio layer so no BuildContext is needed.
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
        // Reject the error so callers don't also show a snackbar after redirect
        handler.reject(error);
        return;
      }
      handler.next(error);
    },
  ));

  return dio;
}
