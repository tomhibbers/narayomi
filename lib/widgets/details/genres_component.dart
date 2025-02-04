import 'package:flutter/material.dart';

class GenresComponent extends StatelessWidget {
  final List<String> genres;

  const GenresComponent({super.key, required this.genres});

  @override
  Widget build(BuildContext context) {
    return genres.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: SizedBox(
              height: 40, // ✅ Keeps height stable while scrolling
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: BouncingScrollPhysics(), // ✅ Adds smooth drag effect
                child: Row(
                  children: genres.map((genre) => _buildGenreChip(genre)).toList(),
                ),
              ),
            ),
          )
        : SizedBox(); // ✅ Don't show anything if no genres
  }

  Widget _buildGenreChip(String genre) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Chip(
        label: Text(genre, style: TextStyle(fontSize: 12, color: Colors.white)),
        backgroundColor: Colors.grey[800], // ✅ Dark theme friendly
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
