// screens/seller/seller_menu_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/food_stall_model.dart';
import '../../models/menu_model.dart';
import '../../providers/menu_provider.dart';
import '../../theme/app_theme.dart';

class SellerMenuScreen extends ConsumerStatefulWidget {
  final FoodStall stall;

  const SellerMenuScreen({super.key, required this.stall});

  @override
  ConsumerState<SellerMenuScreen> createState() => _SellerMenuScreenState();
}

class _SellerMenuScreenState extends ConsumerState<SellerMenuScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text = 'Search menu...';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showStockManagementDialog(BuildContext context, MenuItem menuItem, WidgetRef ref) {
    int currentStock = menuItem.stock;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Manage Stock'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    menuItem.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Minus Button
                      CircleAvatar(
                        backgroundColor: AppTheme.primaryColor,
                        child: IconButton(
                          icon: const Icon(Icons.remove, color: Colors.white),
                          onPressed: () {
                            if (currentStock > 0) {
                              setDialogState(() {
                                currentStock--;
                              });
                            }
                          },
                        ),
                      ),
                      // Current Stock Display
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.cardColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$currentStock',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textColor,
                          ),
                        ),
                      ),
                      // Plus Button
                      CircleAvatar(
                        backgroundColor: AppTheme.primaryColor,
                        child: IconButton(
                          icon: const Icon(Icons.add, color: Colors.white),
                          onPressed: () {
                            setDialogState(() {
                              currentStock++;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Items in stock',
                    style: TextStyle(
                      color: AppTheme.subtleTextColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    ref.read(menuProvider.notifier).updateStock(menuItem.id, currentStock);
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Stock updated to $currentStock'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final menuItems = ref.watch(menuItemsByStallProvider(widget.stall.id));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.accentColor,
        title: Text(
          '${widget.stall.name} - Menu Management',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  hintText: 'Search menu...',
                  prefixIcon: Icon(Icons.search, color: AppTheme.subtleTextColor),
                ),
                onTap: () {
                  if (_searchController.text == 'Search menu...') {
                    setState(() {
                      _searchController.clear();
                    });
                  }
                },
                onChanged: (value) {
                  ref.read(menuProvider.notifier).searchMenuItems(value, widget.stall.id);
                },
              ),
            ),
          ),
          Expanded(
            child: menuItems.isEmpty
                ? const Center(
                    child: Text(
                      'No menu items found',
                      style: TextStyle(
                        color: AppTheme.subtleTextColor,
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: menuItems.length,
                    itemBuilder: (context, index) {
                      final menuItem = menuItems[index];
                      return _buildMenuItemCard(menuItem, ref);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItemCard(MenuItem menuItem, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              menuItem.imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 80,
                height: 80,
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
                    color: AppTheme.textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${menuItem.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: menuItem.stock > 5 ? Colors.green : Colors.orange,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${menuItem.stock} in stock',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  menuItem.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.subtleTextColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Manage Stock Button
          IconButton(
            icon: const Icon(Icons.inventory_2, color: AppTheme.primaryColor),
            onPressed: () => _showStockManagementDialog(context, menuItem, ref),
            tooltip: 'Manage Stock',
          ),
        ],
      ),
    );
  }
}