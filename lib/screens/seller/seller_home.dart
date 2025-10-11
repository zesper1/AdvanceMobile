// screens/seller/seller_home_screen.dart - COMPLETE FILE
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panot/models/food_stall_model.dart';
import 'package:panot/models/seller_shop_model.dart';
import 'package:panot/providers/auth_provider.dart';
import 'package:panot/providers/food_stall_provider.dart';
import 'package:panot/providers/seller_shop_provider.dart';
import 'package:panot/screens/login.dart';
import 'package:panot/theme/app_theme.dart';
import 'package:panot/widgets/logout_dialog.dart';
import 'package:panot/widgets/stalls/food_stall_card.dart';

import 'create_shop.dart';
import 'seller_account.dart';
import 'seller_shop_management_screen.dart';

class SellerHomeScreen extends ConsumerStatefulWidget {
  final String sellerId;
  final String sellerName;

  const SellerHomeScreen({
    super.key,
    required this.sellerId,
    this.sellerName = 'Seller',
  });

  @override
  ConsumerState<SellerHomeScreen> createState() => _SellerHomeScreenState();
}

class _SellerHomeScreenState extends ConsumerState<SellerHomeScreen> {
  String _selectedCategory = 'All';
  String _selectedStatus = 'All'; // 'All', 'Open', 'Closed'
  bool _showWelcomeBanner = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildShopsScreen(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/NU-D.jpg'),
            fit: BoxFit.cover,
          ),
        ),
      ),
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
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
        IconButton(
          icon: const Icon(Icons.account_circle, color: Colors.white),
          tooltip: 'Account',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SellerAccountScreen(sellerId: widget.sellerId),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          tooltip: 'Logout',
          onPressed: () async {
            final didRequestLogout = await showLogoutConfirmationDialog(context);
            if (mounted && didRequestLogout == true) {
              try {
                await ref.read(authNotifierProvider.notifier).signOut();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to log out: $e'),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              }
            }
          },
        ),
      ],
    );
  }

  Widget _buildShopsScreen() {
    // 1. Watch both async providers
    final shopsAsyncValue = ref.watch(sellerShopProvider);
    final allShopsForCustomerView = ref.watch(foodStallProvider);

    // 2. Handle YOUR shops (sellerShopProvider) loading/error states first
    return shopsAsyncValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Failed to load my shops: $error')),
      data: (allMyShops) {
        final approvedShops = allMyShops.where((s) => s.status == ShopStatus.Approved).toList();
        final pendingShops = allMyShops.where((s) => s.status == ShopStatus.Pending).toList();

        // 3. Now that 'allMyShops' is ready, handle the 'All Shops' tab data (foodStallProvider)
        return Column(
          children: [
            if (_showWelcomeBanner)
              _buildWelcomeSection(approvedShops.length, pendingShops.length),
            Expanded(
              child: DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    Container(
                      // ... TabBar styling ...
                      child: const TabBar(
                        labelColor: AppTheme.primaryColor,
                        unselectedLabelColor: AppTheme.subtleTextColor,
                        indicatorColor: AppTheme.primaryColor,
                        tabs: [
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
                          // 4. CORRECTION HERE: Handle the AsyncValue for the 'All Shops' tab
                          allShopsForCustomerView.when(
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (error, stack) => Center(child: Text('Failed to load all stalls: $error')),
                            data: (allShops) {
                              // Data is available, pass the plain List<FoodStall>
                              return _buildAllShopsTab(allShops);
                            },
                          ),
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
      itemBuilder: (context, index) => _buildSellerShopCard(myShops[index]),
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
      itemBuilder: (context, index) => _buildPendingShopCard(pendingShops[index]),
    );
  }

  Widget _buildAllShopsTab(List<FoodStall> allShops) {
    List<FoodStall> filteredShops = allShops;
    if (_selectedCategory != 'All') {
      filteredShops = filteredShops.where((shop) => shop.category == _selectedCategory).toList();
    }
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
                        showFavoriteButton: false,
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
                          setState(() => _selectedCategory = newValue!);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Status', /* ... */),
                    const SizedBox(height: 4),
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(child: _buildStatusToggle('All', Icons.all_inclusive)),
                          Expanded(child: _buildStatusToggle('Open', Icons.check_circle)),
                          Expanded(child: _buildStatusToggle('Closed', Icons.cancel)),
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
            shop.imageUrl ?? '',
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
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(shop.category, style: const TextStyle(color: AppTheme.subtleTextColor)),
            Text(
              '${shop.openingTime} - ${shop.closingTime}',
              style: const TextStyle(color: AppTheme.subtleTextColor, fontSize: 12),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: SizedBox(
                height: 30,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SellerShopManagementScreen(shop: shop),
                      ),
                    );
                  },
                  icon: const Icon(Icons.settings, size: 16),
                  label: const Text(
                    'Manage Shop',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    side: BorderSide(color: AppTheme.primaryColor.withOpacity(0.5), width: 1),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ),
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
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600, fontSize: 12),
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
        border: Border.all(color: Colors.orange.withOpacity(0.2), width: 1),
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
            shop.imageUrl ?? '',
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
        title: Text(shop.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(shop.category, style: const TextStyle(color: AppTheme.subtleTextColor)),
            if (shop.description != null && shop.description!.isNotEmpty)
              Text(
                shop.description!,
                style: const TextStyle(color: AppTheme.subtleTextColor, fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (String result) {
            if (result == 'edit') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateShopScreen(shopToUpdate: shop),
                ),
              );
            } else if (result == 'cancel') {
              confirmAndDeleteShop(context, shop.id);
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(value: 'edit', child: Text('Edit')),
            const PopupMenuItem<String>(value: 'cancel', child: Text('Cancel Request')),
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
              style: const TextStyle(
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
          title: const Text('Confirm Cancellation'),
          content: const Text('Are you sure you want to cancel this shop request? This will permanently delete it.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Back'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Cancel Request'),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                try {
                  // This assumes your notifier has a deleteShop method.
                  await ref.read(sellerShopProvider.notifier).deleteShop(shopId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Shop request cancelled successfully!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Cancellation failed: ${e.toString()}')),
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