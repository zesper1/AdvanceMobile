import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showSearch;
  final bool showFilter;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onFilterPressed;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showSearch = false,
    this.showFilter = false,
    this.onSearchChanged,
    this.onFilterPressed,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title),
                if (showSearch) _buildSearchBar(context),
              ],
            ),
          ),
          _buildLogo(),
        ],
      ),
      actions: [
        if (showFilter)
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: onFilterPressed,
          ),
        ...?actions,
      ],
      bottom: showSearch ? null : _buildFilterOptions(),
    );
  }

  Widget _buildLogo() {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Image.asset(
        'assets/NU-Dine.png', // Your logo path
        height: 40,
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: TextField(
        onChanged: onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search...',
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          prefixIcon: const Icon(Icons.search, size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Theme.of(context).inputDecorationTheme.fillColor,
        ),
      ),
    );
  }

  PreferredSizeWidget? _buildFilterOptions() {
    if (!showFilter) return null;

    return PreferredSize(
      preferredSize: const Size.fromHeight(48),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            FilterChip(
              label: const Text('Popular'),
              onSelected: (bool value) {},
            ),
            const SizedBox(width: 8),
            FilterChip(
              label: const Text('Nearby'),
              onSelected: (bool value) {},
            ),
            const SizedBox(width: 8),
            FilterChip(
              label: const Text('Open Now'),
              onSelected: (bool value) {},
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize {
    if (showSearch && showFilter) {
      return const Size.fromHeight(128);
    } else if (showSearch || showFilter) {
      return const Size.fromHeight(96);
    }
    return const Size.fromHeight(kToolbarHeight);
  }
}
