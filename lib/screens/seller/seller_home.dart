// screens/seller/seller_home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/seller_shop_provider.dart';
import '../../providers/food_stall_provider.dart';
import '../../services/shop_services.dart'; // ✅ For deleteShop()

import '../../widgets/stalls/food_stall_card.dart';
import '../../theme/app_theme.dart';
import 'create_shop.dart';
import 'seller_account.dart';
import 'seller_shop_management_screen.dart';
import '../../models/seller_shop_model.dart';
import '../../models/food_stall_model.dart';
import '../../providers/auth_provider.dart';

class SellerHomeScreen extends ConsumerStatefulWidget {
  final String sellerId;
  final String sellerName; // Add seller name parameter

  const SellerHomeScreen({
    super.key,
    required this.sellerId,
    this.sellerName = 'Seller', // Default name
  });

  @override
  ConsumerState<SellerHomeScreen> createState() => _SellerHomeScreenState();
}

class _SellerHomeScreenState extends ConsumerState<SellerHomeScreen> {
  String _selectedCategory = 'All';
  String _selectedStatus = 'All'; // 'All', 'Open', 'Closed'
  int _currentIndex = 0;
  // int _currentTabIndex = 0; // previously unused: 0: My Shops, 1: Pending, 2: All Shops
  // NEW STATE: Control the visibility of the welcome banner
  bool _showWelcomeBanner = true;

