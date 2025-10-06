// screens/seller/seller_home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panot/services/shop_services.dart';
import '../../providers/seller_shop_provider.dart';
import '../../providers/food_stall_provider.dart';
import '../../widgets/seller_navbar.dart';
import '../../widgets/stalls/food_stall_card.dart';
import '../../theme/app_theme.dart';
import 'create_shop.dart';
import 'seller_account.dart';
import '../../models/seller_shop_model.dart';
import '../../models/food_stall_model.dart';

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
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _selectedStatus = 'All'; // 'All', 'Open', 'Closed'
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _searchController.text = 'Search for shop...';
  }

  @override
  void dispose() {
    _searchController.dispose();
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
      floatingActionButton: _currentIndex == 0 ? _buildFloatingActionButton() : null,
      bottomNavigationBar: SellerBottomNavBar(
        initialIndex: _currentIndex,
        onTabChanged: _onTabChanged,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/NU-D.jpg'), // Replace with your image path
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
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          color: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
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
                hintText: 'Search for shop...',
                prefixIcon: Icon(Icons.search, color: AppTheme.subtleTextColor),
              ),
              onTap: () {
                if (_searchController.text == 'Search for shop...') {
                  setState(() {
                    _searchController.clear();
                  });
                }
              },
              onChanged: (value) {
                // Implement search functionality
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return _buildShopsScreen();
      case 1:
        return SellerAccountScreen(sellerId: widget.sellerId);
      default:
        return _buildShopsScreen();
    }
  }

  Widget _buildShopsScreen() {
    final shopsAsyncValue = ref.watch(sellerShopProvider);

    return shopsAsyncValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Failed to load shops: $error')),
      data: (allMyShops) {
        final approvedShops = allMyShops.where((s) => s.status == ShopStatus.Approved).toList();
        final pendingShops = allMyShops.where((s) => s.status == ShopStatus.Pending).toList();
        
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

  Widget _buildWelcomeSection(int approvedCount, int pendingCount) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withOpacity(0.9),
            const Color(0xFF1976D2).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, ${widget.sellerName}! 👋',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage your business efficiently',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.storefront,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildWelcomeStatItem(
                count: approvedCount,
                label: 'Active Shops',
                icon: Icons.check_circle,
                color: Colors.greenAccent,
              ),
              _buildWelcomeStatItem(
                count: pendingCount,
                label: 'Pending',
                icon: Icons.pending,
                color: Colors.orangeAccent,
              ),
              _buildWelcomeStatItem(
                count: approvedCount + pendingCount,
                label: 'Total',
                icon: Icons.assessment,
                color: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeStatItem({
    required int count,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 6),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
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
        title: 'No shops yet',
        subtitle: 'Create your first shop to get started',
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
    // Apply both category and status filters
    List<FoodStall> filteredShops = allShops;
    
    // Apply category filter
    if (_selectedCategory != 'All') {
      filteredShops = filteredShops.where((shop) => shop.category == _selectedCategory).toList();
    }
    
    // Apply status filter
    if (_selectedStatus != 'All') {
      filteredShops = filteredShops.where((shop) {
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
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredShops.length,
                  itemBuilder: (context, index) {
                    final shop = filteredShops[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: FoodStallCard(
                        stall: shop,
                        cardType: 'horizontal',
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
                        icon: const Icon(Icons.arrow_drop_down, color: AppTheme.textColor, size: 20),
                        style: const TextStyle(fontSize: 14, color: AppTheme.textColor),
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
                            child: _buildStatusToggle('All', Icons.all_inclusive),
                          ),
                          Expanded(
                            child: _buildStatusToggle('Open', Icons.check_circle),
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
          color: isSelected ? selectedColor.withOpacity(0.1) : Colors.transparent,
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
            Text(
              '${shop.openingTime} - ${shop.closingTime}',
              style: const TextStyle(
                color: AppTheme.subtleTextColor,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: shop.status == ShopStatus.Approved 
                ? Colors.green.withOpacity(0.1)
                : Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: shop.status == ShopStatus.Approved 
                  ? Colors.green
                  : Colors.orange,
            ),
          ),
          child: Text(
            shop.status == ShopStatus.Approved ? 'Approved' : 'Pending',
            style: TextStyle(
              color: shop.status == ShopStatus.Approved 
                  ? Colors.green
                  : Colors.orange,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
        onTap: () {
          // Add shop details navigation if needed
        },
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
                    builder: (context) => CreateShopScreen(shopToUpdate: shop),
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
      ),
    );
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
  void confirmAndDeleteShop(BuildContext context, String shopId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to permanently delete this shop and all its subcategories? This cannot be undone.'),
          actions: <Widget>[
            // 1. CANCEL BUTTON
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss the dialog
              },
            ),
            
            // 2. DELETE BUTTON (Calls the function)
            TextButton(
              // Use a red color to emphasize the destructive action
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
              onPressed: () async {
                // Dismiss the dialog first
                Navigator.of(dialogContext).pop(); 

                try {
                  // Call the Supabase function
                  final shopService = ShopService();
                  await shopService.deleteShop(shopId);

                  // ⭐ SUCCESS FEEDBACK (Example)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Shop successfully deleted!')),
                  );
                  
                  // Navigate back or update the UI after a successful deletion
                  // Navigator.of(context).pop(); 

                } catch (e) {
                  // ⭐ ERROR FEEDBACK (Example)
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
  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      backgroundColor: AppTheme.primaryColor,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CreateShopScreen(),
          ),
        );
      },
      child: const Icon(Icons.add, color: Colors.white),
    );
  }
}