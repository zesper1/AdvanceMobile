// widgets/admin/admin_shop_requests_widget.dart
import 'package:flutter/material.dart';
import '../../models/seller_shop_model.dart';
import '../../theme/app_theme.dart';

class AdminShopRequestsWidget extends StatelessWidget {
  final List<SellerShop> pendingShops;
  final Function(SellerShop) onApprove;
  final Function(SellerShop) onReject;

  const AdminShopRequestsWidget({
    super.key,
    required this.pendingShops,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(20),
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
          child: Row(
            children: [
              const Icon(Icons.pending_actions, color: Colors.orange, size: 24),
              const SizedBox(width: 12),
              const Text(
                'Pending Shop Requests',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${pendingShops.length} requests',
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Requests List
        Expanded(
          child: pendingShops.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: pendingShops.length,
                  itemBuilder: (context, index) {
                    final shop = pendingShops[index];
                    return _buildRequestCard(shop, context);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildRequestCard(SellerShop shop, BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    shop.imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 60,
                      height: 60,
                      color: AppTheme.cardColor,
                      child: Icon(Icons.store, color: AppTheme.subtleTextColor),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shop.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        shop.category,
                        style: TextStyle(
                          color: AppTheme.subtleTextColor,
                        ),
                      ),
                      Text(
                        '${shop.openingTime} - ${shop.closingTime}',
                        style: TextStyle(
                          color: AppTheme.subtleTextColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (shop.description != null && shop.description!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                shop.description!,
                style: TextStyle(
                  color: AppTheme.subtleTextColor,
                  fontSize: 14,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => onReject(shop),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => onApprove(shop),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Approve',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pending_actions,
              size: 64,
              color: AppTheme.subtleTextColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No pending requests',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'All shop requests have been processed',
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
}
