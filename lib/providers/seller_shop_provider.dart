// providers/seller_shop_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panot/services/shop_services.dart';

import '../models/seller_shop_model.dart'; // Adjust path

// Provider for the ShopService dependency
final shopServiceProvider = Provider<ShopService>((ref) => ShopService());

// The main notifier to manage the seller's shops state
class SellerShopNotifier extends AutoDisposeAsyncNotifier<List<SellerShop>> {
  
  // The build method is called when the provider is first initialized.
  // It fetches the initial list of shops.
  @override
  Future<List<SellerShop>> build() async {
    return ref.read(shopServiceProvider).getSellerShops();
  }

  // Add a new shop by calling the service, then refetch the list.
  Future<void> addShop({
    required String shopName,
    required String description,
    required String logoUrl,
    required TimeOfDay openingTime,
    required TimeOfDay closingTime,
    required String categoryName,
    required List<String> subcategoryNames,
  }) async {
    // Set state to loading to show a loading indicator in the UI
    state = const AsyncValue.loading();
    
    // Perform the async operation and update the state with the result
    state = await AsyncValue.guard(() async {
      await ref.read(shopServiceProvider).createShop(
            shopName: shopName,
            description: description,
            imagePath: logoUrl,
            openingTime: openingTime,
            closingTime: closingTime,
            categoryName: categoryName,
            subcategoryNames: subcategoryNames,
          );
      // After adding, refetch the full list to get the updated data
      return ref.read(shopServiceProvider).getSellerShops();
    });
  }

  // In a real app, update and delete would also be async methods
  // that call your service and then refetch the state.
}

// The main provider for accessing the notifier and its state
final sellerShopProvider =
    AsyncNotifierProvider.autoDispose<SellerShopNotifier, List<SellerShop>>(
  () => SellerShopNotifier(),
);

// A provider to get all shops (already filtered for the current seller by the notifier)
final allSellerShopsProvider = Provider.autoDispose<AsyncValue<List<SellerShop>>>((ref) {
  return ref.watch(sellerShopProvider);
});


// A provider to get only the approved shops for the current seller
final sellerApprovedShopsProvider = Provider.autoDispose<AsyncValue<List<SellerShop>>>((ref) {
  // Watch the main provider and filter its data when it's available
  return ref.watch(sellerShopProvider).whenData(
    (shops) => shops.where((shop) => shop.status == ShopStatus.Approved).toList(),
  );
});

// A provider to get only the pending shops for the current seller
final sellerPendingShopsProvider = Provider.autoDispose<AsyncValue<List<SellerShop>>>((ref) {
  return ref.watch(sellerShopProvider).whenData(
    (shops) => shops.where((shop) => shop.status == ShopStatus.Pending).toList(),
  );
});