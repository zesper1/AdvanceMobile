import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panot/models/admin_view_model.dart';
import 'package:panot/models/notification_model.dart';
import 'package:panot/providers/notification_provider.dart';
import 'package:panot/services/admin_services.dart';

// The main Notifier for all admin-related shop data
class AdminNotifier extends AutoDisposeAsyncNotifier<List<AdminShopView>> {
  @override
  Future<List<AdminShopView>> build() async {
    // The initial data fetch calls the AdminService
    return ref.read(adminServiceProvider).fetchAllShopsDetailed();
  }

  /// Updates the status of a specific shop and refreshes the state.
  Future<void> updateShopStatus(String shopId, ShopStatus status) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(adminServiceProvider).updateShopStatus(
            shopId: shopId,
            status: status,
          );
      // After successfully updating, refetch the full list to update the UI.
      return build(); // Re-run the build method to get fresh data
    });
  }

  /// Creates and sends a notification related to a shop's status change.
  void sendShopStatusNotification(
    AdminShopView shop, // Accepts the AdminShopView model
    ShopStatus status, {
    String? adminNotes,
  }) {
    final notificationNotifier = ref.read(notificationProvider.notifier);

    final notification = SellerNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sellerId: shop.ownerId,   // Use ownerId from the view model
      shopId: shop.shopId.toString(), // Use shopId from the view model
      shopName: shop.shopName, // Use shopName from the view model
      type: status == ShopStatus.approved
          ? NotificationType.shopApproved
          : NotificationType.shopRejected,
      message: status == ShopStatus.approved
          ? 'Your shop "${shop.shopName}" has been approved and is now live!'
          : 'Your shop "${shop.shopName}" was rejected.${adminNotes != null ? ' Reason: $adminNotes' : ''}',
      createdAt: DateTime.now(),
    );

    notificationNotifier.addNotification(notification);
  }
}

// The provider that the UI will watch
final adminNotifierProvider =
    AsyncNotifierProvider.autoDispose<AdminNotifier, List<AdminShopView>>(
  () => AdminNotifier(),
);