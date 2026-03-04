class Transaction {
  final String transactionRef;
  final String organizationName;
  final String paymentType;
  final double amount;
  final double commission;
  final double netAmount;
  final String status;
  final DateTime initiatedAt;

  Transaction({
    required this.transactionRef,
    required this.organizationName,
    required this.paymentType,
    required this.amount,
    required this.commission,
    required this.netAmount,
    required this.status,
    required this.initiatedAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      transactionRef:   (json['transactionRef'] ?? '').toString(),
      organizationName: (json['organizationName'] ?? '').toString(),
      paymentType:      (json['paymentType'] ?? '').toString(),
      amount:           (json['amount'] as num?)?.toDouble() ?? 0.0,
      commission:       (json['commission'] as num?)?.toDouble() ?? 0.0,
      netAmount:        (json['netAmount'] as num?)?.toDouble() ?? 0.0,
      status:           (json['status'] ?? '').toString(),
      initiatedAt:      _parseDate(json['initiatedAt']),
    );
  }

  /// Safely parse a date from any format the API might return:
  /// - null          → DateTime.now() (safe fallback)
  /// - int           → epoch milliseconds (some APIs return Unix timestamps)
  /// - String        → ISO 8601 via DateTime.parse, FormatException → now()
  static DateTime _parseDate(dynamic raw) {
    if (raw == null) return DateTime.now();
    if (raw is int)  return DateTime.fromMillisecondsSinceEpoch(raw);
    try {
      return DateTime.parse(raw.toString());
    } catch (_) {
      return DateTime.now();
    }
  }
}
