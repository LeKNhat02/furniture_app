import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/config/constants.dart';
import '../../providers/payment_provider.dart';
import '../../providers/sale_provider.dart';

class AddPaymentScreen extends StatefulWidget {
  const AddPaymentScreen({Key? key}) : super(key: key);

  @override
  State<AddPaymentScreen> createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends State<AddPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _transactionIdController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedSaleId; // ✅ Đổi thành String? (match với SaleModel.id)
  String _paymentMethod = 'cash'; // cash hoặc transfer
  String _status = 'completed';
  DateTime _paymentDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSales();
    });
  }

  Future<void> _loadSales() async {
    try {
      await context.read<SaleProvider>().loadSales();
    } catch (e) {
      debugPrint('Error loading sales: $e');
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _transactionIdController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedSaleId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng chọn đơn hàng'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    // Validate transaction ID nếu là chuyển khoản
    if (_paymentMethod == 'transfer' &&
        _transactionIdController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng nhập mã giao dịch cho phương thức chuyển khoản'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final paymentData = {
        'sale_id': _selectedSaleId,
        'amount': double.parse(_amountController.text),
        'payment_method': _paymentMethod,
        'status': _status,
        'payment_date': _paymentDate.toIso8601String(),
        if (_transactionIdController.text.trim().isNotEmpty)
          'transaction_id': _transactionIdController.text.trim(),
        if (_notesController.text.trim().isNotEmpty)
          'notes': _notesController.text.trim(),
      };

      final provider = context.read<PaymentProvider>();
      final success = await provider.createPayment(paymentData);

      if (mounted) {
        setState(() => _isLoading = false);

        if (success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tạo thanh toán thành công'),
                backgroundColor: AppColors.success,
                duration: Duration(seconds: 2),
              ),
            );
            Navigator.pop(context, true);
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  provider.errorMessage ?? 'Tạo thanh toán thất bại',
                ),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _selectPaymentDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _paymentDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      setState(() => _paymentDate = picked);
    }
  }

  // ===== BUILD PAYMENT METHOD ITEMS =====
  List<DropdownMenuItem<String>> _buildPaymentMethodItems() {
    return [
      const DropdownMenuItem(
        value: 'cash',
        child: Row(
          children: [
            Icon(Icons.payments, size: 20),
            SizedBox(width: 8),
            Text('Tiền Mặt'),
          ],
        ),
      ),
      const DropdownMenuItem(
        value: 'transfer',
        child: Row(
          children: [
            Icon(Icons.account_balance, size: 20),
            SizedBox(width: 8),
            Text('Chuyển Khoản'),
          ],
        ),
      ),
    ];
  }

  // ===== BUILD STATUS ITEMS =====
  List<DropdownMenuItem<String>> _buildStatusItems() {
    return [
      const DropdownMenuItem(value: 'completed', child: Text('Hoàn Thành')),
      const DropdownMenuItem(value: 'pending', child: Text('Chờ Xử Lý')),
      const DropdownMenuItem(value: 'failed', child: Text('Thất Bại')),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm Thanh Toán'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0), // AppSpacing.lg
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===== SALE SELECTION =====
                  Text(
                    'Chọn Đơn Hàng *',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8.0), // AppSpacing.sm
                  Consumer<SaleProvider>(
                    builder: (context, saleProvider, _) {
                      if (saleProvider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final saleItems = saleProvider.sales
                          .map((sale) => DropdownMenuItem<String>(
                        value: sale.id, // ✅ sale.id là String
                        child: Text(
                          'Đơn #${sale.id} - ${NumberFormat.currency(
                            locale: 'vi_VN',
                            symbol: 'VNĐ ',
                          ).format(sale.total)}',
                        ),
                      ))
                          .toList();

                      return DropdownButtonFormField<String>(
                        value: _selectedSaleId,
                        decoration: InputDecoration(
                          hintText: 'Chọn đơn hàng',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 16.0,
                          ),
                        ),
                        items: saleItems,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedSaleId = value;
                              try {
                                final selectedSale = saleProvider.sales
                                    .firstWhere((s) => s.id == value);
                                _amountController.text =
                                    selectedSale.total.toStringAsFixed(0);
                              } catch (e) {
                                debugPrint('Error finding sale: $e');
                              }
                            });
                          }
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Vui lòng chọn đơn hàng';
                          }
                          return null;
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 16.0), // AppSpacing.lg

                  // ===== AMOUNT =====
                  Text(
                    'Số Tiền *',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Nhập số tiền',
                      prefixIcon: const Icon(Icons.attach_money),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 16.0,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập số tiền';
                      }
                      final amount = double.tryParse(value);
                      if (amount == null || amount <= 0) {
                        return 'Số tiền phải là số dương';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16.0),

                  // ===== PAYMENT METHOD =====
                  Text(
                    'Phương Thức Thanh Toán *',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  DropdownButtonFormField<String>(
                    value: _paymentMethod,
                    decoration: InputDecoration(
                      hintText: 'Chọn phương thức',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 16.0,
                      ),
                    ),
                    items: _buildPaymentMethodItems(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _paymentMethod = value);
                        // Xóa mã giao dịch nếu chọn tiền mặt
                        if (value == 'cash') {
                          _transactionIdController.clear();
                        }
                      }
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Vui lòng chọn phương thức';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16.0),

                  // ===== STATUS =====
                  Text(
                    'Trạng Thái *',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  DropdownButtonFormField<String>(
                    value: _status,
                    decoration: InputDecoration(
                      hintText: 'Chọn trạng thái',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 16.0,
                      ),
                    ),
                    items: _buildStatusItems(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _status = value);
                      }
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Vui lòng chọn trạng thái';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16.0),

                  // ===== PAYMENT DATE =====
                  Text(
                    'Ngày Thanh Toán *',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  InkWell(
                    onTap: _selectPaymentDate,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 16.0,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            dateFormat.format(_paymentDate),
                            style: const TextStyle(fontSize: 14),
                          ),
                          const Icon(Icons.calendar_today,
                              color: AppColors.primary),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16.0),

                  // ===== TRANSACTION ID (Conditional) =====
                  if (_paymentMethod == 'transfer') ...[
                    Text(
                      'Mã Giao Dịch *',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    TextFormField(
                      controller: _transactionIdController,
                      decoration: InputDecoration(
                        hintText: 'Mã giao dịch từ ngân hàng',
                        prefixIcon: const Icon(Icons.confirmation_number),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 16.0,
                        ),
                      ),
                      validator: (value) {
                        if (_paymentMethod == 'transfer' &&
                            (value == null || value.isEmpty)) {
                          return 'Mã giao dịch không được bỏ trống';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                  ],

                  // ===== NOTES =====
                  Text(
                    'Ghi Chú (Tuỳ Chọn)',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  TextFormField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      hintText: 'Nhập ghi chú...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 16.0,
                      ),
                    ),
                    maxLines: 3,
                    minLines: 2,
                  ),

                  const SizedBox(height: 32.0), // AppSpacing.xl

                  // ===== BUTTONS =====
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed:
                          _isLoading ? null : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16.0,
                            ),
                          ),
                          child: const Text('Hủy'),
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleSave,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(
                              vertical: 16.0,
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white),
                            ),
                          )
                              : const Text(
                            'Tạo Thanh Toán',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}