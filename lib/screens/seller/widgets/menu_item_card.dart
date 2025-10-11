// lib/screens/seller/widgets/menu_item_card.dart - UPDATED

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/menu_model.dart';
import '../../../providers/menu_provider.dart';
import '../../../theme/app_theme.dart';

class MenuItemCard extends ConsumerWidget {
  final MenuItem item;
  final bool showFavorite;
  // ADDED: Callbacks for the new edit and delete actions
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const MenuItemCard({
    super.key,
    required this.item,
    this.showFavorite = true, // Default is true for customer view
    this.onEdit,             // Optional callback for editing
    this.onDelete,           // Optional callback for deleting
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      // MODIFIED: Wrapped the main content in a Stack to overlay the buttons
      child: Stack(
        children: [
          // Main content of the card
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    item.imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.fastfood, size: 80, color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 16),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '₱${item.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            'Stock: ${item.stock}',
                            style: TextStyle(
                              fontSize: 13,
                              color: item.stock > 5 ? Colors.green : Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --- CONDITIONAL ACTION BUTTONS ---
          // Shows EITHER the favorite button OR the edit/delete buttons

          // Customer View: Favorite Button
          if (showFavorite)
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                icon: Icon(
                  item.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: item.isFavorite ? Colors.redAccent : Colors.grey,
                ),
                onPressed: () {
                  ref.read(menuProvider.notifier).toggleFavorite(item.id);
                },
              ),
            )
          // Seller View: Edit & Delete Buttons
          else
            Positioned(
              top: 0,
              right: 0,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    iconSize: 20,
                    color: Colors.grey.shade700,
                    tooltip: 'Edit Product',
                    onPressed: onEdit, // Uses the passed-in callback
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    iconSize: 20,
                    color: Colors.red.shade700,
                    tooltip: 'Delete Product',
                    onPressed: onDelete, // Uses the passed-in callback
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}