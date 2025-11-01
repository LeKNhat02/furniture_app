import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config/constants.dart';
import '../../core/models/product_model.dart';
import '../../providers/product_provider.dart';
import 'package:image_picker/image_picker.dart';

class EditProductScreen extends StatefulWidget {
  final ProductModel product;

  const EditProductScreen({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _costController;
  late TextEditingController _quantityController;
  late TextEditingController _quantityMinController;
  late TextEditingController _skuController;

  late String _selectedCategory;
  bool _isLoading = false;
  XFile? _pickedImage;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Khởi tạo các controller với giá trị hiện tại
    _nameController = TextEditingController(text: widget.product.name);
    _descriptionController =
        TextEditingController(text: widget.product.description ?? '');
    _priceController =
        TextEditingController(text: widget.product.price.toStringAsFixed(0));
    _costController =
        TextEditingController(text: widget.product.cost.toStringAsFixed(0));
    _quantityController =
        TextEditingController(text: widget.product.quantity.toString());
    _quantityMinController =
        TextEditingController(text: widget.product.quantityMin.toString());
    _skuController = TextEditingController(text: widget.product.sku);
    _selectedCategory = widget.product.category;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _costController.dispose();
    _quantityController.dispose();
    _quantityMinController.dispose();
    _skuController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Chuẩn bị dữ liệu cập nhật (chỉ gửi những field cần update)
      final updateData = {
        'name': _nameController.text.trim(),
        'category': _selectedCategory,
        'price': double.parse(_priceController.text),
        'cost': double.parse(_costController.text),
        'quantity': int.parse(_quantityController.text),
        'quantityMin': int.parse(_quantityMinController.text),
        'description': _descriptionController.text.trim(),
        'sku': _skuController.text.trim(),
        if (_pickedImage != null) 'imagePath': _pickedImage!.path,
      };

      final success = await context
          .read<ProductProvider>()
          .updateProduct(widget.product.id, updateData);

      setState(() => _isLoading = false);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cập nhật sản phẩm thành công!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          final errorMsg =
              context.read<ProductProvider>().errorMessage ??
                  'Lỗi cập nhật sản phẩm';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? file = await _imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (file != null) {
      setState(() => _pickedImage = file);
    }
  }

  @override
  Widget build(BuildContext context) {
    // increase font sizes for better readability
    const formFieldTextStyle = TextStyle(fontSize: 18);
    const labelTextStyle = TextStyle(fontSize: 16);

    return Scaffold(
      appBar: AppBar(
        title: Text('Chỉnh Sửa Sản Phẩm', style: TextStyle(fontSize: 20)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Image picker preview
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                    color: Colors.grey.shade50,
                  ),
                  child: _pickedImage == null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.camera_alt, size: 36, color: Colors.grey),
                              SizedBox(height: 8),
                              Text('Chọn ảnh sản phẩm (bấm để chọn)'),
                            ],
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(_pickedImage!.path),
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              // Name
              TextFormField(
                controller: _nameController,
                style: formFieldTextStyle,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên sản phẩm';
                  }
                  if (value.length < 3) {
                    return 'Tên sản phẩm phải có ít nhất 3 ký tự';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Tên Sản Phẩm',
                  labelStyle: labelTextStyle,
                  hintText: 'Ví dụ: Bàn ăn gỗ',
                  prefixIcon: const Icon(Icons.shopping_bag),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Category
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                onChanged: (value) {
                  setState(() => _selectedCategory = value!);
                },
                style: formFieldTextStyle,
                items: AppConstants.productCategories
                    .map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat, style: formFieldTextStyle),
                        ))
                    .toList(),
                decoration: InputDecoration(
                  labelText: 'Danh Mục',
                  labelStyle: labelTextStyle,
                  prefixIcon: const Icon(Icons.category),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                style: formFieldTextStyle,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Mô Tả',
                  labelStyle: labelTextStyle,
                  hintText: 'Nhập mô tả chi tiết về sản phẩm',
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),

              // SKU
              TextFormField(
                controller: _skuController,
                style: formFieldTextStyle,
                decoration: InputDecoration(
                  labelText: 'SKU (Mã Sản Phẩm)',
                  labelStyle: labelTextStyle,
                  hintText: 'Ví dụ: SKU-001',
                  prefixIcon: const Icon(Icons.qr_code),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Price & Cost Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      style: formFieldTextStyle,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nhập giá bán';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Giá không hợp lệ';
                        }
                        if (double.parse(value) < 0) {
                          return 'Giá không được âm';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Giá Bán',
                        labelStyle: labelTextStyle,
                        prefixIcon: const Icon(Icons.attach_money),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _costController,
                      style: formFieldTextStyle,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nhập giá vốn';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Giá không hợp lệ';
                        }
                        if (double.parse(value) < 0) {
                          return 'Giá không được âm';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Giá Vốn',
                        labelStyle: labelTextStyle,
                        prefixIcon: const Icon(Icons.attach_money),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Quantity & Min Quantity Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      style: formFieldTextStyle,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nhập số lượng';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Không hợp lệ';
                        }
                        if (int.parse(value) < 0) {
                          return 'Số lượng không được âm';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Số Lượng',
                        labelStyle: labelTextStyle,
                        prefixIcon: const Icon(Icons.inventory_2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _quantityMinController,
                      style: formFieldTextStyle,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nhập tồn tối thiểu';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Không hợp lệ';
                        }
                        if (int.parse(value) < 0) {
                          return 'Số lượng không được âm';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Tồn Tối Thiểu',
                        labelStyle: labelTextStyle,
                        prefixIcon: const Icon(Icons.warning),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white),
                          ),
                        )
                      : const Text(
                          'Cập Nhật Sản Phẩm',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Cancel Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Hủy', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

