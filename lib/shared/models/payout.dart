class Payout {
  final String id;
  final String organizationId;
  final String organizationName;
  final double netAmount;
  final String status;
  final DateTime? scheduledDate;
  final String? payoutRef;

  Payout({
    required this.id,
    required this.organizationId,
    required this.organizationName,
    required this.netAmount,
    required this.status,
    this.scheduledDate,
    this.payoutRef,
  });

  factory Payout.fromJson(Map<String, dynamic> json) {
    final org = json['organizationId'] as Map<String, dynamic>?;
    return Payout(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      organizationId: (org?['_id'] ?? json['organizationId'] ?? '').toString(),
      organizationName: (org?['name'] ?? '').toString(),
      netAmount: (json['netAmount'] as num?)?.toDouble() ?? 0.0,
      status: (json['payout']?['status'] ?? json['status'] ?? 'pending').toString(),
      scheduledDate: json['payout']?['scheduledDate'] != null
          ? DateTime.parse(json['payout']['scheduledDate'])
          : null,
      payoutRef: json['payoutRef']?.toString(),
    );
  }
}
