
import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trang Chủ')),
      body: const Center(
        child: Text('Dashboard Screen - Coming Soon'),
      ),
    );
  }
}