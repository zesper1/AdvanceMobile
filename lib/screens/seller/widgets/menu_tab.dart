// lib/screens/seller/widgets/menu_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/seller_shop_model.dart';
import '../../../models/menu_model.dart';
import '../../../providers/menu_provider.dart';
import 'menu_item_card.dart';

class MenuTab extends ConsumerWidget {
  final SellerShop shop;
  const MenuTab({super.key, required this.shop});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the provider to get menu items for this specific shop
    final sellerMenuItems = ref.watch(menuItemsByStallProvider(shop.id));

    // Group items by custom categories
    final groupedMenu = <String, List<MenuItem>>{};
    for (final item in sellerMenuItems) {
      if (item.customCategories.isEmpty) {
        groupedMenu.putIfAbsent('Miscellaneous', () => []).add(item);
      } else {
        for (final category in item.customCategories) {
          groupedMenu.putIfAbsent(category, () => []).add(item);
        }
      }
    }

    // Show empty state if no menu items
    if (groupedMenu.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.no_food, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text('No menu items found.', style: TextStyle(fontSize: 16)),
            Text('Add a new item to get started.',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    // Get the category titles to build the list
    final categories = groupedMenu.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final items = groupedMenu[category]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Header
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
              child: Text(
                category,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            // List of menu items in this category
            ...items
                .map(
                  (item) => MenuItemCard(
                    item: item,
                    showFavorite: false, // Hide favorite icon for seller view
                  ),
                )
                .toList(),
          ],
        );
      },
    );
  }
}
