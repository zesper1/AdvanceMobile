// screens/admin/admin_dashboard.dart - SIMPLIFIED
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panot/providers/auth_provider.dart';
import 'package:panot/screens/login.dart';
import 'package:panot/services/admin_services.dart';
import 'package:panot/widgets/logout_dialog.dart';
import '../../providers/seller_shop_provider.dart';
import '../../providers/notification_provider.dart';
import '../../models/seller_shop_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/admin/admin_analytics.dart';
import '../../widgets/admin/admin_shop_request.dart';
import '../../widgets/admin/admin_all_shops.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  int _currentIndex = 0;
  final TextEditingController _rejectionReasonController =
      TextEditingController();

  @override
  void dispose() {
    _rejectionReasonController.dispose();
    super.dispose();
  }

 // --- THIS METHOD IS MODIFIED ---
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
      title: const Text(
        'Admin Dashboard',
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
        // Your existing profile button
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: GestureDetector(
            onTap: () {
              // Add admin profile navigation if needed
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
                Icons.admin_panel_settings,
                color: Colors.black87,
              ),
            ),
          ),
        ),
        // ADDED: Logout button
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

  void _approveShop(SellerShop shop) {
    ref
        .read(sellerShopProvider.notifier)
        .updateShopStatus(shop.id, ShopStatus.Approved);
    ref
        .read(sellerShopProvider.notifier)
        .sendShopStatusNotification(shop, ShopStatus.Approved);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${shop.name} has been approved'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _rejectShop(SellerShop shop) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Shop'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reject "${shop.name}"?'),
            const SizedBox(height: 16),
            const Text('Reason for rejection (optional):'),
            const SizedBox(height: 8),
            TextField(
              controller: _rejectionReasonController,
              decoration: const InputDecoration(
                hintText: 'Enter reason...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref
                  .read(sellerShopProvider.notifier)
                  .updateShopStatus(shop.id, ShopStatus.Rejected);
              ref.read(sellerShopProvider.notifier).sendShopStatusNotification(
                    shop,
                    ShopStatus.Rejected,
                    adminNotes: _rejectionReasonController.text.isEmpty
                        ? null
                        : _rejectionReasonController.text,
                  );
              _rejectionReasonController.clear();
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${shop.name} has been rejected'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Reject', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch the provider as before. 'allShopsAsync' is an AsyncValue.
    final allShopsAsync = ref.watch(sellerShopProvider);

    // Use .when() to handle the different states of the AsyncValue
    return allShopsAsync.when(
      // --- 1. LOADING STATE ---
      loading: () => Scaffold(
        appBar: _buildAppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      // --- 2. ERROR STATE ---
      error: (error, stackTrace) => Scaffold(
        appBar: _buildAppBar(),
        body: Center(child: Text('Error fetching shops: $error')),
      ),
      // --- 3. DATA STATE ---
      data: (allShopsList) {
        // The list is now safely unwrapped! 'allShopsList' is a List<SellerShop>.
        // Now you can perform operations like .where() on it.
        final pendingShops = allShopsList
            .where((shop) => shop.status == ShopStatus.Pending)
            .toList();

        // Build the main UI with the actual data
        return Scaffold(
          appBar: _buildAppBar(),
          body: _buildCurrentScreen(allShopsList, pendingShops),
          bottomNavigationBar: _buildBottomNavBar(),
        );
      },
    );
  }

  Widget _buildCurrentScreen(
      List<SellerShop> allShops, List<SellerShop> pendingShops) {
    switch (_currentIndex) {
      case 0:
        return _buildAnalyticsScreen(allShops);
      case 1:
        return AdminShopRequestsWidget(
          pendingShops: pendingShops,
          onApprove: _approveShop,
          onReject: _rejectShop,
        );
      case 2:
        return AdminAllShopsWidget(allShops: allShops);
      default:
        return _buildAnalyticsScreen(allShops);
    }
  }

  // --- THIS METHOD IS NOW POWERED BY YOUR RPC ---
  Widget _buildAnalyticsScreen(List<SellerShop> allShops) {
    // 1. Watch the new provider that calls your RPC
    final analyticsAsync = ref.watch(dashboardAnalyticsProvider);

    // 2. Use .when() to handle loading/error/data states for the analytics
    return analyticsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Failed to load analytics: $err')),
      data: (analyticsData) {
        // 3. Once data arrives, extract it from the map
        final statusDistribution = analyticsData['status_distribution'];
        
        // This data for recent shops still comes from the allShops list
        final recentShops = allShops.take(5).toList();

        // 4. Pass the data fetched from the RPC to your UI widget
        return AdminAnalyticsWidget(
          totalShops: analyticsData['total_shops'],
          activeShops: analyticsData['active_shops'],
          activeUsers: analyticsData['active_users'],
          pendingRequests: analyticsData['pending_requests'],
          pendingCount: statusDistribution['pending']['count'],
          approvedCount: statusDistribution['approved']['count'],
          rejectedCount: statusDistribution['rejected']['count'],
          recentShops: recentShops,
        );
      },
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      selectedItemColor: AppTheme.primaryColor,
      unselectedItemColor: AppTheme.subtleTextColor,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics),
          label: 'Analytics',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.pending_actions),
          label: 'Requests',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.store),
          label: 'All Shops',
        ),
      ],
    );
  }
}
