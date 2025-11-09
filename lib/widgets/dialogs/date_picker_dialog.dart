import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerDialog extends StatefulWidget {
  final String title;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final Function(DateTime) onDateSelected;

  const DatePickerDialog({
    Key? key,
    required this.title,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    required this.onDateSelected,
  }) : super(key: key);

  @override
  State<DatePickerDialog> createState() => _DatePickerDialogState();
}

class _DatePickerDialogState extends State<DatePickerDialog> {
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1976D2).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  DateFormat('EEEE, dd/MM/yyyy', 'vi_VN').format(selectedDate),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1976D2),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            CalendarDatePicker(
              initialDate: selectedDate,
              firstDate: widget.firstDate ?? DateTime(2000),
              lastDate: widget.lastDate ?? DateTime(2100),
              onDateChanged: (date) {
                setState(() => selectedDate = date);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onDateSelected(selectedDate);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1976D2),
          ),
          child: const Text('Chọn'),
        ),
      ],
    );
  }
}

// Helper function
Future<DateTime?> showCustomDatePicker(
    BuildContext context, {
      required String title,
      DateTime? initialDate,
      DateTime? firstDate,
      DateTime? lastDate,
    }) async {
  DateTime? result;
  await showDialog(
    context: context,
    builder: (context) => DatePickerDialog(
      title: title,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      onDateSelected: (date) => result = date,
    ),
  );
  return result;
}