class KeyUsage {
  final KeyInfo key;
  final Period period;
  final TransactionStats transactions;
  final WebhookStats webhooks;
  final List<DailyStat> daily;

  const KeyUsage({
    required this.key,
    required this.period,
    required this.transactions,
    required this.webhooks,
    required this.daily,
  });

  factory KeyUsage.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return KeyUsage(
      key:          KeyInfo.fromJson(data['key'] as Map<String, dynamic>),
      period:       Period.fromJson(data['period'] as Map<String, dynamic>),
      transactions: TransactionStats.fromJson(data['transactions'] as Map<String, dynamic>),
      webhooks:     WebhookStats.fromJson(data['webhooks'] as Map<String, dynamic>),
      daily: (data['daily'] as List<dynamic>? ?? [])
          .map((d) => DailyStat.fromJson(d as Map<String, dynamic>))
          .toList(),
    );
  }
}

class KeyInfo {
  final String id;
  final String projectName;
  final String environment;
  final String keyPrefix;
  final bool isActive;
  final String? lastUsedAt;
  final LifetimeUsage lifetimeUsage;

  const KeyInfo({
    required this.id,
    required this.projectName,
    required this.environment,
    required this.keyPrefix,
    required this.isActive,
    this.lastUsedAt,
    required this.lifetimeUsage,
  });

  factory KeyInfo.fromJson(Map<String, dynamic> json) => KeyInfo(
        id:           json['id'] as String,
        projectName:  json['projectName'] as String,
        environment:  json['environment'] as String,
        keyPrefix:    json['keyPrefix'] as String,
        isActive:     json['isActive'] as bool,
        lastUsedAt:   json['lastUsedAt'] as String?,
        lifetimeUsage: LifetimeUsage.fromJson(
            json['lifetimeUsage'] as Map<String, dynamic>),
      );
}

class LifetimeUsage {
  final int totalRequests;
  final int totalPayments;
  final double totalVolume;

  const LifetimeUsage({
    required this.totalRequests,
    required this.totalPayments,
    required this.totalVolume,
  });

  factory LifetimeUsage.fromJson(Map<String, dynamic> json) => LifetimeUsage(
        totalRequests: json['totalRequests'] as int,
        totalPayments: json['totalPayments'] as int,
        totalVolume:   (json['totalVolume'] as num).toDouble(),
      );
}

class Period {
  final String from;
  final String to;
  final int days;

  const Period({required this.from, required this.to, required this.days});

  factory Period.fromJson(Map<String, dynamic> json) => Period(
        from: json['from'] as String,
        to:   json['to']   as String,
        days: json['days'] as int,
      );
}

class TransactionStats {
  final int total;
  final int completed;
  final int failed;
  final int processing;
  final double? successRate;
  final double totalVolume;
  final double totalNetVolume;
  final double totalCommission;
  final double? avgAmount;
  final ChannelBreakdown byChannel;

  const TransactionStats({
    required this.total,
    required this.completed,
    required this.failed,
    required this.processing,
    this.successRate,
    required this.totalVolume,
    required this.totalNetVolume,
    required this.totalCommission,
    this.avgAmount,
    required this.byChannel,
  });

  factory TransactionStats.fromJson(Map<String, dynamic> json) =>
      TransactionStats(
        total:           json['total']          as int,
        completed:       json['completed']      as int,
        failed:          json['failed']         as int,
        processing:      json['processing']     as int,
        successRate:     (json['successRate']   as num?)?.toDouble(),
        totalVolume:     (json['totalVolume']   as num).toDouble(),
        totalNetVolume:  (json['totalNetVolume'] as num).toDouble(),
        totalCommission: (json['totalCommission'] as num).toDouble(),
        avgAmount:       (json['avgAmount']     as num?)?.toDouble(),
        byChannel: ChannelBreakdown.fromJson(
            json['byChannel'] as Map<String, dynamic>),
      );
}

class ChannelBreakdown {
  final int mobileMoney;
  final int card;
  final int ussdBridge;

  const ChannelBreakdown({
    required this.mobileMoney,
    required this.card,
    required this.ussdBridge,
  });

  factory ChannelBreakdown.fromJson(Map<String, dynamic> json) =>
      ChannelBreakdown(
        mobileMoney: json['mobileMoney'] as int? ?? 0,
        card:        json['card']        as int? ?? 0,
        ussdBridge:  json['ussdBridge']  as int? ?? 0,
      );
}

class WebhookStats {
  final int total;
  final int delivered;
  final int failed;
  final int retrying;
  final double? successRate;
  final double? avgAttempts;

  const WebhookStats({
    required this.total,
    required this.delivered,
    required this.failed,
    required this.retrying,
    this.successRate,
    this.avgAttempts,
  });

  factory WebhookStats.fromJson(Map<String, dynamic> json) => WebhookStats(
        total:       json['total']       as int,
        delivered:   json['delivered']   as int,
        failed:      json['failed']      as int,
        retrying:    json['retrying']    as int,
        successRate: (json['successRate'] as num?)?.toDouble(),
        avgAttempts: (json['avgAttempts'] as num?)?.toDouble(),
      );
}

class DailyStat {
  final String date;
  final int total;
  final int completed;
  final double volume;

  const DailyStat({
    required this.date,
    required this.total,
    required this.completed,
    required this.volume,
  });

  factory DailyStat.fromJson(Map<String, dynamic> json) => DailyStat(
        date:      json['date']      as String,
        total:     json['total']     as int,
        completed: json['completed'] as int,
        volume:    (json['volume']   as num).toDouble(),
      );
}
