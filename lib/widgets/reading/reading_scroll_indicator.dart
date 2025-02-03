import 'package:flutter/material.dart';

class ReadingScrollIndicator extends StatelessWidget {
  final double scrollProgress;

  const ReadingScrollIndicator({
    super.key,
    required this.scrollProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 10,
      top: MediaQuery.of(context).size.height * scrollProgress,
      child: Container(
        width: 5,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7), // ✅ Ensure visibility
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }
}
