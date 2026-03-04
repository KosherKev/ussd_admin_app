class Subscription {
  final String id;
  final String organizationId;
  final String status;
  final String billingPeriod;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? gracePeriodEndDate;
  final bool ussdEnabled;

  Subscription({
    required this.id,
    required this.organizationId,
    required this.status,
    required this.billingPeriod,
    this.startDate,
    this.endDate,
    this.gracePeriodEndDate,
    required this.ussdEnabled,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    // Normalise: API may return the subscription object nested under
    // json['subscription'], or flat at json root. Always read from `sub`.
    // For fields that may appear at either level (e.g. ussdEnabled), fall
    // back to the root json after checking sub — never double-reading.
    final sub = (json['subscription'] as Map<String, dynamic>?) ?? json;
    return Subscription(
      id:                 (sub['_id'] ?? sub['id'] ?? '').toString(),
      organizationId:     (sub['organizationId'] ?? '').toString(),
      status:             (sub['status'] ?? 'inactive').toString(),
      billingPeriod:      (sub['billingPeriod'] ?? 'monthly').toString(),
      startDate:          sub['startDate'] != null ? _parseDate(sub['startDate']) : null,
      endDate:            sub['endDate'] != null ? _parseDate(sub['endDate']) : null,
      gracePeriodEndDate: sub['gracePeriodEndDate'] != null ? _parseDate(sub['gracePeriodEndDate']) : null,
      // ussdEnabled may live in sub (nested) or at json root (flat) — check both
      ussdEnabled:        (sub['ussdEnabled'] ?? json['ussdEnabled']) == true,
    );
  }

  /// Safe date parse — handles ISO strings and epoch ints.
  static DateTime _parseDate(dynamic raw) {
    if (raw is int) return DateTime.fromMillisecondsSinceEpoch(raw);
    try { return DateTime.parse(raw.toString()); } catch (_) { return DateTime.now(); }
  }

  bool get isActive => status == 'active';
  bool get isCancelled => status == 'cancelled';
  bool get isExpired => endDate != null && DateTime.now().isAfter(endDate!);
}
