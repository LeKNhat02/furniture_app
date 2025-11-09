import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PromotionForm extends StatefulWidget {
  final String? initialName;
  final String? initialDescription;
  final String? initialDiscountType;
  final double? initialDiscountValue;
  final double? initialMinPurchase;
  final double? initialMaxDiscount;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final bool? initialIsActive;
  final Function(Map<String, dynamic>) onSubmit;
  final String submitButtonText;

  const PromotionForm({
    Key? key,
    this.initialName,
    this.initialDescription,
    this.initialDiscountType,
    this.initialDiscountValue,
    this.initialMinPurchase,
    this.initialMaxDiscount,
    this.initialStartDate,
    this.initialEndDate,
    this.initialIsActive,
    required this.onSubmit,
    this.submitButtonText = 'Lưu',
  }) : super(key: key);

  @override
  State<PromotionForm> createState() => _PromotionFormState();
}

class _PromotionFormState extends State<PromotionForm> {
  late TextEditingController nameCtrl;
  late TextEditingController descriptionCtrl;
  late TextEditingController discountValueCtrl;
  late TextEditingController minPurchaseCtrl;
  late TextEditingController maxDiscountCtrl;
  late String discountType;
  late DateTime startDate;
  late DateTime endDate;
  late bool isActive;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.initialName ?? '');
    descriptionCtrl = TextEditingController(text: widget.initialDescription ?? '');
    discountValueCtrl = TextEditingController(text: widget.initialDiscountValue?.toString() ?? '');
    minPurchaseCtrl = TextEditingController(text: widget.initialMinPurchase?.toString() ?? '');
    maxDiscountCtrl = TextEditingController(text: widget.initialMaxDiscount?.toString() ?? '');
    discountType = widget.initialDiscountType ?? 'percentage';
    startDate = widget.initialStartDate ?? DateTime.now();
    endDate = widget.initialEndDate ?? DateTime.now().add(const Duration(days: 30));
    isActive = widget.initialIsActive ?? true;
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    descriptionCtrl.dispose();
    discountValueCtrl.dispose();
    minPurchaseCtrl.dispose();
    maxDiscountCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime.now(),
      lastDate: endDate,
    );
    if (picked != null) {
      setState(() => startDate = picked);
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: endDate,
      firstDate: startDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => endDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tên khuyến mãi
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextFormField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Tên Khuyến Mãi *',
                  hintText: 'Nhập tên khuyến mãi',
                  prefixIcon: const Icon(Icons.local_offer),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên khuyến mãi';
                  }
                  return null;
                },
              ),
            ),

            // Mô tả
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextFormField(
                controller: descriptionCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Mô Tả',
                  hintText: 'Nhập mô tả khuyến mãi',
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignLabelWithHint: true,
                ),
              ),
            ),

            // Loại giảm giá
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: DropdownButtonFormField<String>(
                value: discountType,
                decoration: InputDecoration(
                  labelText: 'Loại Giảm Giá *',
                  prefixIcon: const Icon(Icons.discount),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'percentage',
                    child: Text('Giảm Giá Theo % (Phần Trăm)'),
                  ),
                  DropdownMenuItem(
                    value: 'fixed_amount',
                    child: Text('Giảm Giá Cố Định (Tiền)'),
                  ),
                ],
                onChanged: (value) {
                  setState(() => discountType = value ?? 'percentage');
                },
              ),
            ),

            // Giá trị giảm giá
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextFormField(
                controller: discountValueCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Giá Trị Giảm Giá *',
                  hintText: discountType == 'percentage' ? 'Nhập %' : 'Nhập số tiền',
                  prefixIcon: const Icon(Icons.attach_money),
                  suffixText: discountType == 'percentage' ? '%' : '₫',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập giá trị giảm giá';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Vui lòng nhập giá trị hợp lệ';
                  }
                  if (discountType == 'percentage' && double.parse(value) > 100) {
                    return 'Giảm giá % không thể vượt quá 100%';
                  }
                  return null;
                },
              ),
            ),

            // Mua tối thiểu
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextFormField(
                controller: minPurchaseCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Mua Tối Thiểu (₫)',
                  hintText: 'Nhập số tiền tối thiểu',
                  prefixIcon: const Icon(Icons.shopping_cart),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (double.tryParse(value) == null) {
                      return 'Vui lòng nhập giá trị hợp lệ';
                    }
                  }
                  return null;
                },
              ),
            ),

            // Giảm giá tối đa
            if (discountType == 'percentage')
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextFormField(
                  controller: maxDiscountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Giảm Giá Tối Đa (₫)',
                    hintText: 'Nhập số tiền giảm tối đa',
                    prefixIcon: const Icon(Icons.money_off),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (double.tryParse(value) == null) {
                        return 'Vui lòng nhập giá trị hợp lệ';
                      }
                    }
                    return null;
                  },
                ),
              ),

            // Ngày bắt đầu
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GestureDetector(
                onTap: _pickStartDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[400]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ngày Bắt Đầu *',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('dd/MM/yyyy').format(startDate),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Icon(Icons.calendar_today, color: Color(0xFF1976D2)),
                    ],
                  ),
                ),
              ),
            ),

            // Ngày kết thúc
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GestureDetector(
                onTap: _pickEndDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[400]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ngày Kết Thúc *',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('dd/MM/yyyy').format(endDate),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Icon(Icons.calendar_today, color: Color(0xFF1976D2)),
                    ],
                  ),
                ),
              ),
            ),

            // Status toggle
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isActive ? Icons.check_circle : Icons.block,
                            color: isActive ? const Color(0xFF4CAF50) : Colors.grey,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            isActive ? 'Khuyến mãi hoạt động' : 'Khuyến mãi ngừng hoạt động',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isActive ? const Color(0xFF4CAF50) : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: isActive,
                        onChanged: (value) {
                          setState(() => isActive = value);
                        },
                        activeColor: const Color(0xFF4CAF50),
                      ),
                    ],
                  ),
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
                      'description': descriptionCtrl.text.isEmpty ? null : descriptionCtrl.text,
                      'discountType': discountType,
                      'discountValue': double.parse(discountValueCtrl.text),
                      'minPurchase': minPurchaseCtrl.text.isEmpty ? null : double.parse(minPurchaseCtrl.text),
                      'maxDiscount': maxDiscountCtrl.text.isEmpty ? null : double.parse(maxDiscountCtrl.text),
                      'startDate': startDate.toIso8601String(),
                      'endDate': endDate.toIso8601String(),
                      'isActive': isActive,
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