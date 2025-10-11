import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panot/screens/seller/widgets/add_product_dialog.dart';
import '../../models/seller_shop_model.dart';
import '../../theme/app_theme.dart';
import '../../screens/seller/widgets/menu_tab.dart';
import '../../screens/seller/widgets/details_tab.dart';
import '../../screens/seller/widgets/stock_tab.dart';

// The enum is no longer needed for navigation state
// enum ManagementTab { menu, details, stocks }

class SellerShopManagementScreen extends ConsumerStatefulWidget {
  final SellerShop shop;
  const SellerShopManagementScreen({super.key, required this.shop});

  @override
  ConsumerState<SellerShopManagementScreen> createState() =>
      _SellerShopManagementScreenState();
}

class _SellerShopManagementScreenState
    extends ConsumerState<SellerShopManagementScreen> {
  // ✅ 1. State is now managed by an integer index
  int _selectedIndex = 0;
  bool _showAdditionalDetails = false;

  // ✅ Define the pages to be switched
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      MenuTab(shop: widget.shop),
      DetailsTab(shop: widget.shop),
      StocksTab(shop: widget.shop),
    ];
  }

  // SliverAppBar for the management screen (no changes needed here)
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
      actions: [
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
                  offset: const Offset(0, 3),
                ),
              ],
            ),
          ),
        ),
      ],
      title: Text(
        widget.shop.name,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
      pinned: true,
      expandedHeight: 150.0,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            _buildBackgroundImage(),
            Container(
              color: Colors.black.withOpacity(0.40),
            ),
          ],
        ),
      ),
      backgroundColor: AppTheme.primaryColor.withOpacity(0.95),
      elevation: 4.0,
    );
  }

  Widget _buildBackgroundImage() {
    return Image.asset(
      'assets/NU-Dine.png',
      fit: BoxFit.cover,
    );
  }

  /// Compact shop details card with expandable section (no changes needed here)
  Widget _buildShopDetailsCard() {
    return SliverToBoxAdapter(
      child: Container(
        margin:
            const EdgeInsets.fromLTRB(16, 16, 16, 16), // Added bottom margin
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.shop.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _showAdditionalDetails
                        ? Icons.expand_less
                        : Icons.expand_more,
                    color: AppTheme.primaryColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _showAdditionalDetails = !_showAdditionalDetails;
                    });
                  },
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.category_outlined,
                    color: Colors.grey.shade600, size: 16),
                const SizedBox(width: 6),
                Text(
                  widget.shop.category,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 16),
                _buildStatusChip(widget.shop.status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time_outlined,
                    color: Colors.grey.shade600, size: 16),
                const SizedBox(width: 6),
                Text(
                  '${widget.shop.openingTime} - ${widget.shop.closingTime}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            if (_showAdditionalDetails) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Text(
                'Description',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.shop.description ?? 'No description available.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.black87,
                      height: 1.5,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Helper widget to create a colored chip for the shop status
  Widget _buildStatusChip(ShopStatus status) {
    Color chipColor;
    String label;
    IconData icon;

    switch (status) {
      case ShopStatus.Approved:
        chipColor = Colors.green;
        label = 'Approved';
        icon = Icons.check_circle;
        break;
      case ShopStatus.Pending:
        chipColor = Colors.orange;
        label = 'Pending';
        icon = Icons.hourglass_empty;
        break;
      case ShopStatus.Rejected:
        chipColor = Colors.red;
        label = 'Rejected';
        icon = Icons.cancel;
        break;
    }

    return Chip(
      avatar: Icon(icon, color: chipColor, size: 14),
      label: Text(
        label,
        style: TextStyle(
          color: chipColor,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
      backgroundColor: chipColor.withOpacity(0.1),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ 2. The main layout is simplified to a Scaffold with a BottomNavigationBar
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          _buildShopDetailsCard(),
          // ✅ The selected page is rendered here, wrapped in a SliverFillRemaining
          // This allows the content (e.g., a list in MenuTab) to scroll correctly
          SliverFillRemaining(
            hasScrollBody:
                true, // Set to true if your tabs have scrollable lists
            child: _pages[_selectedIndex],
          ),
        ],
      ),
      // MODIFIED: Added the FloatingActionButton
      floatingActionButton: _selectedIndex == 0 // Only show FAB on the Menu tab
          ? FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AddProductDialog(
                    // Parse the shop ID from String to int
                    shopId: int.parse(widget.shop.id),
                  ),
                );
              },
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        // ✅ 3. This is the new navigation widget
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        // ✅ Aesthetic and functional properties
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey.shade600,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        type: BottomNavigationBarType.fixed, // Good for 3-5 items
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu_outlined),
            activeIcon: Icon(Icons.restaurant_menu),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store_outlined),
            activeIcon: Icon(Icons.store),
            label: 'Details',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'Stocks',
          ),
        ],
      ),
    );
  }
}
