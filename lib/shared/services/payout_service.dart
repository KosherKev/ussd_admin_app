import 'package:shared_preferences/shared_preferences.dart';
import '../http/client.dart';
import '../models/payout.dart';

class PayoutService {
  Future<int> schedule(String organizationId, {DateTime? scheduledDate}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final dio = buildDio(token: token);
    
    final res = await dio.post('/payouts/schedule', data: {
      'organizationId': organizationId,
      if (scheduledDate != null) 'scheduledDate': scheduledDate.toIso8601String(),
    });
    final data = res.data as Map<String, dynamic>;
    
    return (data['count'] as num?)?.toInt() ?? 0;
  }

  Future<List<Payout>> listPending() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final dio = buildDio(token: token);
    
    final res = await dio.get('/payouts/pending');
    final data = res.data as Map<String, dynamic>;
    final items = (data['items'] as List? ?? [])
        .cast<Map<String, dynamic>>()
        .map((m) => Payout.fromJson(m))
        .toList();
    
    return items;
  }

  Future<String> process(String payoutId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final dio = buildDio(token: token);
    
    final res = await dio.post('/payouts/$payoutId/process');
    final data = res.data as Map<String, dynamic>;
    
    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'Payout processing failed');
    }
    
    return (data['payoutRef'] ?? '').toString();
  }
}
