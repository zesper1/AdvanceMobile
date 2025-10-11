// lib/screens/seller/widgets/menu_tab.dart - UPDATED

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panot/models/product_model.dart';
import 'package:panot/models/seller_shop_model.dart';
import 'package:panot/models/menu_model.dart';
import 'package:panot/providers/product_provider.dart';
import 'package:panot/providers/seller_shop_provider.dart';

// ADD IMPORTS for the dialogs
import 'edit_product_dialog.dart';
import 'confirm_delete_dialog.dart';
import 'menu_item_card.dart';

class MenuTab extends ConsumerWidget {
  final SellerShop shop;
  const MenuTab({super.key, required this.shop});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shopId = int.parse(shop.id);
    final subcategoriesAsync = ref.watch(shopSubcategoriesProvider(shopId));
    final productsAsync = ref.watch(productProvider(shopId));

    return productsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error loading menu: $err')),
      data: (products) {
        final subcategories = subcategoriesAsync.value ?? [];
        print(subcategories);
        if (products.isEmpty && subcategories.isEmpty) {
          return const Center(
            child: Text(
              'No products yet.\nTap the + button to add your first one!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          itemCount: subcategories.length,
          itemBuilder: (context, index) {
            final category = subcategories[index];
            final itemsInCategory = products
                .where((p) => p.subcategoryName == category.name)
                .toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                  child: Text(
                    category.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                if (itemsInCategory.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'No items in this category yet.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  ...itemsInCategory.map((product) {
                    final menuItem = MenuItem(
                      id: product.productId.toString(),
                      stallId: product.shopId.toString(),
                      name: product.productName,
                      description: product.description ?? '',
                      price: product.price,
                      imageUrl: product.imageUrl ?? '',
                      category: product.subcategoryName ?? '',
                      stock: product.quantity,
                      isFavorite: false,
                    );

                    // --- CALLBACKS RESTORED HERE ---
                    return MenuItemCard(
                      item: menuItem,
                      showFavorite: false,
                      onEdit: () {
                        // Show the Edit Product Dialog
                        showDialog(
                          context: context,
                          builder: (context) => EditProductDialog(product: product),
                        );
                      },
                      onDelete: () async {
                        // Show the confirmation dialog
                        final didConfirm = await showConfirmDeleteDialog(
                          context: context,
                          itemName: product.productName,
                        );

                        // If user confirmed, call the delete method
                        if (didConfirm == true && context.mounted) {
                          ref.read(productProvider(product.shopId).notifier)
                             .deleteProduct(product.productId, product.imageUrl);
                        }
                      },
                    );
                  }).toList(),
              ],
            );
          },
        );
      },
    );
  }
}