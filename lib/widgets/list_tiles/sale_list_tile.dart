import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SaleListTile extends StatelessWidget {
  final String id;
  final String orderNumber;
  final String? customerName;
  final double total;
  final int itemCount;
  final String status;
  final bool isPaid;
  final DateTime createdAt;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const SaleListTile({
    Key? key,
    required this.id,
    required this.orderNumber,
    this.customerName,
    required this.total,
    required this.itemCount,
    required this.status,
    required this.isPaid,
    required this.createdAt,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,##0', 'en_US');
    return '${formatter.format(amount)}₫';
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM HH:mm').format(date);
  }

  Color _getStatusColor() {
    switch (status) {
      case 'completed':
        return const Color(0xFF4CAF50);
      case 'pending':
        return const Color(0xFFFFC107);
      case 'cancelled':
        return const Color(0xFFF44336);
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel() {
    const map = {
      'completed': 'Hoàn thành',
      'pending': 'Chờ xác nhận',
      'cancelled': 'Đã hủy',
    };
    return map[status] ?? status;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getStatusColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.receipt,
            color: _getStatusColor(),
          ),
        ),
        title: Text(
          orderNumber,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (customerName != null && customerName!.isNotEmpty)
              Text(
                'KH: $customerName',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 12, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  _formatDate(createdAt),
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(0.15),
                    borderRadius: BorderRadius.circular(3),
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
          ],
        ),
        trailing: SizedBox(
          width: 130,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatCurrency(total),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: isPaid
                          ? const Color(0xFF4CAF50).withOpacity(0.1)
                          : const Color(0xFFF44336).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text(
                      isPaid ? '✓ TT' : '✗ Chưa',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: isPaid
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFF44336),
                      ),
                    ),
                  ),
                ],
              ),
              if (onEdit != null || onDelete != null)
                PopupMenuButton(
                  itemBuilder: (context) => [
                    if (onEdit != null)
                      PopupMenuItem(
                        child: Row(
                          children: const [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Sửa'),
                          ],
                        ),
                        onTap: onEdit,
                      ),
                    if (onDelete != null)
                      PopupMenuItem(
                        child: Row(
                          children: const [
                            Icon(Icons.delete, size: 18, color: Color(0xFFF44336)),
                            SizedBox(width: 8),
                            Text('Xóa', style: TextStyle(color: Color(0xFFF44336))),
                          ],
                        ),
                        onTap: onDelete,
                      ),
                  ],
                  child: const Icon(Icons.more_vert, size: 20),
                ),
            ],
          ),
        ),
      ),
    );
  }
}