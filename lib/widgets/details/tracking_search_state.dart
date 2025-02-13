import 'package:flutter/material.dart';

class TrackingSearchState extends StatefulWidget {
  final List<Map<String, String>> searchResults;
  final String? selectedResultId;
  final Function(String) onSelectResult;
  final Function(String) onSearch;
  final VoidCallback onTrack;

  const TrackingSearchState({
    required this.searchResults,
    required this.selectedResultId,
    required this.onSelectResult,
    required this.onSearch,
    required this.onTrack,
  });

  @override
  _TrackingSearchState createState() => _TrackingSearchState();
}

class _TrackingSearchState extends State<TrackingSearchState> {
  final TextEditingController _controller = TextEditingController();

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
          controller: _controller,
          decoration: InputDecoration(
            labelText: "Search MangaUpdates",
            suffixIcon: IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  widget.onSearch(_controller.text);
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 20),
        _buildSearchResults(),
        const SizedBox(height: 20),
        if (widget.selectedResultId != null)
          ElevatedButton(
            onPressed: widget.onTrack,
            child: Text("Add Tracking"),
          ),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (widget.searchResults.isEmpty) {
      return Text("No results found. Try searching for something.");
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: widget.searchResults.length,
      itemBuilder: (context, index) {
        final result = widget.searchResults[index];
        final isSelected = result['id'] == widget.selectedResultId;

        return GestureDetector(
          onTap: () => widget.onSelectResult(result['id']!),
          child: Container(
            padding: EdgeInsets.all(8),
            margin: EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                  : Colors.transparent,
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.secondary
                    : Colors.transparent,
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                // Cover Art on the left
                Container(
                  width: 80,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    image: DecorationImage(
                      image: NetworkImage(result['imageUrl'] ?? ''),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Title and Description on the right
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result['title'] ?? "",
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        result['summary'] ?? "No description available",
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 6,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
