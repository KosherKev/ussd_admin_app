import 'package:shared_preferences/shared_preferences.dart';
import '../http/client.dart';
import '../models/webhook_delivery.dart';
import '../models/api_key.dart';
import '../models/paged.dart';

class DeveloperService {
  Future<KeyUsage?> getKeyUsage(String keyId, {String? from, String? to}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final dio   = buildDio(token: token);

    final params = <String, dynamic>{};
    if (from != null) params['from'] = from;
    if (to   != null) params['to']   = to;

    final res = await dio.get('/v1/keys/$keyId/usage', queryParameters: params);
    if (res.data['success'] == true) {
      return KeyUsage.fromJson(res.data as Map<String, dynamic>);
    }
    return null;
  }

  Future<Paged<WebhookDelivery>> getWebhookDeliveries({
    String? transactionRef,
    String? status,
    String? event,
    int page = 1,
    int limit = 20,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final dio   = buildDio(token: token);

    final params = <String, dynamic>{'page': page, 'limit': limit};
    if (transactionRef != null) params['transactionRef'] = transactionRef;
    if (status         != null) params['status']         = status;
    if (event          != null) params['event']          = event;

    final res = await dio.get('/v1/webhooks/deliveries', queryParameters: params);
    // Webhook deliveries endpoint returns the array under 'data', not 'items'.
    // Pass itemsKey: 'data' so the generic Paged parser reads the right key.
    return Paged.fromJson(
      res.data as Map<String, dynamic>,
      (j) => WebhookDelivery.fromJson(j),
      itemsKey: 'data',
    );
  }

  Future<WebhookDeliveryDetail> getWebhookDelivery(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final dio   = buildDio(token: token);

    final res = await dio.get('/v1/webhooks/deliveries/$id');
    return WebhookDeliveryDetail.fromJson(
        res.data['data'] as Map<String, dynamic>);
  }
}
