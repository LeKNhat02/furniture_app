import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_providers.dart';
import 'providers/product_provider.dart';
import 'providers/customer_provider.dart';
import 'providers/sale_provider.dart';
import 'providers/inventory_provider.dart';
import 'providers/supplier_provider.dart';
import 'providers/promotion_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/main_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => SaleProvider()),
        ChangeNotifierProvider(create: (_) => InventoryProvider()),
        ChangeNotifierProvider(create: (_) => SupplierProvider()),
        ChangeNotifierProvider(create: (_) => PromotionProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Furniture Management',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            return authProvider.isLoggedIn
                ? const MainLayout()
                : const LoginScreen();
          },
        ),
      ),
    );
  }
}