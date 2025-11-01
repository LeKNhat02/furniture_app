class PromotionModel {
  final String id;
  final String name;
  final String? description;
  final String discountType; // 'percentage' hoặc 'fixed_amount'
  final double discountValue;
  final double? minPurchase;
  final double? maxDiscount;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PromotionModel({
    required this.id,
    required this.name,
    this.description,
    required this.discountType,
    required this.discountValue,
    this.minPurchase,
    this.maxDiscount,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  bool get isExpired => DateTime.now().isAfter(endDate);
  bool get isValid => isActive && !isExpired && DateTime.now().isAfter(startDate);

  double calculateDiscount(double purchaseAmount) {
    if (minPurchase != null && purchaseAmount < minPurchase!) {
      return 0.0;
    }

    double discount = 0.0;
    if (discountType == 'percentage') {
      discount = purchaseAmount * (discountValue / 100);
      if (maxDiscount != null && discount > maxDiscount!) {
        discount = maxDiscount!;
      }
    } else {
      discount = discountValue;
      if (discount > purchaseAmount) {
        discount = purchaseAmount;
      }
    }

    return discount;
  }

  factory PromotionModel.fromJson(Map<String, dynamic> json) {
    return PromotionModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      discountType: json['discount_type'] as String? ?? 'percentage',
      discountValue: _parseDouble(json['discount_value']),
      minPurchase: json['min_purchase'] != null ? _parseDouble(json['min_purchase']) : null,
      maxDiscount: json['max_discount'] != null ? _parseDouble(json['max_discount']) : null,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'].toString())
          : DateTime.now(),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'].toString())
          : DateTime.now(),
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
      'description': description,
      'discount_type': discountType,
      'discount_value': discountValue,
      'min_purchase': minPurchase,
      'max_discount': maxDiscount,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  PromotionModel copyWith({
    String? id,
    String? name,
    String? description,
    String? discountType,
    double? discountValue,
    double? minPurchase,
    double? maxDiscount,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PromotionModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      minPurchase: minPurchase ?? this.minPurchase,
      maxDiscount: maxDiscount ?? this.maxDiscount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  @override
  String toString() => 'PromotionModel(id: $id, name: $name, discount: $discountValue)';
}

