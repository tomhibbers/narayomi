import 'package:flutter/material.dart';
import 'package:narayomi/models/publication.dart';

class PublicationInfo extends StatelessWidget {
  final Publication publication;

  const PublicationInfo({super.key, required this.publication});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// ✅ Cover Image (Handles Null Case)
        ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: publication.thumbnailUrl != null &&
                  publication.thumbnailUrl!.isNotEmpty
              ? Image.network(
                  publication.thumbnailUrl!,
                  width: 100,
                  height: 140,
                  fit: BoxFit.cover,
                )
              : Container(
                  width: 100,
                  height: 140,
                  color: Colors.grey[800], // ✅ Placeholder background
                  child: Icon(Icons.image,
                      color: Colors.grey[600], size: 50), // ✅ Placeholder Icon
                ),
        ),
        SizedBox(width: 12),

        /// ✅ Title, Author, Status (Handles Null Values)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                publication.title.isNotEmpty
                    ? publication.title
                    : "Unknown Title",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color:
                      Colors.white, // ✅ Ensures visibility on dark backgrounds
                ),
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.person, size: 18, color: Colors.white70),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      publication.author?.isNotEmpty == true
                          ? publication.author!
                          : "Unknown Author",
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.check_circle_outline,
                      size: 18, color: Colors.greenAccent),
                  SizedBox(width: 6),
                  Text(
                    publication.status?.isNotEmpty == true
                        ? publication.status!
                        : "Unknown Status",
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
