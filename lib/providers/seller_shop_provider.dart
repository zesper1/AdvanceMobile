import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:panot/services/shop_services.dart';
import '../models/seller_shop_model.dart';

// Provider for the ShopService dependency
final shopServiceProvider = Provider<ShopService>((ref) => ShopService());

// The main notifier to manage the seller's shops state
class SellerShopNotifier extends AutoDisposeAsyncNotifier<List<SellerShop>> {
  @override
  Future<List<SellerShop>> build() async {
    // This method is called when the provider is first read.
    // It fetches the initial list of shops for the current seller.
    return ref.read(shopServiceProvider).getSellerShops();
  }

  // This method now accepts an XFile object instead of a String path.
  Future<void> addShop({
    required String shopName,
    required String description,
    required XFile imageFile, // CHANGED: from imagePath to XFile
    required TimeOfDay openingTime,
    required TimeOfDay closingTime,
    required String categoryName,
    required List<String> subcategoryNames,
  }) async {
    state = const AsyncValue.loading();
    // Use AsyncValue.guard to handle potential errors from the service.
    state = await AsyncValue.guard(() async {
      await ref.read(shopServiceProvider).createShop(
            shopName: shopName,
            description: description,
            imageFile: imageFile, // Pass the XFile object to the service
            openingTime: openingTime,
            closingTime: closingTime,
            categoryName: categoryName,
            subcategoryNames: subcategoryNames,
          );
      // After successfully adding, refetch the full list to update the UI.
      return ref.read(shopServiceProvider).getSellerShops();
    });
  }
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

