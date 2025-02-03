import 'package:flutter/material.dart';

class ExpandableDescription extends StatefulWidget {
  final String description;

  const ExpandableDescription({super.key, required this.description});

  @override
  _ExpandableDescriptionState createState() => _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<ExpandableDescription> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textWidget = Text(
          widget.description,
          maxLines: isExpanded ? null : 2,
          overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            textWidget,
            SizedBox(height: 4),
            if (widget.description.length > 100)
              GestureDetector(
                onTap: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
                child: Text(
                  isExpanded ? "Show Less ▲" : "Show More ▼",
                  style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        );
      },
    );
  }
}
