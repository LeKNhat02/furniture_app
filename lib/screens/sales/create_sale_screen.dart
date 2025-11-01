import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config/constants.dart';
import '../../core/models/sale_model.dart';
import '../../providers/sale_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/customer_provider.dart';
import 'sale_list_screen.dart';

class CreateSaleScreen extends StatefulWidget {
  const CreateSaleScreen({Key? key}) : super(key: key);

  @override
  State<CreateSaleScreen> createState() => _CreateSaleScreenState();
}

class _CreateSaleScreenState extends State<CreateSaleScreen> {
  final List<SaleItem> _items = [];
  String? _selectedCustomerId;
  String _paymentMethod = AppConstants.paymentMethods[0];
  final _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng thêm ít nhất một sản phẩm'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    final saleData = {
      'customer_id': _selectedCustomerId,
      'items': _items.map((item) => item.toJson()).toList(),
      'payment_method': _paymentMethod,
      'notes': _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    };

    final provider = context.read<SaleProvider>();
    final success = await provider.createSale(saleData);

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tạo đơn hàng thành công'), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? 'Tạo đơn hàng thất bại'), backgroundColor: Colors.red),
      );
    }
  }

  void _addProduct(dynamic product) {
    showDialog(
      context: context,
      builder: (context) => _AddProductDialog(product: product, onAdd: (item) {
        setState(() => _items.add(item));
      }),
    );
  }

  double get _total {
    return _items.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tạo Đơn Hàng')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCustomerSelector(),
                  const SizedBox(height: 16),
                  _buildPaymentMethod(),
                  const SizedBox(height: 16),
                  _buildAddProductButton(),
                  const SizedBox(height: 16),
                  _buildItemsList(),
                  const SizedBox(height: 16),
                  _buildNotesField(),
                  const SizedBox(height: 16),
                  _buildTotalCard(),
                ],
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildCustomerSelector() {
    return Consumer<CustomerProvider>(
      builder: (context, provider, _) {
        return DropdownButtonFormField<String>(
          value: _selectedCustomerId,
          decoration: const InputDecoration(
            labelText: 'Khách Hàng (Tùy chọn)',
            border: OutlineInputBorder(),
          ),
          items: [
            const DropdownMenuItem(value: null, child: Text('Khách vãng lai')),
            ...provider.customers.map((customer) => DropdownMenuItem(
                  value: customer.id,
                  child: Text('${customer.name} - ${customer.phone}'),
                )),
          ],
          onChanged: (value) => setState(() => _selectedCustomerId = value),
        );
      },
    );
  }

  Widget _buildPaymentMethod() {
    return DropdownButtonFormField<String>(
      value: _paymentMethod,
      decoration: const InputDecoration(
        labelText: 'Phương Thức Thanh Toán',
        border: OutlineInputBorder(),
      ),
      items: AppConstants.paymentMethods.map((method) => DropdownMenuItem(
            value: method,
            child: Text(method),
          )),
      onChanged: (value) => setState(() => _paymentMethod = value!),
    );
  }

  Widget _buildAddProductButton() {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        return ElevatedButton.icon(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (context) => _ProductPickerSheet(
                products: provider.products.where((p) => p.quantity > 0).toList(),
                onSelect: _addProduct,
              ),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Thêm Sản Phẩm'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            minimumSize: const Size(double.infinity, 50),
          ),
        );
      },
    );
  }

  Widget _buildItemsList() {
    if (_items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: const Center(
          child: Text('Chưa có sản phẩm nào', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Sản Phẩm Đã Thêm', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ..._items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return _buildItemCard(item, index);
        }),
      ],
    );
  }

  Widget _buildItemCard(SaleItem item, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(item.productName.isNotEmpty ? item.productName : 'Sản phẩm ${item.productId}'),
        subtitle: Text('SL: ${item.quantity} x ${item.price.toStringAsFixed(0)}${AppConstants.currencySymbol}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${item.subtotal.toStringAsFixed(0)}${AppConstants.currencySymbol}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
              onPressed: () => setState(() => _items.removeAt(index)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesField() {
    return TextField(
      controller: _notesController,
      decoration: const InputDecoration(
        labelText: 'Ghi Chú',
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
    );
  }

  Widget _buildTotalCard() {
    return Card(
      color: AppColors.primary.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Tổng Tiền:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(
              '${_total.toStringAsFixed(0)}${AppConstants.currencySymbol}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.grey[300]!, blurRadius: 4, offset: const Offset(0, -2))],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _handleSave,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('Tạo Đơn Hàng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

class _AddProductDialog extends StatefulWidget {
  final dynamic product;
  final Function(SaleItem) onAdd;

  const _AddProductDialog({required this.product, required this.onAdd});

  @override
  State<_AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<_AddProductDialog> {
  final _quantityController = TextEditingController(text: '1');
  final _discountController = TextEditingController(text: '0');
  double _price = 0;

  @override
  void initState() {
    super.initState();
    _price = widget.product.price;
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    final discount = double.tryParse(_discountController.text) ?? 0.0;

    return AlertDialog(
      title: Text(widget.product.name),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _quantityController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Số Lượng (Tối đa: ${widget.product.quantity})',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: TextEditingController(text: _price.toStringAsFixed(0)),
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Giá Bán',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => setState(() => _price = double.tryParse(value) ?? _price),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _discountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Giảm Giá',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          if (quantity > 0)
            Text(
              'Tổng: ${((_price * quantity) - discount).toStringAsFixed(0)}${AppConstants.currencySymbol}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: quantity > 0 && quantity <= widget.product.quantity
              ? () {
                  widget.onAdd(SaleItem(
                    productId: widget.product.id,
                    productName: widget.product.name,
                    quantity: quantity,
                    price: _price,
                    discount: discount,
                  ));
                  Navigator.pop(context);
                }
              : null,
          child: const Text('Thêm'),
        ),
      ],
    );
  }
}

class _ProductPickerSheet extends StatelessWidget {
  final List<dynamic> products;
  final Function(dynamic) onSelect;

  const _ProductPickerSheet({required this.products, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Chọn Sản Phẩm', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: products.isEmpty
                ? const Center(child: Text('Không có sản phẩm nào'))
                : ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ListTile(
                        title: Text(product.name),
                        subtitle: Text('Giá: ${product.price.toStringAsFixed(0)}${AppConstants.currencySymbol} - Tồn: ${product.quantity}'),
                        trailing: const Icon(Icons.add),
                        onTap: () {
                          onSelect(product);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

