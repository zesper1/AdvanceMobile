import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/food_stall_model.dart';
import '../../models/product_model.dart';
import '../../providers/food_stall_provider.dart';
import '../../providers/product_provider.dart';
import '../../theme/app_theme.dart';

class StallMenuScreen extends ConsumerStatefulWidget {
  final FoodStall stall;
  // 1. ADD NULLABLE FLAG: Defaults to true (show the button)
  final bool? showFavoriteButton; 

  const StallMenuScreen({
    super.key, 
    required this.stall,
    this.showFavoriteButton = false, // Default to true (buyer mode)
  });

  @override
  ConsumerState<StallMenuScreen> createState() => _StallMenuScreenState();
}

class _StallMenuScreenState extends ConsumerState<StallMenuScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  // We no longer need to manage _isFavorite via StatefulWidget state 
  // if we watch the provider, but for now we keep it to minimize changes.
  // The 'isFavorite' state should eventually be watched using a Provider.family
  bool _isFavorite = false; 

  @override
  void initState() {
    super.initState();
    _searchController.text = 'Search menu...';
    // Initialize based on the stall model's current status
    _isFavorite = widget.stall.isFavorite; 
  }
  
  Future<void> _showFavoriteSuccessDialog(BuildContext context, WidgetRef ref) async {
    final isCurrentlyFavorite = _isFavorite;

    // Toggle favorite status using the updated Notifier method
    // Note: The toggleFavorite method handles the DB update and local state refresh
    await ref.read(foodStallProvider.notifier).toggleFavorite(widget.stall.id);
    
    // Update local state and trigger rebuild for the icon change
    setState(() {
      _isFavorite = !_isFavorite;
    });

    // ... (Your showGeneralDialog implementation remains the same) ...
    if (!isCurrentlyFavorite) {
      showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: 'Dismiss',
        pageBuilder: (ctx, a1, a2) => Container(),
        transitionBuilder: (context, a1, a2, child) {
          return FadeTransition(
            opacity: a1,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.8, end: 1.0).animate(a1),
              child: AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
                content: SizedBox(
                  width: 320,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.elasticOut,
                        builder: (context, scale, child) {
                          return Transform.scale(
                            scale: scale,
                            child: const Icon(
                              Icons.favorite,
                              color: Colors.redAccent,
                              size: 80,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Successfully Added to Favorites!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.textColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      );

      await Future.delayed(const Duration(milliseconds: 800));
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final menuItemsAsync = ref.watch(productProvider(widget.stall.id));
    // Check the new flag for conditional rendering
    final shouldShowFavorite = widget.showFavoriteButton ?? false; 

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
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
            actions: [
              // CONDITIONAL RENDERING: Only show the button if the flag is true
              if (shouldShowFavorite)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite ? Colors.redAccent : AppTheme.textColor,
                      ),
                      onPressed: () => _showFavoriteSuccessDialog(context, ref),
                    ),
                  ),
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Assuming 'assets/NU-Dine.png' is your background asset
                  Image.asset(
                    'assets/NU-Dine.png', 
                    fit: BoxFit.cover,
                  ),
                  Container(
                    color: AppTheme.accentColor.withOpacity(0.7), // Optional overlay
                  ),
                ],
              ),
            ),
          ),
          // Main Content (unchanged)
          SliverToBoxAdapter(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                        ref.read(productProvider(widget.stall.id).notifier).searchProducts(value);
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                    Text(widget.stall.name,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.subtleTextColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          // Menu List (unchanged)
          menuItemsAsync.when(
            loading: () => const SliverToBoxAdapter(
              child: Center(child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              )),
            ),
            error: (err, stack) => SliverToBoxAdapter(
              child: Center(child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text('Failed to load menu: $err'),
              )),
            ),
            data: (menuItems) {
              if (menuItems.isEmpty) {
                return const SliverToBoxAdapter(
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
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final menuItem = menuItems[index];
                    return _buildMenuItemCard(menuItem);
                  },
                  childCount: menuItems.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  Widget _buildMenuItemCard(Product menuItem) {
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
                  menuItem.productName, // Use 'productName'
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
                  '${menuItem.quantity} left in stock', // Use 'quantity'
                  style: TextStyle(
                    fontSize: 12,
                    color: menuItem.quantity > 5 ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  menuItem.description ?? '', // Description is nullable
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
              menuItem.imageUrl ?? '', // ImageUrl is nullable
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