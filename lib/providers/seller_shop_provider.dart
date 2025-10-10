import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:panot/models/notification_model.dart';
import 'package:panot/providers/notification_provider.dart';
import 'package:panot/services/admin_services.dart';
import 'package:panot/services/shop_services.dart';
import '../models/seller_shop_model.dart';

// Provider for the ShopService dependency
final shopServiceProvider = Provider<ShopService>((ref) => ShopService());
// CORRECTED: The AdminService provider now gets the client and passes it to the service.
class SellerShopNotifier extends AutoDisposeAsyncNotifier<List<SellerShop>> {
  @override
  Future<List<SellerShop>> build() async {
    // This method is called when the provider is first read.
    // It fetches the initial list of shops for the current seller.
    return ref.read(shopServiceProvider).getSellerShops();
  }

  Future<void> addShop({
    required String shopName,
    required String description,
    required XFile imageFile,
    required TimeOfDay openingTime,
    required TimeOfDay closingTime,
    required int categoryName,
    required List<int> subcategoryNames,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(shopServiceProvider).createShop(
            shopName: shopName,
            description: description,
            imageFile: imageFile,
            openingTime: openingTime,
            closingTime: closingTime,
            categoryName: categoryName,
            subcategoryNames: subcategoryNames,
          );
      // After successfully adding, refetch the full list to update the UI.
      return ref.read(shopServiceProvider).getSellerShops();
    });
  }

  Future<void> updateShop({
    required String shopId,
    required String shopName,
    required String description,
    XFile? newImageFile, // Make the new image optional
    required TimeOfDay openingTime,
    required TimeOfDay closingTime,
    required int categoryId,
    required List<int> subcategoryIds,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // Call a new service method to handle the update logic
      await ref.read(shopServiceProvider).updateShop(
            shopId: shopId,
            shopName: shopName,
            description: description,
            newImageFile: newImageFile,
            openingTime: openingTime,
            closingTime: closingTime,
            categoryId: categoryId,
            subcategoryIds: subcategoryIds,
          );
      // After updating, refetch the full list to update the UI.
      return ref.read(shopServiceProvider).getSellerShops();
    });
  }
  /// This is business logic that lives alongside the state management.
  void sendShopStatusNotification(
    SellerShop shop,
    ShopStatus status, {
    String? adminNotes,
  }) {
    // This uses the built-in `ref` from the Notifier, no need to pass it in.
    final notificationNotifier = ref.read(notificationProvider.notifier);

    final notification = SellerNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sellerId: shop.sellerId,
      shopId: shop.id,
      shopName: shop.name,
      type: status == ShopStatus.Approved
          ? NotificationType.shopApproved
          : NotificationType.shopRejected,
      message: status == ShopStatus.Approved
          ? 'Your shop "${shop.name}" has been approved and is now live!'
          : 'Your shop "${shop.name}" was rejected.${adminNotes != null ? ' Reason: $adminNotes' : ''}',
      createdAt: DateTime.now(),
    );

    notificationNotifier.addNotification(notification);
  }
} // This brace correctly closes the SellerShopNotifier class.

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

// The extra closing brace that caused the error has been removed from here.