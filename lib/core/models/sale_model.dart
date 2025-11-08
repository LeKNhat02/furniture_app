import 'package:intl/intl.dart';

/// Sale Item Model
class SaleItem {
  final String productId; // MySQL foreign key (String)
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

  /// Tính tạm tính (giá x số lượng)
  double get itemSubtotal => price * quantity;

  /// Tính thành tiền sau giảm giá
  double get subtotal => (price * quantity) - discount;

  /// Format giá
  String getFormattedPrice() {
    final formatter = NumberFormat('#,##0', 'en_US');
    return '${formatter.format(price)} VNĐ';
  }

  /// Format giảm giá
  String getFormattedDiscount() {
    final formatter = NumberFormat('#,##0', 'en_US');
    return '${formatter.format(discount)} VNĐ';
  }

  /// Format thành tiền
  String getFormattedSubtotal() {
    final formatter = NumberFormat('#,##0', 'en_US');
    return '${formatter.format(subtotal)} VNĐ';
  }

  factory SaleItem.fromJson(Map<String, dynamic> json) {
    return SaleItem(
      productId: _parseString(json['product_id'] ?? json['productId']), // ✅ Convert to String
      productName: json['product_name'] as String? ?? json['productName'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 0,
      price: _parseDouble(json['price']),
      discount: _parseDouble(json['discount'] ?? 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'price': price,
      'discount': discount,
    };
  }

  /// Helper function để parse String an toàn
  static String _parseString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is int) return value.toString();
    if (value is double) return value.toString();
    return value.toString();
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  @override
  String toString() => 'SaleItem(productId: $productId, quantity: $quantity, subtotal: $subtotal)';
}

/// Sale Model
class SaleModel {
  final String id; // ✅ Đổi thành String (MySQL auto-increment ID)
  final String orderNumber;
  final String? customerId; // ✅ Đổi thành String? (MySQL foreign key)
  final String? customerName;
  final String? customerPhone;
  final List<SaleItem> items;
  final String paymentMethod; // cash, transfer
  final String status; // pending, completed, cancelled
  final bool isPaid;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  SaleModel({
    required this.id,
    required this.orderNumber,
    this.customerId,
    this.customerName,
    this.customerPhone,
    required this.items,
    required this.paymentMethod,
    this.status = 'pending',
    this.isPaid = false,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  /// Tính tạm tính (tổng giá x số lượng)
  double get subtotal => items.fold(0.0, (sum, item) => sum + item.itemSubtotal);

  /// Tính tổng giảm giá
  double get totalDiscount => items.fold(0.0, (sum, item) => sum + item.discount);

  /// Tính tổng tiền (tạm tính - giảm giá)
  double get total => subtotal - totalDiscount;

  /// Số lượng items
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  factory SaleModel.fromJson(Map<String, dynamic> json) {
    final itemsData = json['items'] as List<dynamic>? ?? [];
    final items = itemsData
        .map((item) => SaleItem.fromJson(item as Map<String, dynamic>))
        .toList();

    return SaleModel(
      id: SaleModel._parseString(json['id'] ?? json['_id']), // ✅ Convert to String
      orderNumber: json['order_number'] as String? ?? json['orderNumber'] as String? ?? '',
      customerId: json['customer_id'] != null || json['customerId'] != null
          ? SaleModel._parseString(json['customer_id'] ?? json['customerId']) // ✅ Convert to String
          : null,
      customerName: json['customer_name'] as String? ?? json['customerName'] as String?,
      customerPhone: json['customer_phone'] as String? ?? json['customerPhone'] as String?,
      items: items,
      paymentMethod: json['payment_method'] as String? ?? json['paymentMethod'] as String? ?? 'cash',
      status: json['status'] as String? ?? 'pending',
      isPaid: json['is_paid'] as bool? ?? json['isPaid'] as bool? ?? false,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson({bool includeId = false}) {
    return {
      if (includeId) 'id': id,
      'order_number': orderNumber,
      'customer_id': customerId,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'items': items.map((item) => item.toJson()).toList(),
      'payment_method': paymentMethod,
      'status': status,
      'is_paid': isPaid,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  SaleModel copyWith({
    String? id, // ✅ Đổi thành String?
    String? orderNumber,
    String? customerId, // ✅ Đổi thành String?
    String? customerName,
    String? customerPhone,
    List<SaleItem>? items,
    String? paymentMethod,
    String? status,
    bool? isPaid,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SaleModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      items: items ?? this.items,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      isPaid: isPaid ?? this.isPaid,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Helper function để parse String an toàn
  static String _parseString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is int) return value.toString();
    if (value is double) return value.toString();
    return value.toString();
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  // ===== FORMAT METHODS =====

  /// Format tạm tính
  String getFormattedSubtotal() {
    final formatter = NumberFormat('#,##0', 'en_US');
    return '${formatter.format(subtotal)} VNĐ';
  }

  /// Format giảm giá
  String getFormattedTotalDiscount() {
    final formatter = NumberFormat('#,##0', 'en_US');
    return '${formatter.format(totalDiscount)} VNĐ';
  }

  /// Format tổng tiền
  String getFormattedTotal() {
    final formatter = NumberFormat('#,##0', 'en_US');
    return '${formatter.format(total)} VNĐ';
  }

  /// Format ngày tạo (đầy đủ)
  String getFormattedDate() {
    return DateFormat('dd/MM/yyyy HH:mm').format(createdAt);
  }

  /// Format ngày tạo (chỉ ngày)
  String getFormattedDateOnly() {
    return DateFormat('dd/MM/yyyy').format(createdAt);
  }

  // ===== STATUS DISPLAY =====

  /// Hiển thị trạng thái
  String getStatusDisplay() {
    const statusMap = {
      'pending': 'Chưa xác nhận',
      'completed': 'Hoàn thành',
      'cancelled': 'Đã hủy',
    };
    return statusMap[status] ?? status;
  }

  /// Hiển thị trạng thái thanh toán
  String getPaymentStatusDisplay() {
    return isPaid ? '✓ Đã thanh toán' : '✗ Chưa thanh toán';
  }

  /// Hiển thị phương thức thanh toán
  String getPaymentMethodDisplay() {
    const methodMap = {
      'cash': '💵 Tiền Mặt',
      'transfer': '🏦 Chuyển Khoản',
      'card': '💳 Thẻ Tín Dụng',
      'wallet': '👝 Ví Điện Tử',
    };
    return methodMap[paymentMethod] ?? paymentMethod;
  }

  // ===== COMPUTED PROPERTIES =====

  /// Kiểm tra đơn hàng hoàn thành
  bool get isCompleted => status == 'completed';

  /// Kiểm tra đơn hàng chờ xử lý
  bool get isPending => status == 'pending';

  /// Kiểm tra đơn hàng đã hủy
  bool get isCancelled => status == 'cancelled';

  /// Kiểm tra đơn hàng chưa thanh toán
  bool get isUnpaid => !isPaid;

  /// Tính discount percent
  double getDiscountPercent() {
    if (subtotal == 0) return 0;
    return (totalDiscount / subtotal) * 100;
  }

  /// Format discount percent
  String getFormattedDiscountPercent() {
    return '${getDiscountPercent().toStringAsFixed(1)}%';
  }

  @override
  String toString() =>
      'SaleModel(id: $id, orderNumber: $orderNumber, total: $total, status: $status)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is SaleModel &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;
}