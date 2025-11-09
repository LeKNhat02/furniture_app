import 'package:flutter/material.dart';

class ProductForm extends StatefulWidget {
  final String? initialName;
  final String? initialCategory;
  final double? initialPrice;
  final double? initialCost;
  final int? initialQuantity;
  final int? initialQuantityMin;
  final String? initialDescription;
  final String? initialSku;
  final List<String> categories;
  final Function(Map<String, dynamic>) onSubmit;
  final String submitButtonText;

  const ProductForm({
    Key? key,
    this.initialName,
    this.initialCategory,
    this.initialPrice,
    this.initialCost,
    this.initialQuantity,
    this.initialQuantityMin,
    this.initialDescription,
    this.initialSku,
    required this.categories,
    required this.onSubmit,
    this.submitButtonText = 'Lưu',
  }) : super(key: key);

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  late TextEditingController nameCtrl;
  late TextEditingController priceCtrl;
  late TextEditingController costCtrl;
  late TextEditingController quantityCtrl;
  late TextEditingController quantityMinCtrl;
  late TextEditingController descriptionCtrl;
  late TextEditingController skuCtrl;
  String? selectedCategory;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.initialName ?? '');
    priceCtrl = TextEditingController(text: widget.initialPrice?.toString() ?? '');
    costCtrl = TextEditingController(text: widget.initialCost?.toString() ?? '');
    quantityCtrl = TextEditingController(text: widget.initialQuantity?.toString() ?? '');
    quantityMinCtrl = TextEditingController(text: widget.initialQuantityMin?.toString() ?? '');
    descriptionCtrl = TextEditingController(text: widget.initialDescription ?? '');
    skuCtrl = TextEditingController(text: widget.initialSku ?? '');
    selectedCategory = widget.initialCategory;
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    priceCtrl.dispose();
    costCtrl.dispose();
    quantityCtrl.dispose();
    quantityMinCtrl.dispose();
    descriptionCtrl.dispose();
    skuCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tên sản phẩm
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextFormField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Tên Sản Phẩm *',
                  hintText: 'Nhập tên sản phẩm',
                  prefixIcon: const Icon(Icons.shopping_bag),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên sản phẩm';
                  }
                  return null;
                },
              ),
            ),

            // Danh mục
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Danh Mục *',
                  prefixIcon: const Icon(Icons.category),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: widget.categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => selectedCategory = value);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng chọn danh mục';
                  }
                  return null;
                },
              ),
            ),

            // SKU
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextFormField(
                controller: skuCtrl,
                decoration: InputDecoration(
                  labelText: 'Mã SKU *',
                  hintText: 'Nhập mã SKU',
                  prefixIcon: const Icon(Icons.qr_code),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mã SKU';
                  }
                  return null;
                },
              ),
            ),

            // Giá bán
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextFormField(
                controller: priceCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Giá Bán (₫) *',
                  hintText: 'Nhập giá bán',
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập giá bán';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Vui lòng nhập giá hợp lệ';
                  }
                  return null;
                },
              ),
            ),

            // Giá vốn
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextFormField(
                controller: costCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Giá Vốn (₫) *',
                  hintText: 'Nhập giá vốn',
                  prefixIcon: const Icon(Icons.price_change),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập giá vốn';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Vui lòng nhập giá hợp lệ';
                  }
                  return null;
                },
              ),
            ),

            // Số lượng
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8, bottom: 16),
                    child: TextFormField(
                      controller: quantityCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Số Lượng *',
                        hintText: '0',
                        prefixIcon: const Icon(Icons.inventory_2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập số lượng';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Vui lòng nhập số hợp lệ';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 16),
                    child: TextFormField(
                      controller: quantityMinCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'SL Tối Thiểu *',
                        hintText: '10',
                        prefixIcon: const Icon(Icons.warning),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập SL tối thiểu';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Vui lòng nhập số hợp lệ';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ],
            ),

            // Mô tả
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: TextFormField(
                controller: descriptionCtrl,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Mô Tả',
                  hintText: 'Nhập mô tả sản phẩm',
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignLabelWithHint: true,
                ),
              ),
            ),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    widget.onSubmit({
                      'name': nameCtrl.text,
                      'category': selectedCategory,
                      'sku': skuCtrl.text,
                      'price': double.parse(priceCtrl.text),
                      'cost': double.parse(costCtrl.text),
                      'quantity': int.parse(quantityCtrl.text),
                      'quantityMin': int.parse(quantityMinCtrl.text),
                      'description': descriptionCtrl.text,
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  widget.submitButtonText,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}