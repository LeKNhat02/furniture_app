import 'package:flutter/material.dart';

class CustomerForm extends StatefulWidget {
  final String? initialName;
  final String? initialPhone;
  final String? initialEmail;
  final String? initialAddress;
  final String? initialCity;
  final String? initialNotes;
  final Function(Map<String, dynamic>) onSubmit;
  final String submitButtonText;

  const CustomerForm({
    Key? key,
    this.initialName,
    this.initialPhone,
    this.initialEmail,
    this.initialAddress,
    this.initialCity,
    this.initialNotes,
    required this.onSubmit,
    this.submitButtonText = 'Lưu',
  }) : super(key: key);

  @override
  State<CustomerForm> createState() => _CustomerFormState();
}

class _CustomerFormState extends State<CustomerForm> {
  late TextEditingController nameCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController addressCtrl;
  late TextEditingController cityCtrl;
  late TextEditingController notesCtrl;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.initialName ?? '');
    phoneCtrl = TextEditingController(text: widget.initialPhone ?? '');
    emailCtrl = TextEditingController(text: widget.initialEmail ?? '');
    addressCtrl = TextEditingController(text: widget.initialAddress ?? '');
    cityCtrl = TextEditingController(text: widget.initialCity ?? '');
    notesCtrl = TextEditingController(text: widget.initialNotes ?? '');
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    addressCtrl.dispose();
    cityCtrl.dispose();
    notesCtrl.dispose();
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
            // Tên khách hàng
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextFormField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Tên Khách Hàng *',
                  hintText: 'Nhập tên khách hàng',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên khách hàng';
                  }
                  return null;
                },
              ),
            ),

            // Số điện thoại
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextFormField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Số Điện Thoại *',
                  hintText: '0xxxxxxxxx',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập số điện thoại';
                  }
                  if (!RegExp(r'^0[0-9]{9,10}$').hasMatch(value)) {
                    return 'Số điện thoại không hợp lệ';
                  }
                  return null;
                },
              ),
            ),

            // Email
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextFormField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'example@email.com',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value)) {
                      return 'Email không hợp lệ';
                    }
                  }
                  return null;
                },
              ),
            ),

            // Địa chỉ
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextFormField(
                controller: addressCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Địa Chỉ',
                  hintText: 'Nhập địa chỉ đầy đủ',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignLabelWithHint: true,
                ),
              ),
            ),

            // Tỉnh/Thành phố
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextFormField(
                controller: cityCtrl,
                decoration: InputDecoration(
                  labelText: 'Tỉnh/Thành Phố',
                  hintText: 'Nhập tỉnh/thành phố',
                  prefixIcon: const Icon(Icons.domain),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),

            // Ghi chú
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: TextFormField(
                controller: notesCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Ghi Chú',
                  hintText: 'Nhập ghi chú về khách hàng',
                  prefixIcon: const Icon(Icons.note),
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
                      'phone': phoneCtrl.text,
                      'email': emailCtrl.text.isEmpty ? null : emailCtrl.text,
                      'address': addressCtrl.text.isEmpty ? null : addressCtrl.text,
                      'city': cityCtrl.text.isEmpty ? null : cityCtrl.text,
                      'notes': notesCtrl.text.isEmpty ? null : notesCtrl.text,
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