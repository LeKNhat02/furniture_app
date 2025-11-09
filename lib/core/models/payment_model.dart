import 'package:intl/intl.dart';

class PaymentModel {
  final String id; // MySQL auto-increment ID (lưu dưới dạng String)
  final String saleId; // MySQL foreign key (String)
  final String? saleName;
  final String customerId; // MySQL foreign key (String)
  final String? customerName;
  final double amount;
  final String paymentMethod; // cash, transfer
  final String status; // completed, pending, failed
  final DateTime paymentDate;
  final String? transactionId;
  final String? bankName;
  final String? accountNumber;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  PaymentModel({
    required this.id,
    required this.saleId,
    this.saleName,
    required this.customerId,
    this.customerName,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    required this.paymentDate,
    this.transactionId,
    this.bankName,
    this.accountNumber,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  /// Parse từ JSON
  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: _parseString(json['id'] ?? json['_id']), // ✅ Convert to String
      saleId: _parseString(json['sale_id'] ?? json['saleId']), // ✅ Convert to String
      saleName: json['sale_name'] ?? json['saleName'],
      customerId: _parseString(json['customer_id'] ?? json['customerId']), // ✅ Convert to String
      customerName: json['customerName'] ?? json['customer_name'],
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['paymentMethod'] ?? json['payment_method'] ?? 'cash',
      status: json['status'] ?? 'pending',
      paymentDate: json['payment_date'] != null
          ? DateTime.parse(json['payment_date'].toString())
          : json['paymentDate'] != null
          ? DateTime.parse(json['paymentDate'].toString())
          : DateTime.now(),
      transactionId: json['transaction_id'] ?? json['transactionId'],
      bankName: json['bank_name'] ?? json['bankName'],
      accountNumber: json['account_number'] ?? json['accountNumber'],
      notes: json['notes'],
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

  /// Convert to JSON
  Map<String, dynamic> toJson({bool includeId = false}) => {
    if (includeId) 'id': id,
    'sale_id': saleId,
    'customer_id': customerId,
    'amount': amount,
    'payment_method': paymentMethod,
    'status': status,
    'payment_date': paymentDate.toIso8601String(),
    if (transactionId != null) 'transaction_id': transactionId,
    if (bankName != null) 'bank_name': bankName,
    if (accountNumber != null) 'account_number': accountNumber,
    if (notes != null) 'notes': notes,
  };

  /// Tạo copy với thay đổi
  PaymentModel copyWith({
    String? id,
    String? saleId,
    String? saleName,
    String? customerId,
    String? customerName,
    double? amount,
    String? paymentMethod,
    String? status,
    DateTime? paymentDate,
    String? transactionId,
    String? bankName,
    String? accountNumber,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      saleName: saleName ?? this.saleName,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      paymentDate: paymentDate ?? this.paymentDate,
      transactionId: transactionId ?? this.transactionId,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Format số tiền
  String getFormattedAmount() {
    final formatter = NumberFormat('#,##0', 'en_US');
    return '${formatter.format(amount)} VNĐ';
  }

  /// Get status display
  String getStatusDisplay() {
    const statusMap = {
      'completed': 'Hoàn Thành',
      'pending': 'Chờ Xử Lý',
      'failed': 'Thất Bại',
    };
    return statusMap[status] ?? status;
  }

  /// Get payment method display
  String getPaymentMethodDisplay() {
    const methodMap = {
      'cash': 'Tiền Mặt',
      'transfer': 'Chuyển Khoản',
    };
    return methodMap[paymentMethod] ?? paymentMethod;
  }

  /// Format ngày thanh toán
  String getFormattedPaymentDate() {
    return DateFormat('dd/MM/yyyy').format(paymentDate);
  }

  /// Format ngày thanh toán (chi tiết)
  String getFormattedPaymentDateTime() {
    return DateFormat('dd/MM/yyyy HH:mm').format(paymentDate);
  }

  /// Format ngày tạo
  String getFormattedCreatedDate() {
    return DateFormat('dd/MM/yyyy HH:mm').format(createdAt);
  }

  /// Check xem thanh toán hoàn thành
  bool get isCompleted => status == 'completed';

  /// Check xem thanh toán đang chờ
  bool get isPending => status == 'pending';

  /// Check xem là tiền mặt
  bool get isCash => paymentMethod == 'cash';

  /// Check xem là chuyển khoản
  bool get isTransfer => paymentMethod == 'transfer';

  @override
  String toString() =>
      'PaymentModel(id: $id, saleId: $saleId, amount: $amount, status: $status)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is PaymentModel &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;

  /// Helper function để parse String an toàn
  static String _parseString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is int) return value.toString();
    if (value is double) return value.toString();
    return value.toString();
  }
}