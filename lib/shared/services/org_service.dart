import 'package:shared_preferences/shared_preferences.dart';
import '../http/client.dart';
import '../models/paged.dart';
import '../models/organization.dart';

class OrgService {
  Future<Paged<Organization>> list({int page = 1, int limit = 10, String? q}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final dio = buildDio(token: token);
    final res = await dio.get('/orgs', queryParameters: {
      'page': page,
      'limit': limit,
      if (q != null && q.isNotEmpty) 'q': q,
    });
    return Paged.fromJson(res.data as Map<String, dynamic>, (m) => Organization.fromJson(m));
  }
}