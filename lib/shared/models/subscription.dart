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
    final sub = json['subscription'] as Map<String, dynamic>? ?? json;
    return Subscription(
      id: (sub['_id'] ?? sub['id'] ?? '').toString(),
      organizationId: (sub['organizationId'] ?? '').toString(),
      status: (sub['status'] ?? 'inactive').toString(),
      billingPeriod: (sub['billingPeriod'] ?? 'monthly').toString(),
      startDate: sub['startDate'] != null ? DateTime.parse(sub['startDate']) : null,
      endDate: sub['endDate'] != null ? DateTime.parse(sub['endDate']) : null,
      gracePeriodEndDate: sub['gracePeriodEndDate'] != null 
          ? DateTime.parse(sub['gracePeriodEndDate']) 
          : null,
      ussdEnabled: json['ussdEnabled'] == true || sub['ussdEnabled'] == true,
    );
  }

  bool get isActive => status == 'active';
  bool get isCancelled => status == 'cancelled';
  bool get isExpired => endDate != null && DateTime.now().isAfter(endDate!);
}
