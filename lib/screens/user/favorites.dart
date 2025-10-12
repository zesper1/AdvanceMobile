import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/food_stall_model.dart';
import '../../providers/food_stall_provider.dart';
import '../../widgets/userwidgets/food_stall_card.dart';
import '../../theme/app_theme.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ 1. Watch the provider ONCE at the top of the build method.
    final favoriteShopsAsync = ref.watch(favoriteShopsProvider);

    return Scaffold(
      // ✅ 2. Use .when() to build the entire body based on the async state.
      // This ensures you only build the complex UI when data is actually ready.
      body: favoriteShopsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text('Failed to load favorites: $err')),
        data: (favoriteShops) {
          // ✅ 3. When data is available, build the full NestedScrollView UI.
          //    The 'favoriteShops' list is now passed directly to where it's needed.
          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                _buildSliverAppBar(context),
              ];
            },
            // ✅ 4. The body is the TabBarView itself, not a Column.
            body: TabBarView(
              controller: _tabController,
              children: [
                // Pass the loaded data directly to the shop section.
                _buildShopSection(favoriteShops),
                // Food Section (Placeholder for now).
                _buildFoodSection(),
              ],
            ),
          );
        },
      ),
    );
  }

  // This widget now includes the TabBar in its 'bottom' property.
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
      title: const Text(
        'My Favorites',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 17,
        ),
      ),
      centerTitle: true,
      expandedHeight: 120.0,
      flexibleSpace: FlexibleSpaceBar(
        background: _buildAppBarBackgroundImage(),
      ),
      backgroundColor: AppTheme.primaryColor.withOpacity(0.95),
      elevation: 4.0,
      // ✅ 5. The AppBar STAYS at the top, and the TabBar sticks to it.
      pinned: true,
      floating: true, // Makes the app bar reappear as soon as you scroll up.
      // ✅ 6. The TabBar is placed here for the correct layout.
      bottom: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(30),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppTheme.subtleTextColor,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w400, fontSize: 12),
        // This container adds padding and decoration AROUND the TabBar.
        indicatorPadding: const EdgeInsets.all(4.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        tabs: const [
          Tab(text: 'Shop Section'),
          Tab(text: 'Food Section'),
        ],
      ),
    );
  }

  // The rest of your builder methods remain unchanged as they were well-designed.
  Widget _buildAppBarBackgroundImage() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset('assets/NU-Dine.png', fit: BoxFit.cover),
        Container(color: Colors.black.withOpacity(0.45)),
      ],
    );
  }

  Widget _buildShopSection(List<FoodStall> favoriteShops) {
    if (favoriteShops.isEmpty) {
      return _buildEmptyState(
        icon: Icons.favorite_border_rounded,
        title: 'No Favorite Shops',
        subtitle: 'Start adding shops by tapping the heart icon on any stall.',
      );
    }
    return Padding(
      // The rest of this widget is unchanged...
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.only(bottom: 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: favoriteShops.length,
              itemBuilder: (context, index) {
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

  // The rest of your methods (_buildFoodSection, _buildEmptyState) are unchanged.
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

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return Center(
      child: SingleChildScrollView(
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
