class InventoryTransaction {
  final String id;
  final String productId;
  final String productName;
  final String type; // 'in' hoặc 'out'
  final int quantity;
  final String reason;
  final String? notes;
  final String? supplierId;
  final DateTime date;
  final String? createdBy;
  final DateTime createdAt;

  InventoryTransaction({
    required this.id,
    required this.productId,
    this.productName = '',
    required this.type,
    required this.quantity,
    required this.reason,
    this.notes,
    this.supplierId,
    required this.date,
    this.createdBy,
    required this.createdAt,
  });

  factory InventoryTransaction.fromJson(Map<String, dynamic> json) {
    return InventoryTransaction(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? '',
      productName: json['product_name'] as String? ?? '',
      type: json['type'] as String? ?? 'in',
      quantity: json['quantity'] as int? ?? 0,
      reason: json['reason'] as String? ?? '',
      notes: json['notes'] as String?,
      supplierId: json['supplier_id']?.toString(),
      date: json['date'] != null
          ? DateTime.parse(json['date'].toString())
          : DateTime.now(),
      createdBy: json['created_by'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'product_id': productId,
      'type': type,
      'quantity': quantity,
      'reason': reason,
      'notes': notes,
      'supplier_id': supplierId,
      'date': date.toIso8601String(),
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
    };
  }

  InventoryTransaction copyWith({
    String? id,
    String? productId,
    String? productName,
    String? type,
    int? quantity,
    String? reason,
    String? notes,
    String? supplierId,
    DateTime? date,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return InventoryTransaction(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      reason: reason ?? this.reason,
      notes: notes ?? this.notes,
      supplierId: supplierId ?? this.supplierId,
      date: date ?? this.date,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

