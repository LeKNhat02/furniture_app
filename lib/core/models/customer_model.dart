class CustomerModel {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? address;
  final String? city;
  final double totalSpent;
  final int totalOrders;
  final String? notes;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.address,
    this.city,
    this.totalSpent = 0,
    this.totalOrders = 0,
    this.notes,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      totalSpent: _parseDouble(json['totalSpent']),
      totalOrders: json['totalOrders'] as int? ?? 0,
      notes: json['notes'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'city': city,
      'totalSpent': totalSpent,
      'totalOrders': totalOrders,
      'notes': notes,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  CustomerModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    String? city,
    double? totalSpent,
    int? totalOrders,
    String? notes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      city: city ?? this.city,
      totalSpent: totalSpent ?? this.totalSpent,
      totalOrders: totalOrders ?? this.totalOrders,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'CustomerModel(id: $id, name: $name, phone: $phone, totalSpent: $totalSpent)';

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}