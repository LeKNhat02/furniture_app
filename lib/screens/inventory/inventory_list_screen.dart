import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/config/constants.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/product_provider.dart';
import 'add_inventory_transaction_screen.dart';

class InventoryListScreen extends StatefulWidget {
  const InventoryListScreen({Key? key}) : super(key: key);

  @override
  State<InventoryListScreen> createState() => _InventoryListScreenState();
}

class _InventoryListScreenState extends State<InventoryListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventoryProvider>().fetchTransactions();
      context.read<ProductProvider>().fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(child: _buildTransactionList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddInventoryTransactionScreen()),
          );
          if (result == true && mounted) {
            context.read<InventoryProvider>().fetchTransactions();
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Consumer<InventoryProvider>(
      builder: (context, provider, _) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String?>(
                  value: provider.selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Loại',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Tất Cả')),
                    const DropdownMenuItem(value: 'in', child: Text('Nhập Kho')),
                    const DropdownMenuItem(value: 'out', child: Text('Xuất Kho')),
                  ],
                  onChanged: (value) => provider.filterByType(value),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Consumer<ProductProvider>(
                  builder: (context, productProvider, _) {
                    return DropdownButtonFormField<String?>(
                      value: provider.selectedProductId,
                      decoration: const InputDecoration(
                        labelText: 'Sản Phẩm',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Tất Cả')),
                        ...productProvider.products.map((product) => DropdownMenuItem(
                              value: product.id,
                              child: Text(product.name, overflow: TextOverflow.ellipsis),
                            )),
                      ],
                      onChanged: (value) => provider.filterByProduct(value),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTransactionList() {
    return Consumer<InventoryProvider>(
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
                  onPressed: () => provider.fetchTransactions(),
                  child: const Text('Thử Lại'),
                ),
              ],
            ),
          );
        }

        if (provider.transactions.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('Không có giao dịch nào', style: TextStyle(fontSize: 16, color: Colors.grey)),
              ],
            ),
          );
        }

        final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.transactions.length,
          itemBuilder: (context, index) {
            final transaction = provider.transactions[index];
            return _buildTransactionCard(transaction, dateFormat);
          },
        );
      },
    );
  }

  Widget _buildTransactionCard(dynamic transaction, DateFormat dateFormat) {
    final isIn = transaction.type == 'in';
    final color = isIn ? Colors.green : Colors.orange;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isIn ? Icons.arrow_downward : Icons.arrow_upward,
            color: color,
          ),
        ),
        title: Text(
          transaction.productName.isNotEmpty ? transaction.productName : 'Sản phẩm ${transaction.productId}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Số lượng: ${transaction.quantity}'),
            Text('Lý do: ${transaction.reason}'),
            Text(
              dateFormat.format(transaction.date),
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: Text(
          isIn ? '+${transaction.quantity}' : '-${transaction.quantity}',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
        ),
      ),
    );
  }
}

