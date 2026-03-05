import 'package:shared_preferences/shared_preferences.dart';
import '../http/client.dart';
import '../models/webhook_delivery.dart';
import '../models/api_key.dart';
import '../models/paged.dart';

class DeveloperService {
  /// GET /api/orgs/:orgId/usage?from=<iso>&to=<iso>
  /// Bearer JWT — no API key required.
  Future<KeyUsage?> getOrgUsage(String orgId,
      {String? from, String? to}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final dio   = buildDio(token: token);

    final params = <String, dynamic>{};
    if (from != null) params['from'] = from;
    if (to   != null) params['to']   = to;

    final res = await dio.get('/orgs/$orgId/usage',
        queryParameters: params);
    if (res.data['success'] == true) {
      return KeyUsage.fromJson(res.data as Map<String, dynamic>);
    }
    return null;
  }

  /// GET /api/orgs/:orgId/webhook-deliveries
  /// Bearer JWT — no API key required.
  Future<Paged<WebhookDelivery>> getWebhookDeliveries(
    String orgId, {
    String? transactionRef,
    String? status,
    String? event,
    int page  = 1,
    int limit = 20,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final dio   = buildDio(token: token);

    final params = <String, dynamic>{'page': page, 'limit': limit};
    if (transactionRef != null) params['transactionRef'] = transactionRef;
    if (status         != null) params['status']         = status;
    if (event          != null) params['event']          = event;

    final res = await dio.get('/orgs/$orgId/webhook-deliveries',
        queryParameters: params);
    // Response: { success, page, limit, total, items: [...] }
    return Paged.fromJson(
      res.data as Map<String, dynamic>,
      (j) => WebhookDelivery.fromJson(j),
    );
  }

  /// GET /api/orgs/:orgId/webhook-deliveries/:id  (detail)
  Future<WebhookDeliveryDetail> getWebhookDelivery(
      String orgId, String id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final dio   = buildDio(token: token);

    final res  = await dio.get('/orgs/$orgId/webhook-deliveries/$id');
    final data = res.data as Map<String, dynamic>;
    // May be wrapped under 'item' or flat
    final item = data['item'] ?? data['data'] ?? data;
    return WebhookDeliveryDetail.fromJson(item as Map<String, dynamic>);
  }

  // ── API Key management (GET/POST/DELETE /api/v1/keys) ─────────────────────
  // These also use Bearer JWT; the server scopes results to the caller's org.

  /// GET /api/v1/keys
  Future<List<OrgApiKey>> listKeys() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final dio   = buildDio(token: token);

    final res  = await dio.get('/v1/keys');
    final data = res.data as Map<String, dynamic>;
    final list = data['items'] ?? data['data'] ?? data['keys'] ?? [];
    return (list as List)
        .cast<Map<String, dynamic>>()
        .map(OrgApiKey.fromJson)
        .toList();
  }

  /// POST /api/v1/keys — provision a new key
  Future<NewApiKey> createKey({
    required String projectName,
    required String environment,
    String? webhookUrl,
    List<String> scopes = const ['payments:write', 'payments:read'],
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final dio   = buildDio(token: token);

    final body = <String, dynamic>{
      'projectName': projectName,
      'environment': environment,
      'scopes': scopes,
      if (webhookUrl != null && webhookUrl.isNotEmpty)
        'webhookUrl': webhookUrl,
    };

    final res  = await dio.post('/v1/keys', data: body);
    final data = res.data as Map<String, dynamic>;
    return NewApiKey.fromJson(data);
  }

  /// DELETE /api/v1/keys/:id — revoke a key
  Future<void> revokeKey(String keyId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final dio   = buildDio(token: token);
    await dio.delete('/v1/keys/$keyId');
  }
}
