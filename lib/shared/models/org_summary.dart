class OrgSummaryStats {
  final String paymentTypeId;
  final String paymentTypeName;
  final int count;
  final double totalAmount;

  OrgSummaryStats({
    required this.paymentTypeId,
    required this.paymentTypeName,
    required this.count,
    required this.totalAmount,
  });

  factory OrgSummaryStats.fromJson(Map<String, dynamic> json) {
    return OrgSummaryStats(
      paymentTypeId: (json['_id'] ?? '').toString(),
      paymentTypeName: (json['name'] ?? json['_id'] ?? '').toString(),
      count: (json['count'] as num?)?.toInt() ?? 0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
