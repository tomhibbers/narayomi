import 'package:flutter/material.dart';
import 'package:narayomi/models/publication.dart';
import 'package:narayomi/widgets/common/publication_card.dart';

/// ✅ Reusable Grid View (3 Columns)
Widget buildGridView(List<Publication> publications) {
  return GridView.builder(
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8), // 🔄 Adjusted padding
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 0.7,
    ),
    itemCount: publications.length,
    itemBuilder: (context, index) {
      return PublicationCard(
        publication: publications[index],
        isGridView: true,
      );
    },
  );
}

/// ✅ Reusable List View (Full width)
Widget buildListView(List<Publication> publications) {
  return ListView.separated(
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8), // 🔄 Adjusted padding
    itemCount: publications.length,

    /// ✅ Adds spacing between list items
    separatorBuilder: (context, index) => SizedBox(height: 12),

    itemBuilder: (context, index) {
      return PublicationCard(
        publication: publications[index],
        isGridView: false,
      );
    },
  );
}