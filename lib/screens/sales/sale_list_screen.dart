import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/config/constants.dart';
import '../../providers/sale_provider.dart';
import 'create_sale_screen.dart';
import 'sale_detail_screen.dart';

class SaleListScreen extends StatefulWidget {
  const SaleListScreen({Key? key}) : super(key: key);

  @override
  State<SaleListScreen> createState() => _SaleListScreenState();
}

class _SaleListScreenState extends State<SaleListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SaleProvider>().fetchSales();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildSearchBar(),
          _buildStatusFilter(),
          Expanded(child: _buildSaleList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateSaleScreen()),
          );
          if (result == true && mounted) {
            context.read<SaleProvider>().fetchSales();
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          context.read<SaleProvider>().searchSales(value);
        },
        decoration: InputDecoration(
          hintText: 'Tìm kiếm đơn hàng...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<SaleProvider>().searchSales('');
                  },
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Consumer<SaleProvider>(
      builder: (context, provider, _) {
        return SizedBox(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildStatusChip(provider, null, 'Tất Cả'),
              const SizedBox(width: 8),
              _buildStatusChip(provider, 'completed', 'Hoàn Thành'),
              const SizedBox(width: 8),
              _buildStatusChip(provider, 'pending', 'Chờ Xử Lý'),
              const SizedBox(width: 8),
              _buildStatusChip(provider, 'cancelled', 'Đã Hủy'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(SaleProvider provider, String? status, String label) {
    final isSelected = provider.selectedStatus == status;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        provider.filterByStatus(status);
      },
      backgroundColor: Colors.grey[200],
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSaleList() {
    return Consumer<SaleProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(provider.errorMessage!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.fetchSales(),
                  child: const Text('Thử Lại'),
                ),
              ],
            ),
          );
        }

        if (provider.sales.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shopping_cart, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('Không có đơn hàng nào', style: TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.fetchSales(),
                  child: const Text('Tải Lại'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.sales.length,
          itemBuilder: (context, index) {
            final sale = provider.sales[index];
            return _buildSaleCard(context, sale);
          },
        );
      },
    );
  }

  Widget _buildSaleCard(BuildContext context, dynamic sale) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final statusColor = sale.status == 'completed'
        ? Colors.green
        : sale.status == 'pending'
            ? Colors.orange
            : Colors.red;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SaleDetailScreen(saleId: sale.id)),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Đơn #${sale.orderNumber}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        if (sale.customerName != null)
                          Text(
                            sale.customerName!,
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      sale.status == 'completed'
                          ? 'Hoàn Thành'
                          : sale.status == 'pending'
                              ? 'Chờ Xử Lý'
                              : 'Đã Hủy',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: statusColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Số lượng SP', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      Text('${sale.items.length} sản phẩm', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Tổng Tiền', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      Text(
                        '${sale.total.toStringAsFixed(0)}${AppConstants.currencySymbol}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                dateFormat.format(sale.createdAt),
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

