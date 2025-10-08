// lib/providers/seller_shop_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/seller_shop_model.dart';
import 'notification_provider.dart';
import '../models/notification_model.dart';
import '../models/menu_model.dart';
import 'menu_provider.dart';

class SellerShopNotifier extends StateNotifier<List<SellerShop>> {
  SellerShopNotifier()
      : super([
          SellerShop(
            id: '1',
            sellerId: 'demo_seller_001',

            name: 'Crispy Corner',
            category: 'Snack',
            description: 'Delicious and crispy snacks for everyone.',
            imageUrl:
                'https://placehold.co/600x400/FFF4E0/000000?text=Crispy+Corner',
            openingTime: '08:00 AM',
            closingTime: '10:00 PM',
            status: ShopStatus.Approved,
            rating: 4.5,
            createdAt: DateTime.now().subtract(const Duration(days: 30)),
            customCategories: [
              'Fried Food',
              'Quick Snacks',
              'Student Favorites'
            ], // Added
          ),
          SellerShop(
            id: 'shop2',
            sellerId: 'seller_one',
            name: 'The Juice Bar',
            category: 'Drinks',
            description: 'Fresh and healthy juices to brighten your day.',
            imageUrl:
                'https://placehold.co/600x400/D2E3C8/000000?text=Juice+Bar',
            openingTime: '09:00 AM',
            closingTime: '08:00 PM',
            status: ShopStatus.Approved,
            rating: 4.8,
            createdAt: DateTime.now().subtract(const Duration(days: 60)),
            customCategories: [
              'Healthy Options',
              'Fresh Juice',
              'Smoothies'
            ], // Added
          ),
          SellerShop(
            id: 'shop3',
            sellerId: 'seller_two',
            name: 'Mama\'s Kitchen',
            category: 'Meal',
            description: 'Hearty home-cooked meals, just like mama makes.',
            imageUrl:
                'https://placehold.co/600x400/FFD9C0/000000?text=Mama\'s+Kitchen',
            openingTime: '10:00 AM',
            closingTime: '09:00 PM',
            status: ShopStatus.Pending,
            rating: 4.2,
            createdAt: DateTime.now().subtract(const Duration(days: 5)),
            customCategories: [
              'Home Style',
              'Comfort Food',
              'Budget Meals'
            ], // Added
          ),
          SellerShop(
            id: 'shop4',
            sellerId: 'seller_two',
            name: 'Quick Bites',
            category: 'Snack',
            description: 'Fast and tasty snacks on the go.',
            imageUrl:
                'https://placehold.co/600x400/A2CDB0/000000?text=Quick+Bites',
            openingTime: '11:00 AM',
            closingTime: '11:00 PM',
            status: ShopStatus.Approved,
            rating: 3.8,
            createdAt: DateTime.now().subtract(const Duration(days: 90)),
            customCategories: ['Fast Food', 'On-the-Go', 'Late Night'], // Added
          ),
          SellerShop(
            id: 'shop5',
            sellerId: 'seller_one',
            name: 'Ocean Fresh',
            category: 'Meal',
            description: 'The freshest seafood dishes in town.',
            imageUrl:
                'https://placehold.co/600x400/8ECDDD/000000?text=Ocean+Fresh',
            openingTime: '10:00 AM',
            closingTime: '09:00 PM',
            status: ShopStatus.Approved,
            rating: 4.9,
            createdAt: DateTime.now().subtract(const Duration(days: 120)),
            customCategories: ['Seafood', 'Healthy', 'Premium'], // Added
          ),
          SellerShop(
            id: 'shop6',
            sellerId: 'seller_two',
            name: 'Boba Bliss',
            category: 'Drinks',
            description: 'Blissful boba tea creations.',
            imageUrl:
                'https://placehold.co/600x400/F6F4EB/000000?text=Boba+Bliss',
            openingTime: '12:00 PM',
            closingTime: '10:00 PM',
            status: ShopStatus.Pending,
            rating: 4.1,
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
            customCategories: [
              'Bubble Tea',
              'Dessert Drinks',
              'Asian Beverages'
            ], // Added
          ),
        ]);

  final menuItemsBySellerProvider =
      Provider.family<List<MenuItem>, String>((ref, sellerId) {
    final allMenuItems = ref.watch(menuProvider);
    final allShops = ref.watch(sellerShopProvider);
    final sellerShopIds = allShops
        .where((shop) => shop.sellerId == sellerId)
        .map((shop) => shop.id)
        .toList();

    return allMenuItems
        .where((item) => sellerShopIds.contains(item.stallId))
        .toList();
  });

  // Adds a new shop to the state.
  void addShop(SellerShop shop) {
    state = [...state, shop];
  }

  // Updates the status of a specific shop.
  void updateShopStatus(String shopId, ShopStatus status) {
    state = [
      for (final shop in state)
        if (shop.id == shopId) shop.copyWith(status: status) else shop,
    ];
  }

  // Creates and sends a notification related to a shop's status change.
  void sendShopStatusNotification(
    SellerShop shop,
    ShopStatus status,
    WidgetRef ref, {
    String? adminNotes,
  }) {
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

  // Retrieves all shops for a given seller ID.
  List<SellerShop> getShopsBySeller(String sellerId) {
    return state.where((shop) => shop.sellerId == sellerId).toList();
  }

  // Retrieves pending shops for a given seller ID.
  List<SellerShop> getPendingShopsBySeller(String sellerId) {
    return state
        .where((shop) =>
            shop.sellerId == sellerId && shop.status == ShopStatus.Pending)
        .toList();
  }

  // Retrieves approved shops for a given seller ID.
  List<SellerShop> getApprovedShopsBySeller(String sellerId) {
    return state
        .where((shop) =>
            shop.sellerId == sellerId && shop.status == ShopStatus.Approved)
        .toList();
  }
}

// Provider to access the SellerShopNotifier.
final sellerShopProvider =
    StateNotifierProvider<SellerShopNotifier, List<SellerShop>>((ref) {
  return SellerShopNotifier();
});

// Provider factory to get all shops for a specific seller.
final sellerShopsProvider =
    Provider.family<List<SellerShop>, String>((ref, sellerId) {
  final allShops = ref.watch(sellerShopProvider);
  return allShops.where((shop) => shop.sellerId == sellerId).toList();
});

// Provider factory to get approved shops for a specific seller.
final sellerApprovedShopsProvider =
    Provider.family<List<SellerShop>, String>((ref, sellerId) {
  final allShops = ref.watch(sellerShopProvider);
  return allShops
      .where((shop) =>
          shop.sellerId == sellerId && shop.status == ShopStatus.Approved)
      .toList();
});

// Provider factory to get pending shops for a specific seller.
final sellerPendingShopsProvider =
    Provider.family<List<SellerShop>, String>((ref, sellerId) {
  final allShops = ref.watch(sellerShopProvider);
  return allShops
      .where((shop) =>
          shop.sellerId == sellerId && shop.status == ShopStatus.Pending)
      .toList();
});
