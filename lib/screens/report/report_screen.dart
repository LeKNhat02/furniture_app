import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config/constants.dart';
import '../../providers/sale_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/customer_provider.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({Key? key}) : super(key: key);

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SaleProvider>().fetchSales();
      context.read<ProductProvider>().fetchProducts();
      context.read<CustomerProvider>().fetchCustomers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Báo Cáo & Thống Kê', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _buildQuickStats(),
          const SizedBox(height: 24),
          _buildSalesStats(),
          const SizedBox(height: 24),
          _buildProductStats(),
          const SizedBox(height: 24),
          _buildCustomerStats(),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Consumer2<SaleProvider, ProductProvider>(
      builder: (context, saleProvider, productProvider, _) {
        final totalSales = saleProvider.sales.length;
        final totalRevenue = saleProvider.sales.fold<double>(
          0.0,
          (sum, sale) => sum + sale.total,
        );
        final totalProducts = productProvider.products.length;
        final totalInventoryValue = productProvider.products.fold<double>(
          0.0,
          (sum, product) => sum + (product.price * product.quantity),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tổng Quan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.shopping_cart,
                    label: 'Tổng Đơn Hàng',
                    value: '$totalSales',
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.attach_money,
                    label: 'Doanh Thu',
                    value: '${(totalRevenue / 1000000).toStringAsFixed(1)}M',
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.inventory_2,
                    label: 'Sản Phẩm',
                    value: '$totalProducts',
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.warehouse,
                    label: 'Giá Trị Kho',
                    value: '${(totalInventoryValue / 1000000).toStringAsFixed(1)}M',
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesStats() {
    return Consumer<SaleProvider>(
      builder: (context, provider, _) {
        final completedSales = provider.sales.where((s) => s.status == 'completed').length;
        final pendingSales = provider.sales.where((s) => s.status == 'pending').length;
        final cancelledSales = provider.sales.where((s) => s.status == 'cancelled').length;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Thống Kê Bán Hàng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildStatRow('Đơn Hoàn Thành', '$completedSales', Colors.green),
                _buildStatRow('Đơn Chờ Xử Lý', '$pendingSales', Colors.orange),
                _buildStatRow('Đơn Đã Hủy', '$cancelledSales', Colors.red),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductStats() {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        final lowStockCount = provider.products.where((p) => p.isLowStock).length;
        final totalQuantity = provider.products.fold<int>(0, (sum, p) => sum + p.quantity);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Thống Kê Sản Phẩm', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildStatRow('Tổng Sản Phẩm', '${provider.products.length}', Colors.blue),
                _buildStatRow('Hàng Sắp Hết', '$lowStockCount', Colors.orange),
                _buildStatRow('Tổng Tồn Kho', '$totalQuantity', Colors.green),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomerStats() {
    return Consumer<CustomerProvider>(
      builder: (context, provider, _) {
        final totalCustomers = provider.customers.length;
        final activeCustomers = provider.customers.where((c) => c.isActive).length;
        final totalSpent = provider.customers.fold<double>(0.0, (sum, c) => sum + c.totalSpent);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Thống Kê Khách Hàng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildStatRow('Tổng Khách Hàng', '$totalCustomers', Colors.blue),
                _buildStatRow('Khách Hoạt Động', '$activeCustomers', Colors.green),
                _buildStatRow('Tổng Chi Tiêu', '${(totalSpent / 1000000).toStringAsFixed(1)}M', Colors.purple),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}

