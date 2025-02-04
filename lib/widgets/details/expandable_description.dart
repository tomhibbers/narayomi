import 'package:flutter/material.dart';

class ExpandableDescription extends StatefulWidget {
  final String description;

  const ExpandableDescription({super.key, required this.description});

  @override
  _ExpandableDescriptionState createState() => _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<ExpandableDescription> {
  bool isExpanded = false;
  final int maxLines = 3; // ✅ Number of lines before collapsing

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedSize(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: isExpanded
                  ? Padding(
                      padding: EdgeInsets.only(bottom: 16), // ✅ Extra padding when expanded
                      child: Text(
                        widget.description,
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    )
                  : ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white,
                            Colors.white,
                            Colors.white.withOpacity(0.7),
                            Colors.white.withOpacity(0.3),
                            Colors.transparent, // ✅ Fade effect at bottom
                          ],
                          stops: [0.0, 0.7, 0.85, 0.95, 1.0],
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.dstIn,
                      child: Text(
                        widget.description,
                        maxLines: maxLines,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ),
            ),
          ],
        ),

        // ✅ Ensuring "Show More" button is positioned at last visible line
        Positioned(
          bottom: isExpanded ? 4 : 0, // ✅ Pushes icon down when expanded
          child: GestureDetector(
            onTap: () => setState(() => isExpanded = !isExpanded),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              color: Colors.transparent,
              child: Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                color: Colors.cyan, // ✅ Easier to see on text
              ),
            ),
          ),
        ),
      ],
    );
  }
}
