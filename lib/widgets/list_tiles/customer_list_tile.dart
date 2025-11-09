import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomerListTile extends StatelessWidget {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? city;
  final double totalSpent;
  final int totalOrders;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CustomerListTile({
    Key? key,
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.city,
    this.totalSpent = 0,
    this.totalOrders = 0,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,##0', 'en_US');
    return '${formatter.format(amount)}₫';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF1976D2).withOpacity(0.1),
          child: Text(
            name.substring(0, 1).toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1976D2),
            ),
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(phone, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.trending_up, size: 12, color: const Color(0xFF4CAF50)),
                const SizedBox(width: 4),
                Text(
                  _formatCurrency(totalSpent),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF4CAF50),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.shopping_bag, size: 12, color: const Color(0xFF2196F3)),
                const SizedBox(width: 4),
                Text(
                  '$totalOrders đơn',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF2196F3),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: SizedBox(
          width: 100,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onEdit != null)
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: onEdit,
                  color: const Color(0xFF2196F3),
                  constraints: const BoxConstraints(),
                ),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  onPressed: onDelete,
                  color: const Color(0xFFF44336),
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}