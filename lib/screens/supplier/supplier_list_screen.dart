import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config/constants.dart';
import '../../providers/supplier_provider.dart';
import 'add_supplier_screen.dart';
import 'edit_supplier_screen.dart';
import 'supplier_detail_screen.dart';

class SupplierListScreen extends StatefulWidget {
  const SupplierListScreen({Key? key}) : super(key: key);

  @override
  State<SupplierListScreen> createState() => _SupplierListScreenState();
}

class _SupplierListScreenState extends State<SupplierListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SupplierProvider>().fetchSuppliers();
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
          Expanded(child: _buildSupplierList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddSupplierScreen()),
          );
          if (result == true && mounted) {
            context.read<SupplierProvider>().fetchSuppliers();
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
          context.read<SupplierProvider>().searchSuppliers(value);
        },
        decoration: InputDecoration(
          hintText: 'Tìm kiếm nhà cung cấp...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<SupplierProvider>().searchSuppliers('');
                  },
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildSupplierList() {
    return Consumer<SupplierProvider>(
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
                  onPressed: () => provider.fetchSuppliers(),
                  child: const Text('Thử Lại'),
                ),
              ],
            ),
          );
        }

        if (provider.suppliers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.business, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('Không có nhà cung cấp nào', style: TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.fetchSuppliers(),
                  child: const Text('Tải Lại'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.suppliers.length,
          itemBuilder: (context, index) {
            final supplier = provider.suppliers[index];
            return _buildSupplierCard(context, supplier);
          },
        );
      },
    );
  }

  Widget _buildSupplierCard(BuildContext context, dynamic supplier) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SupplierDetailScreen(supplierId: supplier.id)),
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
                          supplier.name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          supplier.phone,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: supplier.isActive ? Colors.green[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      supplier.isActive ? 'Hoạt Động' : 'Ngừng',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: supplier.isActive ? Colors.green : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              if (supplier.email != null && supplier.email!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Email: ${supplier.email}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
              if (supplier.contactPerson != null && supplier.contactPerson!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text('Người liên hệ: ${supplier.contactPerson}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    iconSize: 20,
                    color: AppColors.primary,
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => EditSupplierScreen(supplier: supplier)),
                      );
                      if (result == true && mounted) {
                        context.read<SupplierProvider>().fetchSuppliers();
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    iconSize: 20,
                    color: Colors.red,
                    onPressed: () => _showDeleteConfirmDialog(context, supplier),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, dynamic supplier) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác Nhận Xóa'),
          content: Text('Bạn có chắc chắn muốn xóa "${supplier.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<SupplierProvider>().deleteSupplier(supplier.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã xóa nhà cung cấp'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Xóa', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

