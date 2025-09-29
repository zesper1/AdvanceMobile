// providers/shop_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shop_model.dart';
import '../services/shop_service.dart';

class ShopNotifier extends StateNotifier<AsyncValue<List<Shop>>> {
  final ShopService _shopService;

  ShopNotifier(this._shopService) : super(const AsyncValue.loading()) {
    loadShops();
  }

  Future<void> loadShops() async {
    try {
      final shops = await _shopService.fetchShops();
      state = AsyncValue.data(shops);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createShop(Map<String, dynamic> shopData) async {
    try {
      final newShop = await _shopService.createShop(shopData);
      state.whenData((shops) {
        state = AsyncValue.data([...shops, newShop]);
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void updateStatus(int shopId, ShopStatus newStatus) {
    state.whenData((shops) {
      state = AsyncValue.data([
        for (final shop in shops)
          if (shop.id == shopId) shop.copyWith(status: newStatus) else shop
      ]);
    });
  }

  void updateRating(int shopId, double newRating) {
    state.whenData((shops) {
      state = AsyncValue.data([
        for (final shop in shops)
          if (shop.id == shopId) shop.copyWith(rating: newRating) else shop
      ]);
    });
  }
}

final shopProvider =
    StateNotifierProvider<ShopNotifier, AsyncValue<List<Shop>>>(
  (ref) => ShopNotifier(ShopService()),
);