  @override
  void dispose() {
    super.dispose();
  }

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentIndex == 0 ? _buildAppBar() : null,
      body: _buildCurrentScreen(),
      floatingActionButton:
          _currentIndex == 0 ? _buildFloatingActionButton() : null,
    );
  }

  // Simplified AppBar without the search bar
  PreferredSizeWidget _buildAppBar() {
    final auth = ref.read(authNotifierProvider.notifier); // Access AuthNotifier

    return AppBar(
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/NU-D.jpg'), // Background image
            fit: BoxFit.cover,
          ),
        ),
      ),
      elevation: 0,
      centerTitle: true,
      title: const Text(
        'My Business',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 20,
          shadows: [
            Shadow(
              blurRadius: 4.0,
              color: Colors.black54,
              offset: Offset(2.0, 2.0),
            ),
          ],
        ),
      ),
      actions: [
        // 👤 Profile Icon (moved to previous notification spot)
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      SellerAccountScreen(sellerId: widget.sellerId),
                ),
              );
            },
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.person,
                color: Colors.black87,
              ),
            ),
          ),
        ),

        // 🚪 Logout Icon (added at the rightmost side)
        // 🚪 Logout Icon (Improved confirmation dialog)
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: GestureDetector(
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                barrierDismissible:
                    true, // Allow dismissing by tapping outside the dialog
                builder: (context) => Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 6,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.logout,
                            color: Colors.redAccent,
                            size: 36,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Are you sure you want to log out?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Cancel Button
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context, false),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.grey),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Logout Button
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Logout',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );

              if (confirm == true) {
                await ref.read(authNotifierProvider.notifier).signOut();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                }
              }
            },
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.logout,
                color: Colors.redAccent,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return _buildShopsScreen();
      case 1:
        // Assuming this is supposed to be the account screen as per the original structure
        return SellerAccountScreen(sellerId: widget.sellerId);
      default:
        return _buildShopsScreen();
    }
  }

  Widget _buildShopsScreen() {
    final shopsAsyncValue = ref.watch(sellerShopProvider);

    return shopsAsyncValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          Center(child: Text('Failed to load shops: $error')),
      data: (allMyShops) {
        final approvedShops =
            allMyShops.where((s) => s.status == ShopStatus.Approved).toList();
        final pendingShops =
            allMyShops.where((s) => s.status == ShopStatus.Pending).toList();

        // This provider is for the "All Shops" tab for customer view, keep it separate if needed.
        final allShopsForCustomerView = ref.watch(foodStallProvider);

        return Column(
          children: [
            _buildWelcomeSection(approvedShops.length, pendingShops.length),
            Expanded(
              child: DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    Container(
                      // Your TabBar styling
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TabBar(
                        labelColor: AppTheme.primaryColor,
                        unselectedLabelColor: AppTheme.subtleTextColor,
                        indicatorColor: AppTheme.primaryColor,
                        // ... other TabBar properties
                        tabs: const [
                          Tab(text: 'My Shops'),
                          Tab(text: 'Pending'),
                          Tab(text: 'All Shops'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildMyShopsTab(approvedShops),
                          _buildPendingTab(pendingShops),
                          _buildAllShopsTab(allShopsForCustomerView),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // MODIFIED: Welcome Section with added Dismiss/Close button
  Widget _buildWelcomeSection(int approvedCount, int pendingCount) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withOpacity(0.9),
            const Color(0xFF1976D2).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${widget.sellerName}! 👋',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage your business efficiently',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),
              // NEW: Dismiss Button
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showWelcomeBanner = false;
                  });
                  // Optionally, you can also save this preference locally
                  // so the banner stays hidden on subsequent app opens.
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildWelcomeStatItem(
                count: approvedCount,
                label: 'Owned',
                icon: Icons.check_circle,
                color: Colors.greenAccent,
              ),
              _buildWelcomeStatItem(
                count: pendingCount,
                label: 'Pending',
                icon: Icons.pending,
                color: Colors.orangeAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ... (Keep the rest of your original widgets: _buildWelcomeStatItem,
  // _buildMyShopsTab, _buildPendingTab, _buildAllShopsTab,
  // _buildEnhancedFilterSection, _buildStatusToggle, _buildSellerShopCard,
  // _buildPendingShopCard, _buildEmptyState, _buildFloatingActionButton)

  // Note: I am only including the modified or new parts in the full code block.
  // In a real file, you would keep all the other methods as they were.

  Widget _buildWelcomeStatItem({
    required int count,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.18),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(height: 6),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMyShopsTab(List<SellerShop> myShops) {
    if (myShops.isEmpty) {
      return _buildEmptyState(
        icon: Icons.store,
        title: 'No owned shops yet',
        subtitle: 'Create a new shop or wait for approval',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: myShops.length,
      itemBuilder: (context, index) {
        final shop = myShops[index];
        return _buildSellerShopCard(shop);
      },
    );
  }

  Widget _buildPendingTab(List<SellerShop> pendingShops) {
    if (pendingShops.isEmpty) {
      return _buildEmptyState(
        icon: Icons.pending_actions,
        title: 'No pending requests',
        subtitle: 'Your shop approval requests will appear here',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pendingShops.length,
      itemBuilder: (context, index) {
        final shop = pendingShops[index];
        return _buildPendingShopCard(shop);
      },
    );
  }

  Widget _buildAllShopsTab(List<FoodStall> allShops) {
    // Apply category and status filters
    List<FoodStall> filteredShops = allShops;

    // Apply category filter
    if (_selectedCategory != 'All') {
      filteredShops = filteredShops
          .where((shop) => shop.category == _selectedCategory)
          .toList();
    }

    // Apply status filter
    if (_selectedStatus != 'All') {
      filteredShops = filteredShops.where((shop) {
        // NOTE: The original code assumes shop has an 'availability' property
        // that matches the AvailabilityStatus enum.
        if (_selectedStatus == 'Open') {
          return shop.availability == AvailabilityStatus.Open;
        } else if (_selectedStatus == 'Closed') {
          return shop.availability == AvailabilityStatus.Closed ||
              shop.availability == AvailabilityStatus.OnBreak;
        }
        return true;
      }).toList();
    }

    return Column(
      children: [
        // Enhanced Filter Section
        _buildEnhancedFilterSection(allShops),
        Expanded(
          child: filteredShops.isEmpty
              ? _buildEmptyState(
                  icon: Icons.search_off,
                  title: 'No shops found',
                  subtitle: 'Try changing your filter criteria',
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredShops.length,
                  itemBuilder: (context, index) {
                    final shop = filteredShops[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: FoodStallCard(
                        stall: shop,
                        cardType: 'horizontal',
                        showFavoriteButton:
                            false, // 👈 Hide favorite icon for sellers
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEnhancedFilterSection(List<FoodStall> allShops) {
    final categories = allShops.map((stall) => stall.category).toSet().toList();
    categories.insert(0, 'All');

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardColor.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filters',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.textColor,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Category Filter
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Category',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.subtleTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        isExpanded: true,
                        underline: const SizedBox(),
                        icon: const Icon(Icons.arrow_drop_down,
                            color: AppTheme.textColor, size: 20),
                        style: const TextStyle(
                            fontSize: 14, color: AppTheme.textColor),
                        items: categories.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCategory = newValue!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Status Filter
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.subtleTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child:
                                _buildStatusToggle('All', Icons.all_inclusive),
                          ),
                          Expanded(
                            child:
                                _buildStatusToggle('Open', Icons.check_circle),
                          ),
                          Expanded(
                            child: _buildStatusToggle('Closed', Icons.cancel),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusToggle(String status, IconData icon) {
    bool isSelected = _selectedStatus == status;
    Color selectedColor = status == 'Open'
        ? Colors.green
        : status == 'Closed'
            ? Colors.red
            : AppTheme.primaryColor;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatus = status;
        });
      },
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color:
              isSelected ? selectedColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? selectedColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? selectedColor : AppTheme.subtleTextColor,
            ),
            const SizedBox(height: 2),
            Text(
              status,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isSelected ? selectedColor : AppTheme.subtleTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

// ✅ Shop deletion confirmation function
  void confirmAndDeleteShop(BuildContext context, String shopId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text(
              'Are you sure you want to permanently delete this shop and all its subcategories? This cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                try {
                  final shopService =
                      ShopService(); // Make sure this import exists
                  await shopService.deleteShop(shopId);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Shop successfully deleted!')),
                  );

                  // 🔄 Refresh shop list after deletion
                  ref.invalidate(sellerShopProvider);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Deletion failed: ${e.toString()}')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSellerShopCard(SellerShop shop) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            shop.imageUrl!,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 50,
              height: 50,
              color: AppTheme.cardColor,
              child: const Icon(Icons.store, color: AppTheme.subtleTextColor),
            ),
          ),
        ),
        title: Text(
          shop.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(shop.category,
                style: const TextStyle(color: AppTheme.subtleTextColor)),
            Text('${shop.openingTime} - ${shop.closingTime}',
                style: const TextStyle(
                    color: AppTheme.subtleTextColor, fontSize: 12)),

            const SizedBox(height: 6),

            // ⚙️ Manage + 🗑 Delete Buttons Row
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SellerShopManagementScreen(shop: shop),
                        ),
                      );
                    },
                    icon: const Icon(Icons.settings, size: 16),
                    label: const Text(
                      'Manage',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      side: BorderSide(
                          color: AppTheme.primaryColor.withOpacity(0.5)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // ✅ Delete button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => confirmAndDeleteShop(context, shop.id),
                    icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                    label: const Text(
                      'Delete',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.green),
          ),
          child: const Text(
            'Approved',
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPendingShopCard(SellerShop shop) {
    return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.orange.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              shop.imageUrl!,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 50,
                height: 50,
                color: AppTheme.cardColor,
                child: Icon(Icons.store, color: AppTheme.subtleTextColor),
              ),
            ),
          ),
          title: Text(
            shop.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                shop.category,
                style: const TextStyle(
                  color: AppTheme.subtleTextColor,
                ),
              ),
              if (shop.description != null && shop.description!.isNotEmpty)
                Text(
                  shop.description!,
                  style: const TextStyle(
                    color: AppTheme.subtleTextColor,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
          trailing: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert), // The classic "3 dots" icon
            onSelected: (String result) {
              // This function is called when a menu item is selected.
              switch (result) {
                case 'edit':
                  // Navigate to the CreateShopScreen and pass the shop data to it.
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CreateShopScreen(shopToUpdate: shop),
                    ),
                  );
                  break;
                case 'cancel':
                  confirmAndDeleteShop(context, shop.id);
                  print('Cancel request for ${shop.name}');
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'edit',
                child: Text('Edit'),
              ),
              const PopupMenuItem<String>(
                value: 'cancel',
                child: Text('Cancel Request'),
              ),
            ],
          ),
        ));
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppTheme.subtleTextColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.subtleTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      backgroundColor: AppTheme.primaryColor,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CreateShopScreen(),
          ),
        );
      },
      child: const Icon(Icons.add, color: Colors.white),
    );
  }
}
