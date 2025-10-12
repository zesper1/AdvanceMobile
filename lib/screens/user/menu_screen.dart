import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panot/providers/seller_shop_provider.dart';

import '../../models/food_stall_model.dart';
import '../../models/product_model.dart';
import '../../providers/food_stall_provider.dart';
import '../../providers/product_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/userwidgets/rate_stall_dialog.dart';
import '../../widgets/userwidgets/user_review_tab.dart';

class StallMenuScreen extends ConsumerStatefulWidget {
  final FoodStall stall;
  final bool showFavoriteButton;

  const StallMenuScreen({
    super.key,
    required this.stall,
    this.showFavoriteButton = true, // Default to true for user-facing screens
  });

  @override
  ConsumerState<StallMenuScreen> createState() => _StallMenuScreenState();
}

class _StallMenuScreenState extends ConsumerState<StallMenuScreen> {
  final TextEditingController _searchController = TextEditingController();

  bool _showReviews = false; // ✅ added toggle for reviews tab

  @override
  void initState() {
    super.initState();
    _searchController.text = 'Search menu...';
    // Initial fetch for the menu items
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productProvider(widget.stall.id).notifier).searchProducts('');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Helper method to show the "Rate Stall" dialog
  void _showRateStallDialog(BuildContext context, FoodStall stall) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return RateStallDialog(stall: stall);
      },
    );
  }

  // Helper method for the "Favorite Added" animation
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
                          child: const Icon(Icons.favorite,
                              color: Colors.redAccent, size: 80),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Successfully Added to Favorites!',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.textColor),
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
    Future.delayed(const Duration(seconds: 2)).then((_) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch reactive providers for live data
    final favoriteIdsAsync = ref.watch(favoriteShopIdsStreamProvider);
    final favoriteIdsSet = favoriteIdsAsync.value?.toSet() ?? <int>{};
    final bool isCurrentlyFavorite = favoriteIdsSet.contains(widget.stall.id);

    // Watch the new groupedProductsProvider, which returns an AsyncValue
    final menuItemsAsync = ref.watch(groupedProductsProvider(widget.stall.id));

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRateStallDialog(context, widget.stall),
        icon: const Icon(Icons.star_outline_rounded),
        label: const Text('Rate Stall'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 4.0,
      ),
      body: _showReviews
          ? UserReviewsTab(stall: widget.stall) // ✅ show reviews tab
          : CustomScrollView(
              slivers: [
                _buildSliverAppBar(context, isCurrentlyFavorite),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 12.0),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2))
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          hintText: 'Search menu...',
                          prefixIcon: Icon(Icons.search,
                              color: AppTheme.subtleTextColor),
                        ),
                        onTap: () {
                          if (_searchController.text == 'Search menu...') {
                            setState(() => _searchController.clear());
                          }
                        },
                        onChanged: (value) {
                          ref
                              .read(productProvider(widget.stall.id).notifier)
                              .searchProducts(value);
                        },
                      ),
                    ),
                  ),
                ),
                // Handle the AsyncValue from the grouped provider
                menuItemsAsync.when(
                  loading: () => const SliverToBoxAdapter(
                    child: Center(
                        child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(
                          color: AppTheme.primaryColor),
                    )),
                  ),
                  error: (err, stack) => SliverToBoxAdapter(
                    child: Center(
                        child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text('Failed to load menu: $err'),
                    )),
                  ),
                  data: (groupedMenuItems) {
                    if (groupedMenuItems.isEmpty) {
                      return const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Center(
                              child: Text('No menu items found',
                                  style: TextStyle(fontSize: 14))),
                        ),
                      );
                    }
                    return SliverMainAxisGroup(
                      slivers: [
                        for (final entry in groupedMenuItems.entries) ...[
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                              child: Text(entry.key,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textColor)),
                            ),
                          ),
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final menuItem = entry.value[index];
                                return _buildMenuItemCard(menuItem);
                              },
                              childCount: entry.value.length,
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, bool isCurrentlyFavorite) {
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
                  offset: const Offset(0, 3))
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back,
                color: AppTheme.primaryColor, size: 24),
            onPressed: () {
              if (_showReviews) {
                setState(() => _showReviews = false); // ✅ go back to menu
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
      ),
      actions: [
        // ⭐ Added review button
        Padding(
          padding: const EdgeInsets.only(right: 8.0, top: 8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3))
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.star_rate_rounded, color: Colors.amber),
              onPressed: () {
                setState(() => _showReviews = true);
              },
            ),
          ),
        ),
        if (widget.showFavoriteButton)
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3))
                ],
              ),
              child: IconButton(
                icon: Icon(
                  isCurrentlyFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isCurrentlyFavorite
                      ? Colors.redAccent
                      : AppTheme.primaryColor,
                ),
                onPressed: () {
                  ref.read(shopServiceProvider).toggleFavoriteStatus(
                      widget.stall.id, isCurrentlyFavorite);
                  if (!isCurrentlyFavorite) {
                    _showFavoriteAddedDialog(context);
                  }
                },
              ),
            ),
          ),
      ],
      title: Text(
        _showReviews
            ? '${widget.stall.name} Reviews'
            : '${widget.stall.name} Menu', // ✅ dynamic title
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
      ),
      centerTitle: true,
      pinned: true,
      expandedHeight: 120.0,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/NU-Dine.png', fit: BoxFit.cover),
            Container(color: Colors.black.withOpacity(0.45)),
          ],
        ),
      ),
      backgroundColor: AppTheme.primaryColor.withOpacity(0.95),
      elevation: 4.0,
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
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(menuItem.productName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppTheme.textColor),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Text('₱${menuItem.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppTheme.primaryColor)),
                const SizedBox(height: 4),
                Text('${menuItem.quantity} left in stock',
                    style: TextStyle(
                        fontSize: 10,
                        color: menuItem.quantity > 5
                            ? Colors.green
                            : Colors.orange,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Text(menuItem.description ?? '',
                    style: const TextStyle(
                        fontSize: 10, color: AppTheme.subtleTextColor),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              menuItem.imageUrl ?? '',
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 80,
                height: 80,
                color: AppTheme.cardColor,
                child: const Center(
                    child:
                        Icon(Icons.fastfood, color: AppTheme.subtleTextColor)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
