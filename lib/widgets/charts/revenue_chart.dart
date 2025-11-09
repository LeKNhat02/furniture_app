import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RevenueData {
  final String label;
  final double revenue;

  RevenueData({
    required this.label,
    required this.revenue,
  });
}

class RevenueChart extends StatelessWidget {
  final List<RevenueData> data;
  final String title;
  final double? maxHeight;

  const RevenueChart({
    Key? key,
    required this.data,
    this.title = 'Doanh Thu',
    this.maxHeight = 250,
  }) : super(key: key);

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,##0', 'en_US');
    return '${formatter.format(amount)}₫';
  }

  double get maxValue => data.isEmpty ? 1 : data.map((e) => e.revenue).reduce((a, b) => a > b ? a : b);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(
              'Không có dữ liệu',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: maxHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  data.length,
                      (index) {
                    final item = data[index];
                    final heightPercent = (item.revenue / maxValue).clamp(0.1, 1.0);
                    final barHeight = (maxHeight! - 60) * heightPercent;

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Tooltip(
                          message: _formatCurrency(item.revenue),
                          child: Container(
                            width: 30,
                            height: barHeight,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1976D2),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(4),
                                topRight: Radius.circular(4),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.label,
                          style: const TextStyle(fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1976D2).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat(
                    'Tổng',
                    _formatCurrency(data.fold(0.0, (sum, item) => sum + item.revenue)),
                  ),
                  Container(
                    width: 1,
                    height: 30,
                    color: Colors.grey[300],
                  ),
                  _buildStat(
                    'Trung bình',
                    _formatCurrency(data.fold(0.0, (sum, item) => sum + item.revenue) / data.length),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1976D2),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
        ),
      ],
    );
  }
}