// screens/stall_menu_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/food_stall_model.dart';
import '../../models/menu_model.dart';
// favorites removed from this screen
import '../../providers/menu_provider.dart';
import '../../theme/app_theme.dart';
import '../seller/menu_screen.dart'; // <-- Make sure this import is correct for your project

class StallMenuScreen extends ConsumerStatefulWidget {
  final FoodStall stall;

  const StallMenuScreen({super.key, required this.stall});

  @override
  ConsumerState<StallMenuScreen> createState() => _StallMenuScreenState();
}

class _StallMenuScreenState extends ConsumerState<StallMenuScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _searchController.text = 'Search menu...';
    _isFavorite = widget.stall.isFavorite;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Favorite functionality removed from this screen

  @override
  Widget build(BuildContext context) {
    final menuItems = ref.watch(menuItemsByStallProvider(widget.stall.id));

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // App Bar with custom design
          SliverAppBar(
            backgroundColor: AppTheme.accentColor,
            elevation: 0,
            expandedHeight: 120,
            floating: true,
            pinned: true,
            leading: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppTheme.textColor),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/NU-Dine.png', // Replace with your desired background image asset
                    fit: BoxFit.cover,
                  ),
                  Container(
                    color: AppTheme.accentColor
                        .withOpacity(0.7), // Optional overlay for readability
                  ),
                ],
              ),
            ),
          ),

          // Main Content
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Stall Name
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 24.0, horizontal: 16.0),
                  child: Text(
                    widget.stall.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
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
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        hintText: 'Search menu...',
                        prefixIcon:
                            Icon(Icons.search, color: AppTheme.subtleTextColor),
                      ),
                      onTap: () {
                        if (_searchController.text == 'Search menu...') {
                          setState(() {
                            _searchController.clear();
                          });
                        }
                      },
                      onChanged: (value) {
                        ref
                            .read(menuProvider.notifier)
                            .searchMenuItems(value, widget.stall.id);
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),

          // Menu Items List
          if (menuItems.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text(
                  'No menu items found',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.subtleTextColor,
                    fontSize: 16,
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final menuItem = menuItems[index];
                  return _buildMenuItemCard(menuItem);
                },
                childCount: menuItems.length,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMenuItemCard(MenuItem menuItem) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
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
          // Text Content
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${menuItem.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${menuItem.stock} left in stock',
                  style: TextStyle(
                    fontSize: 12,
                    color: menuItem.stock > 5 ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
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

          // Image
          const SizedBox(width: 12),
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
        ],
      ),
    );
  }
}
