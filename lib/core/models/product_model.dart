
class Product {
  final int id;
  final String name;
  final String category;
  final double price;
  final double cost;
  final int quantity;
  final int quantityMin;
  final String? description;
  final String? sku;
  final bool isActive;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.cost,
    required this.quantity,
    required this.quantityMin,
    this.description,
    this.sku,
    required this.isActive,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      category: json['category'] as String,
      price: (json['price'] as num).toDouble(),
      cost: (json['cost'] as num).toDouble(),
      quantity: json['quantity'] as int,
      quantityMin: json['quantity_min'] as int? ?? 10,
      description: json['description'] as String?,
      sku: json['sku'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'cost': cost,
      'quantity': quantity,
      'quantity_min': quantityMin,
      'description': description,
      'sku': sku,
      'is_active': isActive,
    };
  }

  double get profit => price - cost;

  bool get isLowStock => quantity <= quantityMin;
}