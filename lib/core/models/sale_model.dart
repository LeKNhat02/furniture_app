class SaleItem {
  final String productId;
  final String productName;
  final int quantity;
  final double price;
  final double discount;
  
  SaleItem({
    required this.productId,
    this.productName = '',
    required this.quantity,
    required this.price,
    this.discount = 0.0,
  });

  double get subtotal => (price * quantity) - discount;

  factory SaleItem.fromJson(Map<String, dynamic> json) {
    return SaleItem(
      productId: json['product_id']?.toString() ?? '',
      productName: json['product_name'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 0,
      price: _parseDouble(json['price']),
      discount: _parseDouble(json['discount'] ?? 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'quantity': quantity,
      'price': price,
      'discount': discount,
    };
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class SaleModel {
  final String id;
  final String orderNumber;
  final String? customerId;
  final String? customerName;
  final List<SaleItem> items;
  final String paymentMethod;
  final String status; // 'pending', 'completed', 'cancelled'
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  SaleModel({
    required this.id,
    required this.orderNumber,
    this.customerId,
    this.customerName,
    required this.items,
    required this.paymentMethod,
    this.status = 'completed',
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  double get subtotal => items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  double get totalDiscount => items.fold(0.0, (sum, item) => sum + item.discount);
  double get total => subtotal - totalDiscount;

  factory SaleModel.fromJson(Map<String, dynamic> json) {
    final itemsData = json['items'] as List<dynamic>? ?? [];
    final items = itemsData.map((item) => SaleItem.fromJson(item)).toList();

    return SaleModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      orderNumber: json['order_number'] as String? ?? '',
      customerId: json['customer_id']?.toString(),
      customerName: json['customer_name'] as String?,
      items: items,
      paymentMethod: json['payment_method'] as String? ?? 'Tiền mặt',
      status: json['status'] as String? ?? 'completed',
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'order_number': orderNumber,
      'customer_id': customerId,
      'items': items.map((item) => item.toJson()).toList(),
      'payment_method': paymentMethod,
      'status': status,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  SaleModel copyWith({
    String? id,
    String? orderNumber,
    String? customerId,
    String? customerName,
    List<SaleItem>? items,
    String? paymentMethod,
    String? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SaleModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      items: items ?? this.items,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

