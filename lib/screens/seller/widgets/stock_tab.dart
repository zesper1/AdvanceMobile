// lib/screens/seller/widgets/stock_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/seller_shop_model.dart';
import '../../../providers/menu_provider.dart';
import 'stock_item_tile.dart';

class StocksTab extends ConsumerStatefulWidget {
  final SellerShop shop;
  const StocksTab({super.key, required this.shop});

  @override
  ConsumerState<StocksTab> createState() => _StocksTabState();
}

class _StocksTabState extends ConsumerState<StocksTab> {
  String selectedCustomCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final menuItems = ref.watch(menuItemsByStallProvider(widget.shop.id));

    if (menuItems.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text('No items to track.', style: TextStyle(fontSize: 16)),
            Text('Add items in the Menu tab to manage stock.',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    // Extract unique custom categories
    final customCategories = <String>{};
    for (final item in menuItems) {
      customCategories.addAll(item.customCategories);
    }
    final filterOptions = ['All', ...customCategories.toList()..sort()];

    // Filter items based on selected custom category
    final filteredItems = selectedCustomCategory == 'All'
        ? menuItems
        : menuItems
            .where((item) =>
                item.customCategories.contains(selectedCustomCategory))
            .toList();

    return Column(
      children: [
        // Top filter bar
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            itemCount: filterOptions.length,
            itemBuilder: (context, index) {
              final option = filterOptions[index];
              final isSelected = option == selectedCustomCategory;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(option),
                  labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87),
                  selected: isSelected,
                  selectedColor: Theme.of(context).primaryColor,
                  backgroundColor: Colors.grey.shade200,
                  onSelected: (_) {
                    setState(() {
                      selectedCustomCategory = option;
                    });
                  },
                ),
              );
            },
          ),
        ),
        // Stock items list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: filteredItems.length,
            itemBuilder: (context, index) {
              final item = filteredItems[index];
              // ✅ FIXED: Pass the 'item' directly without modification.
              return StockItemTile(item: item);
            },
          ),
        ),
      ],
    );
  }
}
