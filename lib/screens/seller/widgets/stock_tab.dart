// lib/screens/seller/widgets/stock_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/seller_shop_model.dart';
// REMOVE: import '../../../providers/menu_provider.dart';
import '../../../providers/product_provider.dart'; // Import the new provider
import '../../../models/product_model.dart'; // Import the Product model
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
    // 1. WATCH THE ASYNCHRONOUS PRODUCT PROVIDER
    // widget.shop.id is a String, but productProvider expects an int (arg), so we parse it.
    final productsAsync = ref.watch(productProvider(int.parse(widget.shop.id)));

    return productsAsync.when(
      // Loading State
      loading: () => const Center(child: CircularProgressIndicator()),
      
      // Error State
      error: (err, stack) => Center(child: Text('Error loading stock: $err')),
      
      // Data State
      data: (allProducts) {
        // Renamed from menuItems to allProducts

        if (allProducts.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey),
                SizedBox(height: 16),
                Text('No products to track.', style: TextStyle(fontSize: 16)),
                Text('Add products in the Menu tab to manage stock.',
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        // 2. Extract unique custom categories (subcategories)
        final customCategories = <String>{};
        for (final product in allProducts) {
          customCategories.addAll(product.customCategories);
        }
        final filterOptions = ['All', ...customCategories.toList()..sort()];

        // 3. Filter products based on selected custom category
        final filteredProducts = selectedCustomCategory == 'All'
            ? allProducts
            : allProducts
                .where((product) =>
                    product.customCategories.contains(selectedCustomCategory))
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
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  final item = filteredProducts[index];
                  // Pass the product (now named 'item') to the StockItemTile
                  // StockItemTile will need to be updated to accept a 'Product' type
                  return StockItemTile(item: item); 
                },
              ),
            ),
          ],
        );
      },
    );
  }
}