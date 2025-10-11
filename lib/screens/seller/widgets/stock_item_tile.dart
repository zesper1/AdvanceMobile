// lib/screens/seller/widgets/stock_item_tile.dart - REFACTORED FOR DEFERRED SAVE

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/product_model.dart';
import '../../../providers/product_provider.dart'; // Contains productProvider and temporaryStockProvider
import '../../../theme/app_theme.dart';

class StockItemTile extends ConsumerWidget {
  final Product item;

  const StockItemTile({super.key, required this.item});

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Helper to trigger the update and reset the local state
  Future<void> _saveStockChanges(BuildContext context, WidgetRef ref) async {
    final newQuantity = ref.read(temporaryStockProvider(item.productId));
    final productNotifier = ref.read(productProvider(item.shopId).notifier);
    
    // Only save if the value has actually changed from the original
    if (newQuantity == item.quantity) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No changes to save.'),
          backgroundColor: Colors.blueGrey,
        ),
      );
      return;
    }

    try {
      // 1. Show loading indicator/disable button temporarily if possible
      
      // 2. Call the asynchronous DB update
      await productNotifier.updateQuantity(
        productId: item.productId,
        newQuantity: newQuantity,
      );

      // 3. Show success
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.productName} stock updated to $newQuantity!'),
            backgroundColor: Colors.green,
          ),
        );
      }
      
      // 4. IMPORTANT: Reset the temporary state to match the new saved value
      // The overall productProvider will refetch/update, but we reset the temp state here
      ref.read(temporaryStockProvider(item.productId).notifier).state = newQuantity;

    } catch (e) {
      _showError(context, 'Failed to save stock: ${e.toString()}');
      // On error, reset the temporary state back to the official item.quantity
      ref.read(temporaryStockProvider(item.productId).notifier).state = item.quantity;
    }
  }


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Get/Initialize the temporary stock state
    final stockState = ref.watch(temporaryStockProvider(item.productId));
    
    // If the temporary state is 0 (uninitialized), set it to the actual product quantity
    if (stockState == 0 && item.quantity > 0) {
        // We use read here because we don't want to rebuild when we set it for the first time
        WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(temporaryStockProvider(item.productId).notifier).state = item.quantity;
        });
    }

    // Use the temporary state for display, defaulting to item.quantity
    final currentQuantity = ref.watch(temporaryStockProvider(item.productId)) == 0 ? item.quantity : stockState;
    final hasChanges = currentQuantity != item.quantity;
    
    final stockNotifier = ref.read(temporaryStockProvider(item.productId).notifier);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: hasChanges ? 3 : 1.5, // Highlight item with unsaved changes
      shadowColor: hasChanges ? AppTheme.primaryColor.withOpacity(0.3) : Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            Row(
              children: [
                // Item Name and Category
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      if (item.customCategories.isNotEmpty)
                        Text(
                          item.customCategories.join(', '),
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                    ],
                  ),
                ),
                // Stock Controls
                Row(
                  children: [
                    _buildControlButton(
                      context,
                      icon: Icons.remove,
                      onPressed: () {
                        if (currentQuantity > 0) {
                          stockNotifier.state = currentQuantity - 1;
                        }
                      },
                    ),
                    Container(
                      width: 50,
                      alignment: Alignment.center,
                      child: Text(
                        '$currentQuantity', 
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: hasChanges ? AppTheme.primaryColor : Colors.black,
                        ),
                      ),
                    ),
                    _buildControlButton(
                      context,
                      icon: Icons.add,
                      onPressed: () {
                        stockNotifier.state = currentQuantity + 1;
                      },
                    ),
                  ],
                ),
              ],
            ),
            
            // SAVE BUTTON (Only visible when changes exist)
            if (hasChanges)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    icon: const Icon(Icons.save, size: 18),
                    label: const Text('Save Changes'),
                    onPressed: () => _saveStockChanges(context, ref),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton(BuildContext context,
      {required IconData icon, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: AppTheme.primaryColor),
      ),
    );
  }
}