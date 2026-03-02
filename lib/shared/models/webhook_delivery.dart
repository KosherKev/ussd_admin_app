class WebhookDelivery {
  final String id;
  final String transactionRef;
  final String event;
  final String targetUrl;
  final String status;
  final int attemptCount;
  final String? deliveredAt;
  final String? nextRetryAt;
  final WebhookAttempt? lastAttempt;
  final String createdAt;

  const WebhookDelivery({
    required this.id,
    required this.transactionRef,
    required this.event,
    required this.targetUrl,
    required this.status,
    required this.attemptCount,
    this.deliveredAt,
    this.nextRetryAt,
    this.lastAttempt,
    required this.createdAt,
  });

  factory WebhookDelivery.fromJson(Map<String, dynamic> json) =>
      WebhookDelivery(
        id:             json['id'] as String,
        transactionRef: json['transactionRef'] as String,
        event:          json['event'] as String,
        targetUrl:      json['targetUrl'] as String,
        status:         json['status'] as String,
        attemptCount:   json['attemptCount'] as int,
        deliveredAt:    json['deliveredAt'] as String?,
        nextRetryAt:    json['nextRetryAt'] as String?,
        lastAttempt: json['lastAttempt'] != null
            ? WebhookAttempt.fromJson(json['lastAttempt'] as Map<String, dynamic>)
            : null,
        createdAt: json['createdAt'] as String,
      );
}

class WebhookAttempt {
  final int? attemptNumber;
  final String? attemptedAt;
  final int? responseStatus;
  final String? responseBody;
  final int? durationMs;
  final String? error;

  const WebhookAttempt({
    this.attemptNumber,
    this.attemptedAt,
    this.responseStatus,
    this.responseBody,
    this.durationMs,
    this.error,
  });

  factory WebhookAttempt.fromJson(Map<String, dynamic> json) => WebhookAttempt(
        attemptNumber:  json['attemptNumber'] as int?,
        attemptedAt:    json['attemptedAt']   as String?,
        responseStatus: json['responseStatus'] as int?,
        responseBody:   json['responseBody']  as String?,
        durationMs:     json['durationMs']    as int?,
        error:          json['error']         as String?,
      );
}

class WebhookDeliveryDetail extends WebhookDelivery {
  final String? projectName;
  final Map<String, dynamic>? payload;
  final List<WebhookAttempt> attempts;

  const WebhookDeliveryDetail({
    required super.id,
    required super.transactionRef,
    required super.event,
    required super.targetUrl,
    required super.status,
    required super.attemptCount,
    super.deliveredAt,
    super.nextRetryAt,
    super.lastAttempt,
    required super.createdAt,
    this.projectName,
    this.payload,
    required this.attempts,
  });

  factory WebhookDeliveryDetail.fromJson(Map<String, dynamic> json) =>
      WebhookDeliveryDetail(
        id:             json['id'] as String,
        transactionRef: json['transactionRef'] as String,
        event:          json['event'] as String,
        targetUrl:      json['targetUrl'] as String,
        status:         json['status'] as String,
        attemptCount:   json['attemptCount'] as int,
        deliveredAt:    json['deliveredAt'] as String?,
        nextRetryAt:    json['nextRetryAt'] as String?,
        createdAt:      json['createdAt'] as String,
        projectName:    json['projectName'] as String?,
        payload: json['payload'] != null
            ? Map<String, dynamic>.from(json['payload'] as Map)
            : null,
        attempts: (json['attempts'] as List<dynamic>? ?? [])
            .map((a) => WebhookAttempt.fromJson(a as Map<String, dynamic>))
            .toList(),
      );
}
