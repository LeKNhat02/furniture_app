import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config/constants.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/supplier_provider.dart';

class AddInventoryTransactionScreen extends StatefulWidget {
  const AddInventoryTransactionScreen({Key? key}) : super(key: key);

  @override
  State<AddInventoryTransactionScreen> createState() =>
      _AddInventoryTransactionScreenState();
}

class _AddInventoryTransactionScreenState
    extends State<AddInventoryTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _reasonController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedProductId; // ✅ String (match với ProductModel.id)
  String _selectedType = 'in';
  String? _selectedSupplierId; // ✅ String (match với SupplierModel.id)
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SupplierProvider>().fetchSuppliers();
      context.read<ProductProvider>().fetchProducts();
    });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _reasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedProductId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Vui lòng chọn sản phẩm'),
              backgroundColor: Colors.red),
        );
        return;
      }

      setState(() => _isLoading = true);

      final transactionData = {
        'product_id': _selectedProductId, // ✅ String
        'type': _selectedType,
        'quantity': int.parse(_quantityController.text),
        'reason': _reasonController.text.trim(),
        'notes': _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        'supplier_id': _selectedSupplierId, // ✅ String?
        'date': DateTime.now().toIso8601String(),
      };

      final provider = context.read<InventoryProvider>();
      final success = await provider.createTransaction(transactionData);

      setState(() => _isLoading = false);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Tạo giao dịch thành công'),
              backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(provider.errorMessage ?? 'Tạo giao dịch thất bại'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm Giao Dịch Kho')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Consumer<ProductProvider>(
                builder: (context, provider, _) {
                  return DropdownButtonFormField<String>(
                    value: _selectedProductId,
                    decoration: const InputDecoration(
                      labelText: 'Sản Phẩm *',
                      border: OutlineInputBorder(),
                    ),
                    items: provider.products
                        .map((product) => DropdownMenuItem(
                      value: product.id, // ✅ product.id là String
                      child: Text(product.name),
                    ))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedProductId = value),
                  );
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Loại Giao Dịch *',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'in', child: Text('Nhập Kho')),
                  DropdownMenuItem(value: 'out', child: Text('Xuất Kho')),
                ],
                onChanged: (value) => setState(() => _selectedType = value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Số Lượng *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập số lượng';
                  }
                  if (int.tryParse(value) == null ||
                      int.parse(value) <= 0) {
                    return 'Số lượng phải là số nguyên dương';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Lý Do *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập lý do';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (_selectedType == 'in')
                Consumer<SupplierProvider>(
                  builder: (context, provider, _) {
                    return DropdownButtonFormField<String?>(
                      value: _selectedSupplierId,
                      decoration: const InputDecoration(
                        labelText: 'Nhà Cung Cấp (Tùy chọn)',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                            value: null, child: Text('Không có')),
                        ...provider.suppliers
                            .map((supplier) => DropdownMenuItem<String?>(
                          value: supplier.id, // ✅ supplier.id là String
                          child: Text(supplier.name),
                        )),
                      ],
                      onChanged: (value) =>
                          setState(() => _selectedSupplierId = value),
                    );
                  },
                ),
              if (_selectedType == 'in') const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Ghi Chú',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Tạo Giao Dịch',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}