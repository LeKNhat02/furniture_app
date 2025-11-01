import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config/constants.dart';
import '../../providers/supplier_provider.dart';
import 'edit_supplier_screen.dart';

class SupplierDetailScreen extends StatefulWidget {
  final String supplierId;

  const SupplierDetailScreen({Key? key, required this.supplierId}) : super(key: key);

  @override
  State<SupplierDetailScreen> createState() => _SupplierDetailScreenState();
}

class _SupplierDetailScreenState extends State<SupplierDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SupplierProvider>().fetchSupplierById(widget.supplierId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi Tiết Nhà Cung Cấp')),
      body: Consumer<SupplierProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.selectedSupplier == null) {
            return const Center(child: Text('Không tìm thấy nhà cung cấp'));
          }

          final supplier = provider.selectedSupplier!;

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
                                supplier.name,
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: supplier.isActive ? Colors.green.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                supplier.isActive ? 'Hoạt Động' : 'Ngừng',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: supplier.isActive ? Colors.green : Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(Icons.phone, 'Số Điện Thoại', supplier.phone),
                        if (supplier.email != null && supplier.email!.isNotEmpty)
                          _buildInfoRow(Icons.email, 'Email', supplier.email!),
                        if (supplier.contactPerson != null && supplier.contactPerson!.isNotEmpty)
                          _buildInfoRow(Icons.person, 'Người Liên Hệ', supplier.contactPerson!),
                        if (supplier.address != null && supplier.address!.isNotEmpty)
                          _buildInfoRow(Icons.location_on, 'Địa Chỉ', supplier.address!),
                        if (supplier.city != null && supplier.city!.isNotEmpty)
                          _buildInfoRow(Icons.location_city, 'Thành Phố', supplier.city!),
                        if (supplier.notes != null && supplier.notes!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Text('Ghi Chú', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(supplier.notes!),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => EditSupplierScreen(supplier: supplier)),
                      );
                      if (result == true && mounted) {
                        provider.fetchSupplierById(widget.supplierId);
                      }
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Chỉnh Sửa'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
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
}

