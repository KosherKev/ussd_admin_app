class UssdSessionStats {
  final String status;
  final int count;
  final double avgDuration;

  UssdSessionStats({
    required this.status,
    required this.count,
    required this.avgDuration,
  });

  factory UssdSessionStats.fromJson(Map<String, dynamic> json) {
    return UssdSessionStats(
      status: (json['_id'] ?? 'unknown').toString(),
      count: (json['count'] as num?)?.toInt() ?? 0,
      avgDuration: (json['avgDuration'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
