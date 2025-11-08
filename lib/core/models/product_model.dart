class ProductModel {
  final String id; // MySQL auto-increment ID (lưu dưới dạng String)
  final String name;
  final String category;
  final double price;
  final double cost;
  final int quantity;
  final int quantityMin;
  final String? description;
  final String? imageUrl;
  final String sku;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.cost,
    required this.quantity,
    required this.quantityMin,
    this.description,
    this.imageUrl,
    required this.sku,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: _parseString(json['id'] ?? json['_id']), // ✅ Convert to String
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      price: _parseDouble(json['price']),
      cost: _parseDouble(json['cost']),
      quantity: json['quantity'] as int? ?? 0,
      quantityMin: json['quantityMin'] as int? ?? json['quantity_min'] as int? ?? 10,
      description: json['description'] as String?,
      imageUrl: json['image'] as String? ?? json['imageUrl'] as String?,
      sku: json['sku'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? json['is_active'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson({bool includeId = false}) {
    return {
      if (includeId) 'id': id,
      'name': name,
      'category': category,
      'price': price,
      'cost': cost,
      'quantity': quantity,
      'quantityMin': quantityMin,
      'description': description,
      'sku': sku,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Computed properties
  double get profit => price - cost;
  bool get isLowStock => quantity <= quantityMin;

  // Copy with method
  ProductModel copyWith({
    String? id,
    String? name,
    double? price,
    double? cost,
    int? quantity,
    int? quantityMin,
    String? category,
    String? description,
    String? sku,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      cost: cost ?? this.cost,
      quantity: quantity ?? this.quantity,
      quantityMin: quantityMin ?? this.quantityMin,
      description: description ?? this.description,
      sku: sku ?? this.sku,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'ProductModel(id: $id, name: $name, price: $price)';

  // Helper function để parse String an toàn
  static String _parseString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is int) return value.toString();
    if (value is double) return value.toString();
    return value.toString();
  }

  // Helper function để parse double an toàn
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  // Helper function để parse int an toàn
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }
}