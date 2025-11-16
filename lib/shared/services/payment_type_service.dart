import 'package:shared_preferences/shared_preferences.dart';
import '../http/client.dart';
import '../models/payment_type.dart';

class PaymentTypeService {
  Future<List<PaymentType>> list(String orgId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final dio = buildDio(token: token);
    
    final res = await dio.get('/orgs/$orgId/payment-types');
    final data = res.data as Map<String, dynamic>;
    final items = (data['items'] as List? ?? [])
        .cast<Map<String, dynamic>>()
        .map((m) => PaymentType.fromJson(m))
        .toList();
    
    return items;
  }

  Future<List<PaymentType>> create(String orgId, PaymentType paymentType) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final dio = buildDio(token: token);
    
    final res = await dio.post('/orgs/$orgId/payment-types', data: paymentType.toJson());
    final data = res.data as Map<String, dynamic>;
    final items = (data['items'] as List? ?? [])
        .cast<Map<String, dynamic>>()
        .map((m) => PaymentType.fromJson(m))
        .toList();
    
    return items;
  }

  Future<PaymentType> update(String orgId, String typeId, Map<String, dynamic> updates) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final dio = buildDio(token: token);
    
    final res = await dio.patch('/orgs/$orgId/payment-types/$typeId', data: updates);
    final data = res.data as Map<String, dynamic>;
    
    return PaymentType.fromJson(data['item'] as Map<String, dynamic>);
  }
}
