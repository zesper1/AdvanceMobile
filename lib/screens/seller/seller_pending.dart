// screens/seller/seller_pending.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/seller_shop_model.dart';
import '../../providers/seller_shop_provider.dart';
import '../../theme/app_theme.dart';

// The sellerId is no longer needed as the provider is user-aware.
class SellerPendingRequestsScreen extends ConsumerWidget {
  const SellerPendingRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the new provider for pending shops.
    final pendingShopsAsync = ref.watch(sellerPendingShopsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Requests'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      // Use .when() to handle the different states of the async data.
      body: pendingShopsAsync.when(
        // 1. Show a loading indicator while fetching.
        loading: () => const Center(child: CircularProgressIndicator()),
        
        // 2. Show an error message if something goes wrong.
        error: (err, stack) => Center(child: Text('Error: $err')),
        
        // 3. Show the data when it's available.
        data: (pendingShops) {
          if (pendingShops.isEmpty) {
            return const Center(
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
            );
          }
          // If data is not empty, build the list.
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pendingShops.length,
            itemBuilder: (context, index) {
              final shop = pendingShops[index];
              return _buildPendingShopCard(shop);
            },
          );
        },
      ),
    );
  }

  // This widget builder remains exactly the same.
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
                    shop.imageUrl ?? 'https://placehold.co/60x60', // Handle null imageUrl
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