import 'package:flutter/material.dart';

class ReadingScrollIndicator extends StatelessWidget {
  final double scrollProgress;

  const ReadingScrollIndicator({super.key, required this.scrollProgress});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 10,
      top: 100 + (scrollProgress * (MediaQuery.of(context).size.height - 200)), // ✅ Moves down as you scroll
      child: AnimatedOpacity(
        opacity: scrollProgress > 0.02 ? 0.6 : 0.0, // Hide when near the top
        duration: Duration(milliseconds: 300),
        child: Container(
          width: 5,
          height: 40, // Small progress indicator
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
