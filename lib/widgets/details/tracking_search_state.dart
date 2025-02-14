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
  bool _isLoading = false;

  void _performSearch(String query) {
    if (query.isNotEmpty) {
      setState(() {
        _isLoading = true; // Show the spinner
      });

      widget.onSearch(query);

      // Simulate the end of loading after search completion
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Add Tracking Button in a Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Track Publication",
                  style: Theme.of(context).textTheme.headlineSmall),
              if (widget.selectedResultId != null)
                ElevatedButton(
                  onPressed: widget.onTrack,
                  child: Text("Add Tracking",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary)),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Search Bar
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: "Search MangaUpdates...",
              prefixIcon: IconButton(
                icon: Icon(Icons.search),
                onPressed: () => _performSearch(_controller.text),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.primaryContainer,
              contentPadding:
                  EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
            ),
            style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
            onSubmitted: _performSearch,
          ),
          const SizedBox(height: 20),

          // Loading Spinner
          if (_isLoading) Center(child: CircularProgressIndicator()),

          const SizedBox(height: 10),

          // Scrollable Search Results with Constrained Height
          Container(
            height: MediaQuery.of(context).size.height * 0.6,
            child: ListView.builder(
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
                    child: Row(
                      children: [
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
            ),
          ),
        ],
      ),
    );
  }
}
