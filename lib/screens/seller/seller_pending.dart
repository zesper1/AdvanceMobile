// screens/seller/seller_pending.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/seller_shop_model.dart';
import '../../providers/seller_shop_provider.dart';
import '../../theme/app_theme.dart';

class SellerPendingRequestsScreen extends ConsumerWidget {
  final String sellerId;

  const SellerPendingRequestsScreen({super.key, required this.sellerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingShops = ref.watch(sellerPendingShopsProvider(sellerId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Requests'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: pendingShops.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pending_actions, size: 64, color: AppTheme.subtleTextColor),
                  SizedBox(height: 16),
                  Text(
                    'No pending requests',
                    style: TextStyle(
                      color: AppTheme.subtleTextColor,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your shop requests will appear here',
                    style: TextStyle(
                      color: AppTheme.subtleTextColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pendingShops.length,
              itemBuilder: (context, index) {
                final shop = pendingShops[index];
                return _buildPendingShopCard(shop);
              },
            ),
    );
  }

  Widget _buildPendingShopCard(SellerShop shop) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
                      child: const Icon(Icons.store, color: AppTheme.subtleTextColor),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
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
                        style: const TextStyle(
                          color: AppTheme.subtleTextColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${shop.openingTime} - ${shop.closingTime}',
                        style: const TextStyle(
                          color: AppTheme.subtleTextColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Pending',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            if (shop.description != null && shop.description!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                shop.description!,
                style: const TextStyle(
                  color: AppTheme.subtleTextColor,
                  fontSize: 14,
                ),
              ),
            ],
            if (shop.customCategories.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: shop.customCategories.map((category) {
                  return Chip(
                    label: Text(category),
                    backgroundColor: AppTheme.accentColor.withOpacity(0.2),
                    labelStyle: const TextStyle(fontSize: 12),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}