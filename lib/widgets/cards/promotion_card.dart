import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PromotionCard extends StatelessWidget {
  final String id;
  final String name;
  final String? description;
  final String discountType;
  final double discountValue;
  final double? minPurchase;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const PromotionCard({
    Key? key,
    required this.id,
    required this.name,
    this.description,
    required this.discountType,
    required this.discountValue,
    this.minPurchase,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.onTap,
    this.onDelete,
  }) : super(key: key);

  bool get isExpired => DateTime.now().isAfter(endDate);
  bool get isNotStarted => DateTime.now().isBefore(startDate);

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,##0', 'en_US');
    return '${formatter.format(amount)}₫';
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _getDiscountLabel() {
    if (discountType == 'percentage') {
      return '${discountValue.toStringAsFixed(0)}%';
    } else {
      return _formatCurrency(discountValue);
    }
  }

  Color _getStatusColor() {
    if (!isActive) return Colors.grey;
    if (isExpired) return const Color(0xFFF44336);
    if (isNotStarted) return const Color(0xFFFFC107);
    return const Color(0xFF4CAF50);
  }

  String _getStatusLabel() {
    if (!isActive) return 'Đã tắt';
    if (isExpired) return 'Hết hạn';
    if (isNotStarted) return 'Sắp diễn ra';
    return 'Đang diễn ra';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        _getDiscountLabel(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor().withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getStatusLabel(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (description != null && description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    description!,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Từ: ${_formatDate(startDate)}',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Đến: ${_formatDate(endDate)}',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
              if (minPurchase != null && minPurchase! > 0) ...[
                const SizedBox(height: 8),
                Text(
                  'Mua tối thiểu: ${_formatCurrency(minPurchase!)}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
              if (onDelete != null) ...[
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      onPressed: onDelete,
                      color: const Color(0xFFF44336),
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}