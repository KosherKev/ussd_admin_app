class PaymentType {
  final String id;
  final String typeId;
  final String name;
  final String? description;
  final bool enabled;
  final double minAmount;
  final double maxAmount;

  PaymentType({
    required this.id,
    required this.typeId,
    required this.name,
    this.description,
    required this.enabled,
    required this.minAmount,
    required this.maxAmount,
  });

  factory PaymentType.fromJson(Map<String, dynamic> json) {
    return PaymentType(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      typeId: (json['typeId'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: json['description']?.toString(),
      enabled: json['enabled'] == true,
      minAmount: (json['minAmount'] as num?)?.toDouble() ?? 0.0,
      maxAmount: (json['maxAmount'] as num?)?.toDouble() ?? 10000.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'typeId': typeId,
      'name': name,
      if (description != null) 'description': description,
      'enabled': enabled,
      'minAmount': minAmount,
      'maxAmount': maxAmount,
    };
  }

  PaymentType copyWith({
    String? id,
    String? typeId,
    String? name,
    String? description,
    bool? enabled,
    double? minAmount,
    double? maxAmount,
  }) {
    return PaymentType(
      id: id ?? this.id,
      typeId: typeId ?? this.typeId,
      name: name ?? this.name,
      description: description ?? this.description,
      enabled: enabled ?? this.enabled,
      minAmount: minAmount ?? this.minAmount,
      maxAmount: maxAmount ?? this.maxAmount,
    );
  }
}
