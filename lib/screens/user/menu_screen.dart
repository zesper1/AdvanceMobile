// screens/stall_menu_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/food_stall_model.dart';
import '../../models/menu_model.dart';
import '../../providers/menu_provider.dart';
import '../../theme/app_theme.dart';

class StallMenuScreen extends ConsumerStatefulWidget {
  final FoodStall stall;
  const StallMenuScreen({super.key, required this.stall});
  @override
  ConsumerState<StallMenuScreen> createState() => _StallMenuScreenState();
}

class _StallMenuScreenState extends ConsumerState<StallMenuScreen> {
  // SliverAppBar for the menu screen
  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      leading: Padding(
        padding: const EdgeInsets.only(left: 16.0, top: 8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back,
                color: AppTheme.primaryColor, size: 24),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      title: Text(
        '${widget.stall.name} menu',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
      centerTitle: true,
      pinned: true,
      expandedHeight: 120.0,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/NU-Dine.png',
              fit: BoxFit.cover,
            ),
            Container(
              color: Colors.black.withOpacity(0.45),
            ),
          ],
        ),
      ),
      backgroundColor: AppTheme.primaryColor.withOpacity(0.95),
      elevation: 4.0,
    );
  }

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(menuProvider.notifier).searchMenuItems('', widget.stall.id);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // NEW: Helper method for showing the favorite dialog
  void _showFavoriteAddedDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      pageBuilder: (ctx, a1, a2) => Container(),
      transitionBuilder: (ctx, a1, a2, child) {
        return FadeTransition(
          opacity: a1,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(a1),
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
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
      transitionDuration: const Duration(milliseconds: 300),
    );

    // Auto-dismiss the dialog after a short duration
    Future.delayed(const Duration(seconds: 2)).then((_) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final groupedMenuItems =
        ref.watch(groupedMenuItemsProvider(widget.stall.id));

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
              // ... same as before
              ),
          if (groupedMenuItems.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text(
                  'No menu items found',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
              ),
            )
          else
            SliverMainAxisGroup(
              slivers: [
                for (final entry in groupedMenuItems.entries) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        entry.key,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textColor,
                        ),
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final menuItem = entry.value[index];
                        // Pass ref to the build method
                        return _buildMenuItemCard(menuItem, ref);
                      },
                      childCount: entry.value.length,
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }

  // MODIFIED: _buildMenuItemCard now accepts WidgetRef
  Widget _buildMenuItemCard(MenuItem menuItem, WidgetRef ref) {
    // Use a Stack to overlay the favorite button on top of the card
    return Stack(
      children: [
        Container(
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Add some padding to avoid text overlapping with the heart icon
                    Padding(
                      padding: const EdgeInsets.only(right: 30.0),
                      child: Text(
                        menuItem.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppTheme.textColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₱${menuItem.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${menuItem.stock} left in stock',
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            menuItem.stock > 5 ? Colors.green : Colors.orange,
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
                    if (menuItem.customCategories.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: menuItem.customCategories.map((category) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 75, 69, 40)
                                  .withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              category,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppTheme.textColor,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
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
                      child:
                          Icon(Icons.fastfood, color: AppTheme.subtleTextColor),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // NEW: Positioned Favorite Button
        Positioned(
          top: 12,
          right: 20,
          child: IconButton(
            icon: Icon(
              menuItem.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: menuItem.isFavorite
                  ? Colors.redAccent
                  : Colors.grey.withOpacity(0.7),
            ),
            onPressed: () {
              // Get the state *before* toggling it
              final bool isCurrentlyFavorite = menuItem.isFavorite;
              // Call the notifier to update the state
              ref.read(menuProvider.notifier).toggleFavorite(menuItem.id);
              // Only show the dialog if the item was *not* favorite before the tap
              if (!isCurrentlyFavorite) {
                _showFavoriteAddedDialog(context);
              }
            },
          ),
        ),
      ],
    );
  }
}
