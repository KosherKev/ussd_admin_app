import 'package:shared_preferences/shared_preferences.dart';
import '../http/client.dart';
import '../models/paged.dart';
import '../models/organization.dart';

class OrgService {
  Future<Paged<Organization>> list({int page = 1, int limit = 10, String? q}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final dio   = buildDio(token: token);
    final res   = await dio.get('/orgs', queryParameters: {
      'page': page,
      'limit': limit,
      if (q != null && q.isNotEmpty) 'q': q,
    });
    return Paged.fromJson(res.data as Map<String, dynamic>, (m) => Organization.fromJson(m));
  }

  /// Fetch a single org by id (GET /api/orgs/:id)
  Future<Organization> get(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final dio   = buildDio(token: token);
    final res   = await dio.get('/orgs/$id');
    final org   = res.data['data'] ?? res.data['org'] ?? res.data;
    return Organization.fromJson(org as Map<String, dynamic>);
  }

  /// Update own org details (PATCH /api/orgs/:id)
  Future<void> updateOrg(String id, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final dio   = buildDio(token: token);
    await dio.patch('/orgs/$id', data: data);
  }

  /// Create a new payment type (POST /api/orgs/:id/payment-types)
  Future<void> createPaymentType(String orgId, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final dio   = buildDio(token: token);
    await dio.post('/orgs/$orgId/payment-types', data: data);
  }
}