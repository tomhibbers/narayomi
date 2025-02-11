import 'package:flutter/material.dart';

class TrackingCustomDropdown extends StatelessWidget {
  final String label;
  final String currentValue;
  final List<String> items;
  final ValueChanged<String> onChanged;

  const TrackingCustomDropdown({
    required this.label,
    required this.currentValue,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 4),
        DropdownButton<String>(
          isExpanded: true,
          value: items.contains(currentValue) ? currentValue : items.first,
          dropdownColor: Theme.of(context).colorScheme.surface,
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline,
                      size: 16, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 10),
                  Text(item),
                ],
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) onChanged(newValue);
          },
        )
      ],
    );
  }
}
