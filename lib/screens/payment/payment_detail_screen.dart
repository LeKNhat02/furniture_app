import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/config/constants.dart';
import '../../providers/payment_provider.dart';

class PaymentDetailScreen extends StatefulWidget {
  final String paymentId;

  const PaymentDetailScreen({Key? key, required this.paymentId}) : super(key: key);

  @override
  State<PaymentDetailScreen> createState() => _PaymentDetailScreenState();
}

class _PaymentDetailScreenState extends State<PaymentDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentProvider>().fetchPaymentById(widget.paymentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi Tiết Thanh Toán')),
      body: Consumer<PaymentProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.selectedPayment == null) {
            return const Center(child: Text('Không tìm thấy thanh toán'));
          }

          final payment = provider.selectedPayment!;
          final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

          final statusColor = payment.status == 'completed'
              ? Colors.green
              : payment.status == 'pending'
              ? Colors.orange
              : payment.status == 'failed'
              ? Colors.red
              : Colors.grey;

          final statusText = payment.getStatusDisplay();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Thanh Toán #${payment.id}',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                statusText,
                                style: TextStyle(fontWeight: FontWeight.bold, color: statusColor),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // ✅ Sửa: Dùng saleName thay vì saleOrderNumber
                        _buildInfoRow(Icons.shopping_cart, 'Đơn Hàng', payment.saleName ?? 'N/A'),
                        if (payment.customerName != null)
                          _buildInfoRow(Icons.person, 'Khách Hàng', payment.customerName!),
                        _buildInfoRow(Icons.attach_money, 'Số Tiền',
                            '${payment.amount.toStringAsFixed(0)}${AppConstants.currencySymbol}'),
                        _buildInfoRow(Icons.payment, 'Phương Thức', payment.getPaymentMethodDisplay()),
                        _buildInfoRow(Icons.calendar_today, 'Ngày Thanh Toán', dateFormat.format(payment.paymentDate)),
                        if (payment.transactionId != null && payment.transactionId!.isNotEmpty)
                          _buildInfoRow(Icons.receipt, 'Mã Giao Dịch', payment.transactionId!),
                        if (payment.notes != null && payment.notes!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Text('Ghi Chú', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(payment.notes!),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (payment.status == 'completed')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showRefundDialog(context, provider, payment.id),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Hoàn Tiền'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showRefundDialog(BuildContext context, PaymentProvider provider, String paymentId) async {
    final notesController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác Nhận Hoàn Tiền'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Bạn có chắc chắn muốn hoàn tiền cho thanh toán này?'),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Lý do hoàn tiền (Tùy chọn)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xác Nhận', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await provider.refundPayment(paymentId, notes: notesController.text.trim());
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã hoàn tiền thành công'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Hoàn tiền thất bại'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}