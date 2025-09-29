import 'package:flutter/material.dart';

class SearchFilterBar extends StatelessWidget {
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onFilterPressed;
  final bool showFilterOptions;
  final ValueChanged<String>? onSortSelected;

  const SearchFilterBar({
    super.key,
    this.onSearchChanged,
    this.onFilterPressed,
    this.showFilterOptions = false,
    this.onSortSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),
              if (onFilterPressed != null)
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: onFilterPressed,
                ),
            ],
          ),
        ),
        if (showFilterOptions) _buildFilterOptions(),
      ],
    );
  }

  Widget _buildFilterOptions() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          FilterChip(
            label: const Text('Popular'),
            onSelected: (bool value) {
              onSortSelected?.call('popular');
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Nearby'),
            onSelected: (bool value) {
              onSortSelected?.call('nearby');
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Open Now'),
            onSelected: (bool value) {
              onSortSelected?.call('open');
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Rating'),
            onSelected: (bool value) {
              onSortSelected?.call('rating');
            },
          ),
        ],
      ),
    );
  }
}
