// screens/admin/admin_dashboard.dart - REFACTORED
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panot/providers/auth_provider.dart';
import 'package:panot/screens/login.dart';
import 'package:panot/widgets/logout_dialog.dart';
import '../../providers/admin_provider.dart'; // MODIFIED: Use the new admin provider
import '../../models/admin_view_model.dart';
import '../../services/admin_services.dart';
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
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: GestureDetector(
            onTap: () {
              // TODO: Add admin profile navigation
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

  // --- METHODS NOW CORRECTLY USE THE ADMIN NOTIFIER AND MODEL ---

  void _approveShop(AdminShopView shop) {
    ref
        .read(adminNotifierProvider.notifier)
        .updateShopStatus(shop.shopId.toString(), ShopStatus.approved);
    ref
        .read(adminNotifierProvider.notifier)
        .sendShopStatusNotification(shop, ShopStatus.approved);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${shop.shopName} has been approved'),
        backgroundColor: Colors.green,
      ),
    );
  }

// In lib/screens/admin/admin_dashboard.dart

void _rejectShop(AdminShopView shop) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Reject Shop'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Are you sure you want to reject "${shop.shopName}"?'),
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
        // FIX 1: Added the required onPressed callback and a child
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () {
            ref
                .read(adminNotifierProvider.notifier)
                // FIX 2: Changed 'Rejected' to 'rejected'
                .updateShopStatus(shop.shopId.toString(), ShopStatus.rejected);
            ref.read(adminNotifierProvider.notifier).sendShopStatusNotification(
                  shop,
                  // FIX 2: Changed 'Rejected' to 'rejected'
                  ShopStatus.rejected,
                  adminNotes: _rejectionReasonController.text.isEmpty
                      ? null
                      : _rejectionReasonController.text,
                );
            _rejectionReasonController.clear();
            Navigator.pop(context);

            // FIX 3: Provided the required SnackBar widget
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${shop.shopName} has been rejected'),
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
    // MODIFIED: Watch the single source of truth for admin data
    final allShopsAsync = ref.watch(adminNotifierProvider);

    return allShopsAsync.when(
      loading: () => Scaffold(
        appBar: _buildAppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: _buildAppBar(),
        body: Center(child: Text('Error fetching shops: $error')),
      ),
      data: (allShopsList) { // This is now correctly a List<AdminShopView>
        return Scaffold(
          appBar: _buildAppBar(),
          body: _buildCurrentScreen(allShopsList),
          bottomNavigationBar: _buildBottomNavBar(),
        );
      },
    );
  }

  Widget _buildCurrentScreen(List<AdminShopView> allShops) {
    switch (_currentIndex) {
      case 0:
        return _buildAnalyticsScreen(allShops);
      case 1:
        // MODIFIED: This widget now fetches its own data, so we don't pass anything.
        return AdminShopRequestsWidget(
          onApprove: _approveShop,
          onReject: _rejectShop,
        );
      case 2:
        return AdminAllShopsWidget(allShops: allShops);
      default:
        return _buildAnalyticsScreen(allShops);
    }
  }

  Widget _buildAnalyticsScreen(List<AdminShopView> allShops) {
    final analyticsAsync = ref.watch(dashboardAnalyticsProvider);
    return analyticsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Failed to load analytics: $err')),
      data: (analyticsData) {
        final statusDistribution = analyticsData['status_distribution'];
        final recentShops = allShops.take(5).toList();
        return AdminAnalyticsWidget(
          totalShops: analyticsData['total_shops'],
          activeShops: analyticsData['active_shops'],
          activeUsers: analyticsData['active_users'],
          pendingRequests: analyticsData['pending_requests'],
          pendingCount: statusDistribution['pending']['count'],
          approvedCount: statusDistribution['approved']['count'],
          rejectedCount: statusDistribution['rejected']['count'],
          recentShops: recentShops, // You will need to update AdminAnalyticsWidget to accept List<AdminShopView>
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
