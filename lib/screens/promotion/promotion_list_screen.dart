import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/config/constants.dart';
import '../../providers/promotion_provider.dart';
import 'add_promotion_screen.dart';
import 'edit_promotion_screen.dart';
import 'promotion_detail_screen.dart';

class PromotionListScreen extends StatefulWidget {
  const PromotionListScreen({Key? key}) : super(key: key);

  @override
  State<PromotionListScreen> createState() => _PromotionListScreenState();
}

class _PromotionListScreenState extends State<PromotionListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PromotionProvider>().fetchPromotions();
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
          Expanded(child: _buildPromotionList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddPromotionScreen()),
          );
          if (result == true && mounted) {
            context.read<PromotionProvider>().fetchPromotions();
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
          context.read<PromotionProvider>().searchPromotions(value);
        },
        decoration: InputDecoration(
          hintText: 'Tìm kiếm khuyến mãi...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<PromotionProvider>().searchPromotions('');
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
    return Consumer<PromotionProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              FilterChip(
                label: const Text('Tất Cả'),
                selected: provider.promotions == provider.promotions,
                onSelected: (_) => provider.filterByActive(null),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('Đang Hoạt Động'),
                selected: false,
                onSelected: (_) => provider.filterByActive(true),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('Đã Hết Hạn'),
                selected: false,
                onSelected: (_) => provider.filterByActive(false),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPromotionList() {
    return Consumer<PromotionProvider>(
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
                  onPressed: () => provider.fetchPromotions(),
                  child: const Text('Thử Lại'),
                ),
              ],
            ),
          );
        }

        if (provider.promotions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.local_offer, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('Không có khuyến mãi nào', style: TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.fetchPromotions(),
                  child: const Text('Tải Lại'),
                ),
              ],
            ),
          );
        }

        final dateFormat = DateFormat('dd/MM/yyyy');

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.promotions.length,
          itemBuilder: (context, index) {
            final promotion = provider.promotions[index];
            return _buildPromotionCard(context, promotion, dateFormat);
          },
        );
      },
    );
  }

  Widget _buildPromotionCard(BuildContext context, dynamic promotion, DateFormat dateFormat) {
    final isValid = promotion.isValid;
    final discountText = promotion.discountType == 'percentage'
        ? '${promotion.discountValue.toStringAsFixed(0)}%'
        : '${promotion.discountValue.toStringAsFixed(0)}${AppConstants.currencySymbol}';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PromotionDetailScreen(promotionId: promotion.id)),
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
                    child: Text(
                      promotion.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isValid ? Colors.green[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isValid ? 'Hoạt Động' : 'Hết Hạn',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isValid ? Colors.green : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.local_offer, size: 16, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    'Giảm $discountText',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Từ ${dateFormat.format(promotion.startDate)} đến ${dateFormat.format(promotion.endDate)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    iconSize: 20,
                    color: AppColors.primary,
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => EditPromotionScreen(promotion: promotion)),
                      );
                      if (result == true && mounted) {
                        context.read<PromotionProvider>().fetchPromotions();
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    iconSize: 20,
                    color: Colors.red,
                    onPressed: () => _showDeleteConfirmDialog(context, promotion),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, dynamic promotion) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác Nhận Xóa'),
          content: Text('Bạn có chắc chắn muốn xóa "${promotion.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<PromotionProvider>().deletePromotion(promotion.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã xóa khuyến mãi'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Xóa', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

