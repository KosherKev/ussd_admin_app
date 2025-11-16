class Paged<T> {
  final bool success;
  final int page;
  final int limit;
  final int total;
  final List<T> items;
  Paged({required this.success, required this.page, required this.limit, required this.total, required this.items});
  static Paged<R> fromJson<R>(Map<String, dynamic> json, R Function(Map<String, dynamic>) convert) {
    final list = (json['items'] as List? ?? []).cast<Map<String, dynamic>>().map(convert).toList();
    return Paged<R>(
      success: json['success'] == true,
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? list.length,
      total: (json['total'] as num?)?.toInt() ?? list.length,
      items: list,
    );
  }
}