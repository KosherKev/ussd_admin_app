import 'package:shared_preferences/shared_preferences.dart';
import '../http/client.dart';
import '../models/paged.dart';
import '../models/transaction.dart';
import '../models/org_summary.dart';
import '../models/ussd_session_stats.dart';

class ReportsService {
  Future<Paged<Transaction>> getTransactions({
    String? organizationId,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 10,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final dio = buildDio(token: token);
    
    final params = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (organizationId != null) 'organizationId': organizationId,
      if (status != null) 'status': status,
      if (startDate != null) 'startDate': startDate.toIso8601String(),
      if (endDate != null) 'endDate': endDate.toIso8601String(),
    };
    
    final res = await dio.get('/reports/transactions', queryParameters: params);
    
    return Paged.fromJson(
      res.data as Map<String, dynamic>,
      (m) => Transaction.fromJson(m),
    );
  }

  Future<List<OrgSummaryStats>> getOrgSummary(
    String orgId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final dio = buildDio(token: token);
    
    final params = <String, dynamic>{
      if (startDate != null) 'startDate': startDate.toIso8601String(),
      if (endDate != null) 'endDate': endDate.toIso8601String(),
    };
    
    final res = await dio.get('/reports/orgs/$orgId/summary', queryParameters: params);
    final data = res.data as Map<String, dynamic>;
    final stats = (data['stats'] as List? ?? [])
        .cast<Map<String, dynamic>>()
        .map((m) => OrgSummaryStats.fromJson(m))
        .toList();
    
    return stats;
  }

  Future<List<UssdSessionStats>> getUssdSessions({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final dio = buildDio(token: token);
    
    final params = <String, dynamic>{
      if (startDate != null) 'startDate': startDate.toIso8601String(),
      if (endDate != null) 'endDate': endDate.toIso8601String(),
    };
    
    final res = await dio.get('/reports/ussd/sessions', queryParameters: params);
    final data = res.data as Map<String, dynamic>;
    final stats = (data['stats'] as List? ?? [])
        .cast<Map<String, dynamic>>()
        .map((m) => UssdSessionStats.fromJson(m))
        .toList();
    
    return stats;
  }
}
