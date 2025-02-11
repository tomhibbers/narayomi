import 'package:flutter/material.dart';

class TrackingSearchState extends StatelessWidget {
  final List<Map<String, String>> searchResults;
  final String? selectedResultId;
  final Function(String) onSelectResult;
  final VoidCallback onSearch;
  final VoidCallback onTrack;

  const TrackingSearchState({
    required this.searchResults,
    required this.selectedResultId,
    required this.onSelectResult,
    required this.onSearch,
    required this.onTrack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("Track Publication",
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 10),
        TextField(
          decoration: InputDecoration(
            labelText: "Search MangaUpdates",
            suffixIcon: IconButton(
              icon: Icon(Icons.search),
              onPressed: onSearch,
            ),
          ),
        ),
        const SizedBox(height: 20),
        searchResults.isEmpty
            ? Text("No results found. Try searching for something.")
            : ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final result = searchResults[index];
                  final isSelected = result['id'] == selectedResultId;

                  return GestureDetector(
                    onTap: () => onSelectResult(result['id']!),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                      margin: EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1)
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.secondary
                              : Colors.transparent,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(result['title'] ?? "",
                              style: Theme.of(context).textTheme.bodyLarge),
                          const SizedBox(height: 4),
                          Text(result['summary'] ?? "No description available",
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                  );
                },
              ),
        const SizedBox(height: 20),
        if (selectedResultId != null)
          ElevatedButton(
            onPressed: onTrack,
            child: Text("Track"),
          ),
      ],
    );
  }
}
