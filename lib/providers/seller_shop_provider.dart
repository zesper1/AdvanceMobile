// providers/seller_shop_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/seller_shop_model.dart';

class SellerShopNotifier extends StateNotifier<List<SellerShop>> {
  SellerShopNotifier() : super([]);

  // Add a new shop (pending approval)
  void addShop(SellerShop shop) {
    state = [...state, shop];
  }

  // Get shops by seller ID
  List<SellerShop> getShopsBySeller(String sellerId) {
    return state.where((shop) => shop.sellerId == sellerId).toList();
  }

  // Get pending shops by seller ID
  List<SellerShop> getPendingShopsBySeller(String sellerId) {
    return state.where((shop) => shop.sellerId == sellerId && shop.status == ShopStatus.Pending).toList();
  }

  // Get approved shops by seller ID
  List<SellerShop> getApprovedShopsBySeller(String sellerId) {
    return state.where((shop) => shop.sellerId == sellerId && shop.status == ShopStatus.Approved).toList();
  }

  // Update shop status (for admin approval)
  void updateShopStatus(String shopId, ShopStatus status) {
    state = [
      for (final shop in state)
        if (shop.id == shopId)
          shop.copyWith(status: status)
        else
          shop,
    ];
  }

  // Search shops
  List<SellerShop> searchShops(String query) {
    if (query.isEmpty) return state;
    return state.where((shop) => 
      shop.name.toLowerCase().contains(query.toLowerCase()) ||
      shop.category.toLowerCase().contains(query.toLowerCase()) ||
      (shop.description?.toLowerCase().contains(query.toLowerCase()) ?? false)
    ).toList();
  }
}

// Using sellerShopProvider name consistently
final sellerShopProvider = StateNotifierProvider<SellerShopNotifier, List<SellerShop>>((ref) {
  return SellerShopNotifier();
});

// Provider for seller's shops
final sellerShopsProvider = Provider.family<List<SellerShop>, String>((ref, sellerId) {
  final allShops = ref.watch(sellerShopProvider);
  return allShops.where((shop) => shop.sellerId == sellerId).toList();
});

// Provider for seller's approved shops
final sellerApprovedShopsProvider = Provider.family<List<SellerShop>, String>((ref, sellerId) {
  final allShops = ref.watch(sellerShopProvider);
  return allShops.where((shop) => shop.sellerId == sellerId && shop.status == ShopStatus.Approved).toList();
});

// Provider for seller's pending shops
final sellerPendingShopsProvider = Provider.family<List<SellerShop>, String>((ref, sellerId) {
  final allShops = ref.watch(sellerShopProvider);
  return allShops.where((shop) => shop.sellerId == sellerId && shop.status == ShopStatus.Pending).toList();
});