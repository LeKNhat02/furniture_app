import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/config/constants.dart';
import '../../providers/promotion_provider.dart';
import 'edit_promotion_screen.dart';

class PromotionDetailScreen extends StatefulWidget {
  final String promotionId;

  const PromotionDetailScreen({Key? key, required this.promotionId}) : super(key: key);

  @override
  State<PromotionDetailScreen> createState() => _PromotionDetailScreenState();
}

class _PromotionDetailScreenState extends State<PromotionDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PromotionProvider>().fetchPromotionById(widget.promotionId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi Tiết Khuyến Mãi')),
      body: Consumer<PromotionProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.selectedPromotion == null) {
            return const Center(child: Text('Không tìm thấy khuyến mãi'));
          }

          final promotion = provider.selectedPromotion!;
          final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
          final discountText = promotion.discountType == 'percentage'
              ? '${promotion.discountValue.toStringAsFixed(0)}%'
              : '${promotion.discountValue.toStringAsFixed(0)}${AppConstants.currencySymbol}';

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
                                promotion.name,
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: promotion.isValid ? Colors.green.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                promotion.isValid ? 'Hoạt Động' : 'Hết Hạn',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: promotion.isValid ? Colors.green : Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(Icons.local_offer, 'Giảm Giá', discountText),
                        if (promotion.minPurchase != null)
                          _buildInfoRow(Icons.shopping_cart, 'Đơn Hàng Tối Thiểu',
                              '${promotion.minPurchase!.toStringAsFixed(0)}${AppConstants.currencySymbol}'),
                        if (promotion.maxDiscount != null)
                          _buildInfoRow(Icons.trending_down, 'Giảm Tối Đa',
                              '${promotion.maxDiscount!.toStringAsFixed(0)}${AppConstants.currencySymbol}'),
                        _buildInfoRow(Icons.calendar_today, 'Ngày Bắt Đầu', dateFormat.format(promotion.startDate)),
                        _buildInfoRow(Icons.event_busy, 'Ngày Kết Thúc', dateFormat.format(promotion.endDate)),
                        if (promotion.description != null && promotion.description!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Text('Mô Tả', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(promotion.description!),
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
                        MaterialPageRoute(builder: (_) => EditPromotionScreen(promotion: promotion)),
                      );
                      if (result == true && mounted) {
                        provider.fetchPromotionById(widget.promotionId);
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

