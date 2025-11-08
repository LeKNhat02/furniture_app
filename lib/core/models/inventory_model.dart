class InventoryTransaction {
  final String id; // ✅ String (MySQL auto-increment ID)
  final String productId; // ✅ String (MySQL foreign key)
  final String productName;
  final String type; // 'in' hoặc 'out'
  final int quantity;
  final String reason;
  final String? notes;
  final String? supplierId; // ✅ String? (MySQL foreign key)
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
      id: _parseString(json['id'] ?? json['_id']), // ✅ Convert to String
      productId: _parseString(json['product_id'] ?? json['productId']), // ✅ Convert to String
      productName: json['product_name'] as String? ?? '',
      type: json['type'] as String? ?? 'in',
      quantity: json['quantity'] as int? ?? 0,
      reason: json['reason'] as String? ?? '',
      notes: json['notes'] as String?,
      supplierId: json['supplier_id'] != null || json['supplierId'] != null
          ? _parseString(json['supplier_id'] ?? json['supplierId'])
          : null, // ✅ Convert to String?
      date: json['date'] != null
          ? DateTime.parse(json['date'].toString())
          : DateTime.now(),
      createdBy: json['created_by'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson({bool includeId = false}) {
    return {
      if (includeId) 'id': id,
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

  @override
  String toString() =>
      'InventoryTransaction(id: $id, productId: $productId, type: $type, quantity: $quantity)';

  /// Helper function để parse String an toàn
  static String _parseString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is int) return value.toString();
    if (value is double) return value.toString();
    return value.toString();
  }

  /// Helper function để parse int an toàn
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }
}