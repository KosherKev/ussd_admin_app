class Organization {
  final String id;
  final String name;
  final String? shortName;
  final String? email;
  final String? phone;
  final String? ussdNumber;
  Organization({required this.id, required this.name, this.shortName, this.email, this.phone, this.ussdNumber});
  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: (json['_id'] ?? json['id']).toString(),
      name: (json['name'] ?? '').toString(),
      shortName: json['shortName']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      ussdNumber: json['ussdNumber']?.toString(),
    );
  }
}