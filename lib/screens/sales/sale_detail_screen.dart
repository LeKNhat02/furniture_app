import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/config/constants.dart';
import '../../providers/sale_provider.dart';
import 'sale_list_screen.dart';

class SaleDetailScreen extends StatefulWidget {
  final String saleId;

  const SaleDetailScreen({Key? key, required this.saleId}) : super(key: key);

  @override
  State<SaleDetailScreen> createState() => _SaleDetailScreenState();
}

class _SaleDetailScreenState extends State<SaleDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SaleProvider>().fetchSaleById(widget.saleId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi Tiết Đơn Hàng')),
      body: Consumer<SaleProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.selectedSale == null) {
            return const Center(child: Text('Không tìm thấy đơn hàng'));
          }

          final sale = provider.selectedSale!;
          final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(sale, dateFormat),
                const SizedBox(height: 16),
                _buildItemsList(sale),
                const SizedBox(height: 16),
                _buildSummaryCard(sale),
                if (sale.notes != null && sale.notes!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildNotesCard(sale),
                ],
                const SizedBox(height: 16),
                if (sale.status == 'pending')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _cancelSale(context, provider, sale.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Hủy Đơn Hàng'),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard(dynamic sale, DateFormat dateFormat) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Đơn #${sale.orderNumber}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: sale.status == 'completed'
                        ? Colors.green.withOpacity(0.2)
                        : sale.status == 'pending'
                            ? Colors.orange.withOpacity(0.2)
                            : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    sale.status == 'completed'
                        ? 'Hoàn Thành'
                        : sale.status == 'pending'
                            ? 'Chờ Xử Lý'
                            : 'Đã Hủy',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: sale.status == 'completed'
                          ? Colors.green
                          : sale.status == 'pending'
                              ? Colors.orange
                              : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (sale.customerName != null) ...[
              Text('Khách hàng: ${sale.customerName}', style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 4),
            ],
            Text('Ngày tạo: ${dateFormat.format(sale.createdAt)}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            const SizedBox(height: 4),
            Text('Thanh toán: ${sale.paymentMethod}', style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsList(dynamic sale) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Danh Sách Sản Phẩm', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          ...sale.items.map((item) => _buildItemRow(item)),
        ],
      ),
    );
  }

  Widget _buildItemRow(dynamic item) {
    return ListTile(
      title: Text(item.productName.isNotEmpty ? item.productName : 'Sản phẩm ${item.productId}'),
      subtitle: Text('SL: ${item.quantity} x ${item.price.toStringAsFixed(0)}${AppConstants.currencySymbol}'),
      trailing: Text(
        '${item.subtotal.toStringAsFixed(0)}${AppConstants.currencySymbol}',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildSummaryCard(dynamic sale) {
    return Card(
      color: AppColors.primary.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSummaryRow('Tạm Tính:', '${sale.subtotal.toStringAsFixed(0)}${AppConstants.currencySymbol}'),
            const SizedBox(height: 8),
            _buildSummaryRow('Giảm Giá:', '${sale.totalDiscount.toStringAsFixed(0)}${AppConstants.currencySymbol}'),
            const Divider(),
            _buildSummaryRow(
              'Tổng Tiền:',
              '${sale.total.toStringAsFixed(0)}${AppConstants.currencySymbol}',
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: isTotal ? 18 : 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        Text(value, style: TextStyle(fontSize: isTotal ? 20 : 14, fontWeight: FontWeight.bold, color: isTotal ? Colors.green : Colors.black)),
      ],
    );
  }

  Widget _buildNotesCard(dynamic sale) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ghi Chú', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(sale.notes!, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Future<void> _cancelSale(BuildContext context, SaleProvider provider, String saleId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác Nhận Hủy Đơn'),
        content: const Text('Bạn có chắc chắn muốn hủy đơn hàng này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xác Nhận', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await provider.cancelSale(saleId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã hủy đơn hàng'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.errorMessage ?? 'Hủy đơn hàng thất bại'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

