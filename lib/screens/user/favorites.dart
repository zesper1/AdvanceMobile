import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/food_stall_model.dart';
import '../../providers/food_stall_provider.dart';
import '../../widgets/stalls/food_stall_card.dart';
import '../../theme/app_theme.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  // State variable for selected section is no longer strictly needed for this UI,
  // but keeping it managed via TabController listener is a good practice if
  // you need to react to tab changes elsewhere.

  @override
  void initState() {
    super.initState();
    // The number of tabs is 2 (Shop Section and Food Section)
    _tabController = TabController(length: 2, vsync: this);
    // You can keep the listener if needed for other logic, but removed the
    // _selectedSection state update since it's not displayed in the new UI.
    // _tabController.addListener(_handleTabSelection);
  }

  // Removed _handleTabSelection as it's no longer used to update UI text.

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the favorite shops provider
    final favoriteShopsAsync = ref.watch(favoriteShopsProvider);

    // Use NestedScrollView for a modern, cohesive UI with a collapsing AppBar
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            _buildSliverAppBar(context),
          ];
        },
        // The body contains the TabBarView, which scrolls under the AppBar
        body: Column(
          children: [
            // Tab Bar
            _buildTabBar(),

            // Dynamic Content
            Expanded(
              child: favoriteShopsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Failed to load favorites: $err')),
                data: (favoriteShops) {
                  // Data is ready: now we pass the synchronous List<FoodStall> 
                  // to _buildContent, which must be updated to accept the list.

                  // NOTE: You need to pass the required TabController here, 
                  // which should be defined and initialized in the parent StatefulWidget.
                  final TabController tabController = DefaultTabController.of(context)!; 
                  
                  return _buildContent(ref, tabController);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // REMADE: Use SliverAppBar for a modern, collapsible header
  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      // The back button is placed here
      leading: Padding(
        padding: const EdgeInsets.only(left: 16.0, top: 8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(
                0.85), // Slightly transparent white for a premium look
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
      // Title of the app bar
      title: const Text(
        'My Favorites',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
      centerTitle: true,
      pinned: true, // Keep the app bar visible when scrolling
      expandedHeight: 120.0, // Reduced height of the fully expanded app bar
      // REMOVED background image from the main Stack and added it here
      flexibleSpace: FlexibleSpaceBar(
        background: _buildAppBarBackgroundImage(),
      ),
      // Set the color to transparent or a subtle color for blend
      backgroundColor:
          AppTheme.primaryColor.withOpacity(0.95), // Solid color when collapsed
      elevation: 4.0,
    );
  }

  // NEW: Widget for the background image in the FlexibleSpaceBar
  Widget _buildAppBarBackgroundImage() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/NU-Dine.png', // Your background image
          fit: BoxFit.cover,
        ),
        // Lower opacity overlay for better text readability
        Container(
          color: Colors.black.withOpacity(0.45), // Increased opacity
        ),
      ],
    );
  }

  // REMADE: TabBar design with gradient removed
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
            color: AppTheme.primaryColor.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        // REMOVED gradient, using solid primary color
        indicator: BoxDecoration(
          color: AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(30),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppTheme.subtleTextColor,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent, // Remove the default divider line
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 12,
        ),
        tabs: const [
          Tab(text: 'Shop Section'),
          Tab(text: 'Food Section'),
        ],
      ),
    );
  }

  // The rest of the content remains mostly the same, ensuring it's aesthetically pleasing.

  // NOTE: Ensure your parent widget passes the required WidgetRef and TabController.
  Widget _buildContent(WidgetRef ref, TabController tabController) {
      // 1. Watch the asynchronous provider for favorite shops
      final favoriteShopsAsync = ref.watch(favoriteShopsProvider);

      return favoriteShopsAsync.when(
          // 1. Loading State: Display a spinner while waiting for data.
          loading: () => const Center(child: CircularProgressIndicator()),

          // 2. Error State: Display the error message.
          error: (err, stack) => Center(child: Text('Error loading favorites: $err')),

          // 3. Data State (success): Data is available as a List<FoodStall>.
          data: (favoriteShops) {
              // Check if the list is empty and display a custom message if so.
              if (favoriteShops.isEmpty) {
                  return const Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                              Icon(Icons.favorite_border, size: 60, color: Colors.grey),
                              SizedBox(height: 16),
                              Text('No favorite shops yet.', style: TextStyle(fontSize: 16)),
                              Text('Tap the ❤️ on a shop to add it here.', style: TextStyle(color: Colors.grey)),
                          ],
                      ),
                  );
              }
              
              // Return the TabBarView with the actual data
              return TabBarView(
                  controller: tabController,
                  children: [
                      // Shop Section: Pass the synchronous List<FoodStall>
                      _buildShopSection(favoriteShops),

                      // Food Section (Placeholder for now)
                      _buildFoodSection(),
                  ],
              );
          },
      );
  }

  Widget _buildShopSection(List<FoodStall> favoriteShops) {
    if (favoriteShops.isEmpty) {
      return _buildEmptyState(
        icon: Icons.favorite_border_rounded,
        title: 'No Favorite Shops',
        subtitle:
            'Start adding your favorite shops by tapping the heart icon on any stall.',
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                Icon(Icons.storefront_rounded,
                    color: AppTheme.primaryColor, size: 16),
                const SizedBox(width: 8),
                Text(
                  '${favoriteShops.length} Favorite Shop${favoriteShops.length > 1 ? 's' : ''}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textColor,
                  ),
                ),
              ],
            ),
          ),

          // Shops Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.only(
                  bottom: 24), // Add padding for the bottom of the grid
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: favoriteShops.length,
              itemBuilder: (context, index) {
                // Assuming FoodStallCard is a well-designed card widget
                return FoodStallCard(
                  stall: favoriteShops[index],
                  cardType: 'vertical',
                  showFavoriteButton: true,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodSection() {
    return _buildEmptyState(
      icon: Icons.restaurant_menu_rounded,
      title: 'Food Favorites Coming Soon',
      subtitle: 'This feature will be available in the next major update!',
      actionText: 'Explore Shops',
      onAction: () {
        _tabController.animateTo(0);
      },
    );
  }

  // Empty state widget is good, kept with minor aesthetic tweaks
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return Center(
      child: SingleChildScrollView(
        // Added to prevent overflow on small screens
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 28,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.subtleTextColor,
                height: 1.4,
              ),
            ),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.storefront_rounded, size: 14),
                label: Text(
                  actionText,
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w500),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                  elevation: 4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
