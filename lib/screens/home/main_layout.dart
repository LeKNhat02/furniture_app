import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config/constants.dart';
import '../../providers/auth_providers.dart';
import '../../providers/product_provider.dart';
import '../product/product_list_screen.dart';
import '../customer/customer_list_screen.dart';
import '../sales/sale_list_screen.dart';
import '../inventory/inventory_list_screen.dart';
import '../supplier/supplier_list_screen.dart';
import '../promotion/promotion_list_screen.dart';
import '../report/report_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({Key? key}) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<DrawerItem> _menuItems = [
    const DrawerItem(
      icon: Icons.home,
      label: '1. Trang Chủ',
      index: 0,
    ),
    const DrawerItem(
      icon: Icons.shopping_bag,
      label: '2. Quản Lý Sản Phẩm',
      index: 1,
    ),
    const DrawerItem(
      icon: Icons.inventory_2,
      label: '3. Quản Lý Kho Hàng',
      index: 2,
    ),
    const DrawerItem(
      icon: Icons.shopping_cart,
      label: '4. Quản Lý Bán Hàng',
      index: 3,
    ),
    const DrawerItem(
      icon: Icons.people,
      label: '5. Quản Lý Khách Hàng',
      index: 4,
    ),
    const DrawerItem(
      icon: Icons.bar_chart,
      label: '6. Báo Cáo & Thống Kê',
      index: 5,
    ),
    const DrawerItem(
      icon: Icons.admin_panel_settings,
      label: '7. Quản Lý Người Dùng',
      index: 6,
    ),
    const DrawerItem(
      icon: Icons.payment,
      label: '8. Thanh Toán Cơ Bản',
      index: 7,
    ),
    const DrawerItem(
      icon: Icons.business,
      label: '9. Quản Lý Nhà Cung Cấp',
      index: 8,
    ),
    const DrawerItem(
      icon: Icons.local_offer,
      label: '10. Quản Lý Khuyến Mãi',
      index: 9,
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Tải dữ liệu sản phẩm khi vào app
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(),
      appBar: AppBar(
        title: Text(_menuItems[_currentIndex].label),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: _buildContent(),
    );
  }

  // Build content dựa theo menu index
  Widget _buildContent() {
    switch (_currentIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return const ProductListScreen();
      case 2:
        return const InventoryListScreen();
      case 3:
        return const SaleListScreen();
      case 4:
        return const CustomerListScreen();
      case 5:
        return const ReportScreen();
      case 6:
        return _buildPlaceholder(_menuItems[_currentIndex].label); // Quản Lý Người Dùng
      case 7:
        return _buildPlaceholder(_menuItems[_currentIndex].label); // Thanh Toán Cơ Bản
      case 8:
        return const SupplierListScreen();
      case 9:
        return const PromotionListScreen();
      default:
        return _buildPlaceholder(_menuItems[_currentIndex].label);
    }
  }

  // Dashboard content
  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeSection(),
          const SizedBox(height: 24),
          _buildQuickStats(),
          const SizedBox(height: 24),
          _buildLowStockSection(),
        ],
      ),
    );
  }

  // Welcome section
  Widget _buildWelcomeSection() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Xin chào, ${authProvider.currentUser?.username ?? 'Bạn'}!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Chào mừng bạn quay lại hệ thống quản lý nội thất',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        );
      },
    );
  }

  // Quick stats section
  Widget _buildQuickStats() {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        final totalProducts = provider.products.length;
        final totalValue = provider.products.fold<double>(
          0,
              (sum, product) => sum + (product.price * product.quantity),
        );
        final lowStockCount = provider.products
            .where((p) => p.quantity <= p.quantityMin)
            .length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thống Kê Nhanh',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.inventory_2,
                    label: 'Tổng Sản Phẩm',
                    value: '$totalProducts',
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.attach_money,
                    label: 'Giá Trị Kho',
                    value: '${(totalValue / 1000000).toStringAsFixed(1)}M',
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.warning,
                    label: 'Hàng Sắp Hết',
                    value: '$lowStockCount',
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.check_circle,
                    label: 'Đủ Hàng',
                    value: '${totalProducts - lowStockCount}',
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // Stat card widget
  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Low stock products section
  Widget _buildLowStockSection() {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        final lowStockProducts = provider.products
            .where((p) => p.quantity <= p.quantityMin)
            .toList();

        if (lowStockProducts.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hàng Sắp Hết',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount:
              lowStockProducts.length > 3 ? 3 : lowStockProducts.length,
              itemBuilder: (context, index) {
                final product = lowStockProducts[index];
                return _buildLowStockItem(product);
              },
            ),
          ],
        );
      },
    );
  }

  // Low stock item
  Widget _buildLowStockItem(dynamic product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red[200]!),
        borderRadius: BorderRadius.circular(8),
        color: Colors.red[50],
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: Colors.red[700], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Tồn kho: ${product.quantity}/${product.quantityMin}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red[700],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Cảnh báo',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Placeholder screen
  Widget _buildPlaceholder(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Đang phát triển - Sắp ra mắt',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // Build drawer
  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          // Drawer Header
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 30,
                  child: Text(
                    (context.read<AuthProvider>().currentUser?.username ?? 'U')
                        .substring(0, 1)
                        .toUpperCase(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  context.read<AuthProvider>().currentUser?.username ?? 'User',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.read<AuthProvider>().currentUser?.role ?? 'User',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Menu Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                final item = _menuItems[index];
                final isActive = _currentIndex == item.index;

                return Container(
                  color: isActive ? AppColors.primary.withOpacity(0.1) : null,
                  child: ListTile(
                    leading: Icon(
                      item.icon,
                      color:
                      isActive ? AppColors.primary : Colors.grey[600],
                    ),
                    title: Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                        isActive ? FontWeight.bold : FontWeight.normal,
                        color:
                        isActive ? AppColors.primary : Colors.black87,
                      ),
                    ),
                    onTap: () {
                      setState(() => _currentIndex = item.index);
                      Navigator.of(context).pop();
                    },
                  ),
                );
              },
            ),
          ),

          // Divider
          const Divider(),

          // Logout button
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  context.read<AuthProvider>().logout();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login',
                        (route) => false,
                  );
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, size: 18),
                    SizedBox(width: 8),
                    Text('Đăng Xuất'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Model cho menu item
class DrawerItem {
  final IconData icon;
  final String label;
  final int index;

  const DrawerItem({
    required this.icon,
    required this.label,
    required this.index,
  });
}