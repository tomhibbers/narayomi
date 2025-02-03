import 'package:flutter/material.dart';
import 'package:narayomi/models/publication.dart';

class PublicationInfo extends StatelessWidget {
  final Publication publication;

  const PublicationInfo({super.key, required this.publication});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ✅ Cover Image
        ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.network(
            publication.thumbnailUrl!,
            width: 100,
            height: 140,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(width: 12),

        // ✅ Title, Author, Status
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                publication.title,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.person, size: 18, color: Colors.white70),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      publication.author ?? "Unknown Author",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.check_circle_outline, size: 18, color: Colors.white70),
                  SizedBox(width: 6),
                  Text(
                    publication.status ?? "Unknown Status",
                    style: TextStyle(fontSize: 16, color: Colors.white),
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
