import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/config/constants.dart';
import '../../providers/promotion_provider.dart';

class AddPromotionScreen extends StatefulWidget {
  const AddPromotionScreen({Key? key}) : super(key: key);

  @override
  State<AddPromotionScreen> createState() => _AddPromotionScreenState();
}

class _AddPromotionScreenState extends State<AddPromotionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _discountValueController = TextEditingController();
  final _minPurchaseController = TextEditingController();
  final _maxDiscountController = TextEditingController();

  String _discountType = AppConstants.discountPercentage;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _discountValueController.dispose();
    _minPurchaseController.dispose();
    _maxDiscountController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final promotionData = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        'discount_type': _discountType,
        'discount_value': double.parse(_discountValueController.text),
        'min_purchase': _minPurchaseController.text.trim().isEmpty ? null : double.parse(_minPurchaseController.text),
        'max_discount': _maxDiscountController.text.trim().isEmpty ? null : double.parse(_maxDiscountController.text),
        'start_date': _startDate.toIso8601String(),
        'end_date': _endDate.toIso8601String(),
        'is_active': _isActive,
      };

      final success = await context.read<PromotionProvider>().createPromotion(promotionData);

      setState(() => _isLoading = false);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tạo khuyến mãi thành công!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.read<PromotionProvider>().errorMessage ?? 'Tạo khuyến mãi thất bại'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text('Thêm Khuyến Mãi')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Tên Khuyến Mãi *', border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? 'Vui lòng nhập tên' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Mô Tả', border: OutlineInputBorder()),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _discountType,
                decoration: const InputDecoration(labelText: 'Loại Giảm Giá *', border: OutlineInputBorder()),
                items: [
                  DropdownMenuItem(value: AppConstants.discountPercentage, child: const Text('Phần Trăm (%)')),
                  DropdownMenuItem(value: AppConstants.discountFixedAmount, child: const Text('Số Tiền Cố Định')),
                ],
                onChanged: (value) => setState(() => _discountType = value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _discountValueController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: _discountType == AppConstants.discountPercentage ? 'Giảm Giá (%) *' : 'Giảm Giá (₫) *',
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập giá trị giảm giá';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Giá trị phải là số dương';
                  }
                  if (_discountType == AppConstants.discountPercentage && double.parse(value) > 100) {
                    return 'Phần trăm không được vượt quá 100%';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _minPurchaseController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Đơn Hàng Tối Thiểu (₫)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              if (_discountType == AppConstants.discountPercentage)
                TextFormField(
                  controller: _maxDiscountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Giảm Tối Đa (₫)',
                    border: OutlineInputBorder(),
                  ),
                ),
              if (_discountType == AppConstants.discountPercentage) const SizedBox(height: 16),
              InkWell(
                onTap: _selectStartDate,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Ngày Bắt Đầu *', border: OutlineInputBorder()),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(dateFormat.format(_startDate)),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selectEndDate,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Ngày Kết Thúc *', border: OutlineInputBorder()),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(dateFormat.format(_endDate)),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Kích Hoạt'),
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSave,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Tạo Khuyến Mãi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

