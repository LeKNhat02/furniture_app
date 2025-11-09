import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BarChartData {
  final String label;
  final double value;
  final Color? color;

  BarChartData({
    required this.label,
    required this.value,
    this.color,
  });
}

class BarChart extends StatelessWidget {
  final List<BarChartData> data;
  final String title;
  final String? yAxisLabel;
  final double? maxHeight;

  const BarChart({
    Key? key,
    required this.data,
    this.title = 'Biểu Đồ Cột',
    this.yAxisLabel,
    this.maxHeight = 300,
  }) : super(key: key);

  String _formatValue(double value) {
    if (value > 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value > 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }

  double get maxValue => data.isEmpty ? 1 : data.map((e) => e.value).reduce((a, b) => a > b ? a : b);

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
                children: [
                  if (yAxisLabel != null)
                    SizedBox(
                      width: 40,
                      child: Text(
                        yAxisLabel!,
                        style: const TextStyle(fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        data.length,
                            (index) {
                          final item = data[index];
                          final heightPercent = (item.value / maxValue).clamp(0.1, 1.0);
                          final barHeight = (maxHeight! - 60) * heightPercent;

                          return Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Tooltip(
                                message: item.value.toStringAsFixed(0),
                                child: Container(
                                  width: 25,
                                  height: barHeight,
                                  decoration: BoxDecoration(
                                    color: item.color ?? const Color(0xFF2196F3),
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
                                style: const TextStyle(fontSize: 9),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Tổng: ${_formatValue(data.fold(0.0, (sum, item) => sum + item.value))}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2196F3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}