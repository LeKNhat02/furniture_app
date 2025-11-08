import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/config/constants.dart';
import '../../providers/payment_provider.dart';
import '../../providers/sale_provider.dart';
import 'payment_detail_screen.dart';
import 'add_payment_screen.dart';

class PaymentListScreen extends StatefulWidget {
  const PaymentListScreen({Key? key}) : super(key: key);

  @override
  State<PaymentListScreen> createState() => _PaymentListScreenState();
}

class _PaymentListScreenState extends State<PaymentListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentProvider>().fetchPayments();
      context.read<SaleProvider>().fetchSales();
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
          _buildFilterBar(),
          Expanded(child: _buildPaymentList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddPaymentScreen()),
          );
          if (result == true && mounted) {
            context.read<PaymentProvider>().fetchPayments();
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
          context.read<PaymentProvider>().searchPayments(value);
        },
        decoration: InputDecoration(
          hintText: 'Tìm kiếm thanh toán...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<PaymentProvider>().searchPayments('');
                  },
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Consumer<PaymentProvider>(
      builder: (context, provider, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String?>(
                  value: provider.selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'Trạng Thái',
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    isDense: true,
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Tất Cả')),
                    const DropdownMenuItem(value: 'completed', child: Text('Hoàn Thành')),
                    const DropdownMenuItem(value: 'pending', child: Text('Chờ Xử Lý')),
                    const DropdownMenuItem(value: 'failed', child: Text('Thất Bại')),
                    const DropdownMenuItem(value: 'refunded', child: Text('Đã Hoàn')),
                  ],
                  onChanged: (value) => provider.filterByStatus(value),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String?>(
                  value: provider.selectedPaymentMethod,
                  decoration: InputDecoration(
                    labelText: 'Phương Thức',
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    isDense: true,
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Tất Cả')),
                    ...AppConstants.paymentMethods.map((method) => DropdownMenuItem(
                          value: method,
                          child: Text(method),
                        )),
                  ],
                  onChanged: (value) => provider.filterByPaymentMethod(value),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentList() {
    return Consumer<PaymentProvider>(
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
                  onPressed: () => provider.fetchPayments(),
                  child: const Text('Thử Lại'),
                ),
              ],
            ),
          );
        }

        if (provider.payments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.payment, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('Không có thanh toán nào', style: TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.fetchPayments(),
                  child: const Text('Tải Lại'),
                ),
              ],
            ),
          );
        }

        final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.payments.length,
          itemBuilder: (context, index) {
            final payment = provider.payments[index];
            return _buildPaymentCard(context, payment, dateFormat);
          },
        );
      },
    );
  }

  Widget _buildPaymentCard(BuildContext context, dynamic payment, DateFormat dateFormat) {
    final statusColor = payment.status == 'completed'
        ? Colors.green
        : payment.status == 'pending'
            ? Colors.orange
            : payment.status == 'failed'
                ? Colors.red
                : Colors.grey;

    final statusText = payment.status == 'completed'
        ? 'Hoàn Thành'
        : payment.status == 'pending'
            ? 'Chờ Xử Lý'
            : payment.status == 'failed'
                ? 'Thất Bại'
                : 'Đã Hoàn';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PaymentDetailScreen(paymentId: payment.id)),
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
                        if (payment.saleName != null)
                          Text(
                            payment.saleName!,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          )
                        else
                          Text(
                            'Đơn #${payment.saleId}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        const SizedBox(height: 4),
                        if (payment.customerName != null)
                          Text(
                            payment.customerName!,
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: statusColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Phương Thức', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      Text(
                        payment.getPaymentMethodDisplay(),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Số Tiền', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      Text(
                        '${payment.amount.toStringAsFixed(0)}${AppConstants.currencySymbol}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                dateFormat.format(payment.paymentDate),
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

