import 'package:flutter/material.dart';
import '../models/publication.dart';

class InfoComponent extends StatelessWidget {
  final Publication publication;

  const InfoComponent({super.key, required this.publication});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ Full-height Cover Image (Left Column)
        if (publication.thumbnailUrl != null)
          Image.network(
            publication.thumbnailUrl!,
            width: 120,
            height: 160,
            fit: BoxFit.cover,
          )
        else
          Container(
            width: 120,
            height: 160,
            color: Colors.grey[300], // Placeholder
            child: Icon(Icons.image_not_supported, size: 50),
          ),

        SizedBox(width: 12), // Spacing between image & text info

        // ✅ Right Column: Title + Author + Status
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Title
              Text(
                publication.title,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),

              // ✅ Author Row
              Row(
                children: [
                  Icon(Icons.person, size: 18, color: Colors.grey),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      publication.author ?? "Unknown Author",
                      style: TextStyle(fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),

              // ✅ Status Row
              Row(
                children: [
                  Icon(Icons.check_circle_outline,
                      size: 18, color: Colors.grey),
                  SizedBox(width: 6),
                  Text(
                    publication.status ?? "Unknown Status",
                    style: TextStyle(fontSize: 16),
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
