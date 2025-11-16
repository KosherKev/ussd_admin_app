import 'package:shared_preferences/shared_preferences.dart';
import '../http/client.dart';
import '../models/subscription.dart';

class SubscriptionService {
  Future<Subscription> getStatus(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final dio = buildDio(token: token);
    
    final res = await dio.get('/subscriptions/$id/status');
    final data = res.data as Map<String, dynamic>;
    
    return Subscription.fromJson(data['item'] as Map<String, dynamic>);
  }

  Future<Subscription> activate(String id, {
    String billingPeriod = 'monthly',
    DateTime? startDate,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final dio = buildDio(token: token);
    
    final res = await dio.post('/subscriptions/$id/activate', data: {
      'billingPeriod': billingPeriod,
      if (startDate != null) 'startDate': startDate.toIso8601String(),
    });
    final data = res.data as Map<String, dynamic>;
    
    return Subscription.fromJson(data['item'] as Map<String, dynamic>);
  }

  Future<Subscription> cancel(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final dio = buildDio(token: token);
    
    final res = await dio.post('/subscriptions/$id/cancel');
    final data = res.data as Map<String, dynamic>;
    
    return Subscription.fromJson(data['item'] as Map<String, dynamic>);
  }
}
