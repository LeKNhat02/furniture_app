import 'dart:async';

import 'package:flutter/material.dart';
import 'package:furniture_app/screens/product/edit_product_screen.dart';
import 'package:provider/provider.dart';
import '../../core/config/constants.dart';
import '../../providers/product_provider.dart';
import 'product_detail_screen.dart';
import 'add_product_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Tải danh sách sản phẩm khi vào screen
    final provider = Provider.of<ProductProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider.fetchProducts();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản Lý Sản Phẩm'),
        elevation: 0,
        actions: [
          // Nút refresh
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ProductProvider>().fetchProducts();
            },
          ),
          // Nút low stock
          IconButton(
            icon: const Icon(Icons.warning),
            tooltip: 'Hàng sắp hết',
            onPressed: () {
              context.read<ProductProvider>().filterLowStock();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          _buildSearchBar(),

          // Category Filter
          _buildCategoryFilter(),

          // Product List
          Expanded(
            child: _buildProductList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Capture provider reference before awaiting navigation to avoid using
          // BuildContext across async gaps (fix analyzer warning).
          final provider = Provider.of<ProductProvider>(context, listen: false);
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddProductScreen(),
            ),
          );
          // Reload danh sách nếu có sản phẩm mới được tạo
          if (result == true && mounted) {
            provider.fetchProducts();
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  // Search Bar
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          // Debounce search
          if (_debounce?.isActive ?? false) _debounce!.cancel();
          _debounce = Timer(const Duration(milliseconds: 450), () {
            if (!mounted) return;
            context.read<ProductProvider>().searchProducts(value);
          });
        },
        decoration: InputDecoration(
          hintText: 'Tìm kiếm sản phẩm...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              if (mounted) context.read<ProductProvider>().searchProducts('');
            },
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  // Category Filter
  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: AppConstants.productCategories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            // "All" button
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Consumer<ProductProvider>(
                builder: (context, provider, _) {
                  final isSelected = provider.selectedCategory == null;
                  return FilterChip(
                    label: const Text('Tất Cả'),
                    selected: isSelected,
                    onSelected: (_) {
                      provider.clearFilters();
                      provider.fetchProducts();
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            );
          }

          final category = AppConstants.productCategories[index - 1];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Consumer<ProductProvider>(
              builder: (context, provider, _) {
                final isSelected = provider.selectedCategory == category;
                return FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (_) {
                    provider.filterByCategory(category);
                  },
                  backgroundColor: Colors.grey[200],
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  // Product List
  Widget _buildProductList() {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        // Loading state
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Error state
        if (provider.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  provider.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    provider.fetchProducts();
                  },
                  child: const Text('Thử Lại'),
                ),
              ],
            ),
          );
        }

        // Empty state
        if (provider.products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.inbox,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Không có sản phẩm nào',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    provider.fetchProducts();
                  },
                  child: const Text('Tải Lại'),
                ),
              ],
            ),
          );
        }

        // Product list
        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: provider.products.length + (provider.isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < provider.products.length) {
              final product = provider.products[index];
              return _buildProductCard(context, product);
            }

            // Loading more indicator
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator()),
            );
          },
        );
      },
    );
  }

  void _onScroll() {
    final provider = context.read<ProductProvider>();
    if (!_scrollController.hasClients) return;
    final threshold = 200; // px before end
    final maxScroll = _scrollController.position.maxScrollExtent;
    final current = _scrollController.offset;
    if (maxScroll - current <= threshold) {
      // load next page
      if (!provider.isLoadingMore && provider.hasMore && !provider.isLoading) {
        provider.fetchProducts(page: provider.currentPage + 1);
      }
    }
  }

  // Product Card
  Widget _buildProductCard(BuildContext context, dynamic product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(productId: product.id),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: Image, Name and Category
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnail
                  if (product.imageUrl != null && product.imageUrl!.isNotEmpty)
                    Container(
                      width: 72,
                      height: 72,
                      margin: const EdgeInsets.only(right: 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.broken_image, color: Colors.grey),
                          ),
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  value: progress.expectedTotalBytes != null
                                      ? progress.cumulativeBytesLoaded / (progress.expectedTotalBytes ?? 1)
                                      : null,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 72,
                      height: 72,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.image_not_supported, color: Colors.grey),
                    ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.category,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Stock Status Badge
                  _buildStockBadge(product),
                ],
              ),
              const SizedBox(height: 12),

              // Price row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Price
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Giá Bán',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '${product.price.toStringAsFixed(0)}${AppConstants.currencySymbol}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),

                  // Cost
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Giá Vốn',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '${product.cost.toStringAsFixed(0)}${AppConstants.currencySymbol}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  // Profit
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lợi Nhuận',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '${(product.price - product.cost).toStringAsFixed(0)}${AppConstants.currencySymbol}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Quantity row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tồn Kho: ${product.quantity}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Action buttons
                  Row(
                    children: [
                      // Edit button
                      IconButton(
                        icon: const Icon(Icons.edit),
                        iconSize: 20,
                        color: AppColors.primary,
                        onPressed: () async {
                          final provider = Provider.of<ProductProvider>(context, listen: false);
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditProductScreen(product: product)
                            )
                          );
                          if (result == true && mounted) {
                            provider.fetchProducts();
                          }
                        },
                      ),
                      // Delete button
                      IconButton(
                        icon: const Icon(Icons.delete),
                        iconSize: 20,
                        color: Colors.red,
                        onPressed: () {
                          _showDeleteConfirmDialog(context, product);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Stock Badge
  Widget _buildStockBadge(dynamic product) {
    final isLowStock = product.isLowStock;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: isLowStock ? Colors.red[100] : Colors.green[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isLowStock ? 'Sắp Hết' : 'Đủ Hàng',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isLowStock ? Colors.red : Colors.green,
        ),
      ),
    );
  }

  // Delete Confirm Dialog
  void _showDeleteConfirmDialog(BuildContext context, dynamic product) {
    final provider = Provider.of<ProductProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Xác Nhận Xóa'),
          content: Text('Bạn có chắc chắn muốn xóa "${product.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                final success = await provider.deleteProduct(product.id);
                if (!mounted) return;
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã xóa sản phẩm'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(provider.errorMessage ?? 'Xóa thất bại'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              },
              child: const Text(
                'Xóa',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}