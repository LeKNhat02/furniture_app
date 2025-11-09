import 'package:flutter/material.dart';

class FilterDialog extends StatefulWidget {
  final String title;
  final List<FilterOption> options;
  final Function(List<String>) onApply;
  final List<String>? initialSelected;

  const FilterDialog({
    Key? key,
    required this.title,
    required this.options,
    required this.onApply,
    this.initialSelected,
  }) : super(key: key);

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class FilterOption {
  final String id;
  final String label;
  final IconData? icon;

  FilterOption({
    required this.id,
    required this.label,
    this.icon,
  });
}

class _FilterDialogState extends State<FilterDialog> {
  late List<String> selectedOptions;

  @override
  void initState() {
    super.initState();
    selectedOptions = widget.initialSelected ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.options.length,
          itemBuilder: (context, index) {
            final option = widget.options[index];
            final isSelected = selectedOptions.contains(option.id);

            return CheckboxListTile(
              title: Row(
                children: [
                  if (option.icon != null) ...[
                    Icon(option.icon, size: 18, color: const Color(0xFF1976D2)),
                    const SizedBox(width: 8),
                  ],
                  Text(option.label),
                ],
              ),
              value: isSelected,
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    selectedOptions.add(option.id);
                  } else {
                    selectedOptions.remove(option.id);
                  }
                });
              },
              activeColor: const Color(0xFF1976D2),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        TextButton(
          onPressed: () {
            setState(() => selectedOptions = []);
            Navigator.pop(context);
          },
          child: const Text('Xóa Bộ Lọc'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onApply(selectedOptions);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1976D2),
          ),
          child: const Text('Áp Dụng'),
        ),
      ],
    );
  }
}

// Helper function
Future<List<String>?> showCustomFilterDialog(
    BuildContext context, {
      required String title,
      required List<FilterOption> options,
      List<String>? initialSelected,
    }) async {
  List<String>? result;
  await showDialog(
    context: context,
    builder: (context) => FilterDialog(
      title: title,
      options: options,
      initialSelected: initialSelected,
      onApply: (selected) => result = selected,
    ),
  );
  return result;
}