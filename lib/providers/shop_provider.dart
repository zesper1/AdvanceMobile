import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shop_model.dart';

class ShopNotifier extends StateNotifier<List<Shop>> {
  ShopNotifier()
      : super([
          Shop(
            id: '1',
            name: 'Streetfoods Ondago',
            category: 'Streetfoods',
            status: ShopStatus.open,
            rating: 5,
            bestPicks: ['Kwek Kwek', 'Fishball', 'Squid Ball'],
          ),
          Shop(
            id: '2',
            name: 'Burger Haven',
            category: 'Burgers & Fries',
            status: ShopStatus.breakTime,
            rating: 4,
            bestPicks: ['Cheese Burger', 'Bacon Fries', 'Chicken Wings'],
          ),
          Shop(
            id: '3',
            name: 'Pizza Palace',
            category: 'Italian',
            status: ShopStatus.closed,
            rating: 4.5,
            bestPicks: ['Pepperoni Pizza', 'Garlic Bread', 'Pasta Carbonara'],
          ),
        ]);

  void updateStatus(String shopId, ShopStatus newStatus) {
    state = [
      for (final shop in state)
        if (shop.id == shopId) shop.copyWith(status: newStatus) else shop
    ];
  }

  void updateRating(String shopId, double newRating) {
    state = [
      for (final shop in state)
        if (shop.id == shopId) shop.copyWith(rating: newRating) else shop
    ];
  }
}

final shopProvider =
    StateNotifierProvider<ShopNotifier, List<Shop>>((ref) => ShopNotifier());
