import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:narayomi/models/publication.dart';
import 'package:narayomi/pages/details_page.dart';

class PublicationCard extends StatelessWidget {
  final Publication publication;

  const PublicationCard({super.key, required this.publication});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.background, // ✅ Dark theme styling
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ListTile(
        leading: publication.thumbnailUrl != null
            ? Image.network(publication.thumbnailUrl!,
                width: 50, height: 75, fit: BoxFit.cover)
            : Icon(Icons.book,
                size: 50, color: Theme.of(context).colorScheme.onBackground), // ✅ Placeholder if no image
        title: Text(publication.title,
            style: TextStyle(color: Theme.of(context).colorScheme.onBackground, fontWeight: FontWeight.bold)),
        subtitle: Text(publication.author ?? "Unknown Author",
            style: TextStyle(color: Theme.of(context).colorScheme.onBackground)),
        trailing:
            Icon(Icons.arrow_forward_ios, color: Theme.of(context).colorScheme.onBackground, size: 16),
        onTap: () {
          log("📖 Navigating to DetailsPage with: ${publication.title} (${publication.id})");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailsPage(
                  publication:
                      publication), // ✅ Ensure it's passing the full object
            ),
          );
        },
      ),
    );
  }
}
