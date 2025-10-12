import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panot/screens/seller/widgets/add_product_dialog.dart';
import '../../models/seller_shop_model.dart';
import '../../providers/seller_shop_provider.dart';
import '../../theme/app_theme.dart';
import '../../screens/seller/widgets/menu_tab.dart';
import '../../screens/seller/widgets/details_tab.dart';
import '../../screens/seller/widgets/stock_tab.dart';
import '../../screens/seller/widgets/reviewstab.dart';

class SellerShopManagementScreen extends ConsumerStatefulWidget {
  final SellerShop shop;
  const SellerShopManagementScreen({super.key, required this.shop});

  @override
  ConsumerState<SellerShopManagementScreen> createState() =>
      _SellerShopManagementScreenState();
}

class _SellerShopManagementScreenState
    extends ConsumerState<SellerShopManagementScreen> {
  int _selectedIndex = 0;
  bool _showAdditionalDetails = false;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      MenuTab(shop: widget.shop),
      DetailsTab(shop: widget.shop),
      StocksTab(shop: widget.shop),
      ReviewsTab(shop: widget.shop),
    ];
  }

  // ✅ 1. RESTORED HELPER METHODS with 'OnBreak'
  Color _getColor(ShopAvailabilityStatus? status) {
    switch (status) {
      case ShopAvailabilityStatus.Open:
        return Colors.green.shade600;
      case ShopAvailabilityStatus.OnBreak:
        return Colors.orange.shade700;
      case ShopAvailabilityStatus.Closed:
      default: // Handles null and Closed cases
        return Colors.red.shade600;
    }
  }

  Color _getFillColor(ShopAvailabilityStatus? status) {
    switch (status) {
      case ShopAvailabilityStatus.Open:
        return Colors.green.shade100;
      case ShopAvailabilityStatus.OnBreak:
        return Colors.orange.shade100;
      case ShopAvailabilityStatus.Closed:
      default: // Handles null and Closed cases
        return Colors.red.shade100;
    }
  }

  // ... (SliverAppBar, _buildBackgroundImage, _buildShopDetailsCard, and _buildStatusChip methods are unchanged)
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
        widget.shop.name,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 17,
        ),
      ),
      centerTitle: true,
      pinned: true,
      expandedHeight: 100.0,
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

  Widget _buildShopDetailsCard(SellerShop currentShop) {
    return SliverToBoxAdapter(
      child: Container(
        margin:
            const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
                    currentShop.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
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
                  currentShop.category,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 16),
                _buildStatusChip(currentShop.status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time_outlined,
                    color: Colors.grey.shade600, size: 16),
                const SizedBox(width: 6),
                Text(
                  '${currentShop.openingTime} - ${currentShop.closingTime}',
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
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                currentShop.description ?? 'No description available.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
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

  // ✅ 2. UPDATED TOGGLE WIDGET with three options
  Widget _buildOperationalStatusToggle(SellerShop currentShop) {
    final isSelected = [
      currentShop.availabilityStatus == ShopAvailabilityStatus.Open,
      currentShop.availabilityStatus == ShopAvailabilityStatus.Closed,
      currentShop.availabilityStatus == ShopAvailabilityStatus.OnBreak,
    ];

    final color = _getColor(currentShop.availabilityStatus);
    final fillColor = _getFillColor(currentShop.availabilityStatus);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Center(
          child: ToggleButtons(
            isSelected: isSelected,
            onPressed: (int index) {
              // The index directly maps to the enum order
              final newStatus = ShopAvailabilityStatus.values[index];

              if (newStatus == currentShop.availabilityStatus) return;

              ref.read(sellerShopProvider.notifier).updateShopAvailability(
                    shopId: currentShop.id,
                    newStatus: newStatus,
                  );
            },
            borderRadius: BorderRadius.circular(10.0),
            selectedBorderColor: color,
            fillColor: fillColor,
            selectedColor: color,
            color: Colors.grey.shade700,
            constraints: const BoxConstraints(minHeight: 40.0, minWidth: 100.0),
            children: <Widget>[
              _buildToggleButtonChild(
                icon: Icons.check_circle_outline,
                label: 'Open',
                isSelected: isSelected[0],
                color: _getColor(ShopAvailabilityStatus.Open),
              ),
              _buildToggleButtonChild(
                icon: Icons.cancel_outlined,
                label: 'Closed',
                isSelected: isSelected[1],
                color: _getColor(ShopAvailabilityStatus.Closed),
              ),
              _buildToggleButtonChild(
                icon: Icons.pause_circle_outline,
                label: 'On Break',
                isSelected: isSelected[2],
                color: _getColor(ShopAvailabilityStatus.OnBreak),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper for toggle button children. No changes needed here.
  Widget _buildToggleButtonChild({
    required IconData icon,
    required String label,
    required bool isSelected,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? color : Colors.grey.shade700,
              )),
        ],
      ),
    );
  }

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
          fontSize: 9,
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
    final asyncSellerShops = ref.watch(sellerShopProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: asyncSellerShops.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (shopList) {
          final currentShop = shopList.firstWhere(
            (s) => s.id == widget.shop.id,
            orElse: () => widget.shop,
          );

          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(context),
              _buildShopDetailsCard(currentShop),
              _buildOperationalStatusToggle(currentShop),
              SliverFillRemaining(
                hasScrollBody: true,
                child: _pages[_selectedIndex],
              ),
            ],
          );
        },
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AddProductDialog(
                    shopId: int.parse(widget.shop.id),
                  ),
                );
              },
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey.shade600,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        type: BottomNavigationBarType.fixed,
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
          BottomNavigationBarItem(
            icon: Icon(Icons.reviews_outlined),
            activeIcon: Icon(Icons.reviews),
            label: 'Reviews',
          )
        ],
      ),
    );
  }
}