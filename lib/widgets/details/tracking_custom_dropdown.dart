import 'package:flutter/material.dart';

class TrackingCustomDropdown extends StatelessWidget {
  final String label;
  final int currentValue;
  final Map<int, String> items;
  final ValueChanged<int> onChanged;

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
        DropdownButton<int>(
          isExpanded: true,
          value:
              items.containsKey(currentValue) ? currentValue : items.keys.first,
          dropdownColor: Theme.of(context).colorScheme.surface,
          items: items.entries.map((entry) {
            return DropdownMenuItem<int>(
              value: entry.key,
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline,
                      size: 16, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 10),
                  Text(entry.value),
                ],
              ),
            );
          }).toList(),
          onChanged: (int? newValue) {
            if (newValue != null) onChanged(newValue);
          },
        )
      ],
    );
  }
}
