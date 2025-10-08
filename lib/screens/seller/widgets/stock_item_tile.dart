// lib/screens/seller/widgets/stock_item_tile.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/menu_model.dart';
import '../../../providers/menu_provider.dart';
import '../../../theme/app_theme.dart';

class StockItemTile extends ConsumerWidget {
  final MenuItem item;

  const StockItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 1.5,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Item Name and Category
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // ✅ FIXED: Display the list of customCategories, joined by a comma.
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
                    if (item.stock > 0) {
                      ref
                          .read(menuProvider.notifier)
                          .updateStock(item.id, item.stock - 1);
                    }
                  },
                ),
                Container(
                  width: 50,
                  alignment: Alignment.center,
                  child: Text(
                    '${item.stock}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildControlButton(
                  context,
                  icon: Icons.add,
                  onPressed: () {
                    ref
                        .read(menuProvider.notifier)
                        .updateStock(item.id, item.stock + 1);
                  },
                ),
              ],
            )
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
