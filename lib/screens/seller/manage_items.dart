// screens/seller/manage_store_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/food_stall_model.dart';
import '../../models/menu_model.dart';
import '../../providers/menu_provider.dart';
import '../../theme/app_theme.dart';

class ManageStoreScreen extends ConsumerStatefulWidget {
  final FoodStall stall;

  const ManageStoreScreen({super.key, required this.stall});

  @override
  ConsumerState<ManageStoreScreen> createState() => _ManageStoreScreenState();
}

class _ManageStoreScreenState extends ConsumerState<ManageStoreScreen> {
  @override
  Widget build(BuildContext context) {
    final menuItems = ref.watch(menuItemsByStallProvider(widget.stall.id.toString()));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.accentColor,
        title: const Text(
          'Manage Store',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddEditMenuItemDialog(context, null),
            tooltip: 'Add New Item',
          ),
        ],
      ),
      body: menuItems.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restaurant_menu, size: 64, color: AppTheme.subtleTextColor),
                  SizedBox(height: 16),
                  Text(
                    'No menu items yet',
                    style: TextStyle(
                      color: AppTheme.subtleTextColor,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap the + button to add your first item',
                    style: TextStyle(
                      color: AppTheme.subtleTextColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final menuItem = menuItems[index];
                return _buildMenuItemCard(menuItem, ref);
              },
            ),
    );
  }

  Widget _buildMenuItemCard(MenuItem menuItem, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                menuItem.imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 60,
                  height: 60,
                  color: AppTheme.cardColor,
                  child: const Center(
                    child: Icon(Icons.fastfood, color: AppTheme.subtleTextColor),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    menuItem.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${menuItem.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    menuItem.category!,
                    style: const TextStyle(
                      color: AppTheme.subtleTextColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Edit and Delete Buttons
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: AppTheme.primaryColor),
                  onPressed: () => _showAddEditMenuItemDialog(context, menuItem),
                  tooltip: 'Edit Item',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteConfirmationDialog(context, menuItem, ref),
                  tooltip: 'Delete Item',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddEditMenuItemDialog(BuildContext context, MenuItem? existingItem) {
    final nameController = TextEditingController(text: existingItem?.name ?? '');
    final descriptionController = TextEditingController(text: existingItem?.description ?? '');
    final priceController = TextEditingController(text: existingItem?.price.toString() ?? '');
    final imageUrlController = TextEditingController(text: existingItem?.imageUrl ?? '');
    final categoryController = TextEditingController(text: existingItem?.category ?? '');
    final stockController = TextEditingController(text: existingItem?.stock.toString() ?? '0');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(existingItem == null ? 'Add Menu Item' : 'Edit Menu Item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Item Name'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 2,
                ),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                TextField(
                  controller: stockController,
                  decoration: const InputDecoration(labelText: 'Stock'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: imageUrlController,
                  decoration: const InputDecoration(labelText: 'Image URL'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newItem = MenuItem(
                  id: existingItem?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  description: descriptionController.text,
                  price: double.tryParse(priceController.text) ?? 0.0,
                  imageUrl: imageUrlController.text,
                  stock: int.tryParse(stockController.text) ?? 0,
                  category: categoryController.text,
                  stallId: widget.stall.id.toString(),
                );

                if (existingItem == null) {
                  ref.read(menuProvider.notifier).addMenuItem(newItem);
                } else {
                  ref.read(menuProvider.notifier).updateMenuItem(existingItem.id, newItem);
                }

                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(existingItem == null ? 'Item added successfully!' : 'Item updated successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Text(existingItem == null ? 'Add' : 'Update'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, MenuItem menuItem, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Item'),
          content: Text('Are you sure you want to delete "${menuItem.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                ref.read(menuProvider.notifier).deleteMenuItem(menuItem.id);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Item deleted successfully'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}