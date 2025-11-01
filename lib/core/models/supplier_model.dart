class SupplierModel {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? address;
  final String? city;
  final String? contactPerson;
  final String? notes;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SupplierModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.address,
    this.city,
    this.contactPerson,
    this.notes,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    return SupplierModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      contactPerson: json['contact_person'] as String? ?? json['contactPerson'] as String?,
      notes: json['notes'] as String?,
      isActive: json['is_active'] as bool? ?? json['isActive'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
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
      'contact_person': contactPerson,
      'notes': notes,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  SupplierModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    String? city,
    String? contactPerson,
    String? notes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SupplierModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      city: city ?? this.city,
      contactPerson: contactPerson ?? this.contactPerson,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'SupplierModel(id: $id, name: $name, phone: $phone)';
}

