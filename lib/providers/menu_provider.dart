// providers/menu_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:collection';
import '../models/menu_model.dart';

// NOTE: You will need to update your MenuItem model to remove the `category` field.
// The `customCategories` field is now the primary source for categorization.

class MenuNotifier extends StateNotifier<List<MenuItem>> {
  MenuNotifier() : super(_dummyMenuItems);

  void toggleFavorite(String menuItemId) {
    state = [
      for (final item in state)
        if (item.id == menuItemId)
          item.copyWith(isFavorite: !item.isFavorite)
        else
          item,
    ];
  }

  // ✅ Search logic updated to remove `category`
  void searchMenuItems(String query, String stallId) {
    List<MenuItem> stallItems =
        _dummyMenuItems.where((item) => item.stallId == stallId).toList();

    if (query.isEmpty) {
      state = stallItems;
    } else {
      final lowerCaseQuery = query.toLowerCase();
      final filteredItems = stallItems.where((item) {
        return item.name.toLowerCase().contains(lowerCaseQuery) ||
            item.description.toLowerCase().contains(lowerCaseQuery);
      }).toList();
      state = filteredItems;
    }
  }

  void updateStock(String itemId, int newStock) {
    state = [
      for (final item in state)
        if (item.id == itemId) item.copyWith(stock: newStock) else item,
    ];
  }

  void updateMenuItem(String itemId, MenuItem updatedItem) {
    state = [
      for (final item in state)
        if (item.id == itemId) updatedItem else item,
    ];
  }

  void addMenuItem(MenuItem newItem) {
    state = [...state, newItem];
  }

  void deleteMenuItem(String itemId) {
    state = state.where((item) => item.id != itemId).toList();
  }
}

final menuProvider = StateNotifierProvider<MenuNotifier, List<MenuItem>>((ref) {
  return MenuNotifier();
});

final menuItemsByStallProvider =
    Provider.family<List<MenuItem>, String>((ref, stallId) {
  final allMenuItems = ref.watch(menuProvider);
  return allMenuItems.where((item) => item.stallId == stallId).toList();
});

// ✅ Grouping logic now uses the `customCategories` list
final groupedMenuItemsProvider =
    Provider.family<Map<String, List<MenuItem>>, String>((ref, stallId) {
  final menuItems = ref.watch(menuItemsByStallProvider(stallId));
  final grouped = SplayTreeMap<String, List<MenuItem>>();

  for (final item in menuItems) {
    // If an item has no categories, place it in a default group
    if (item.customCategories.isEmpty) {
      const defaultCategory = 'Miscellaneous';
      if (!grouped.containsKey(defaultCategory)) {
        grouped[defaultCategory] = [];
      }
      grouped[defaultCategory]!.add(item);
    } else {
      // Add the item to each category group it belongs to
      for (final category in item.customCategories) {
        if (!grouped.containsKey(category)) {
          grouped[category] = [];
        }
        grouped[category]!.add(item);
      }
    }
  }

  return grouped;
});

// ✅ Dummy data updated: `category` removed, `customCategories` now primary
final List<MenuItem> _dummyMenuItems = [
  MenuItem(
    id: '1',
    name: 'Classic Burger',
    description: 'Juicy beef patty with fresh vegetables and special sauce',
    price: 120.00,
    imageUrl: 'https://placehold.co/600x400/FFF4E0/000000?text=Classic+Burger',
    stock: 15,
    stallId: '1',
    customCategories: ['Burgers'], // Replaced category
    isFavorite: true,
  ),
  MenuItem(
    id: '2',
    name: 'Cheese Burger',
    description: 'Classic burger with melted cheese',
    price: 140.00,
    imageUrl: 'https://placehold.co/600x400/FFD9C0/000000?text=Cheese+Burger',
    stock: 8,
    stallId: '1',
    customCategories: ['Burgers'], // Replaced category
    isFavorite: false,
  ),
  MenuItem(
    id: '3',
    name: 'French Fries',
    description: 'Crispy golden fries with sea salt',
    price: 60.00,
    imageUrl: 'https://placehold.co/600x400/A2CDB0/000000?text=French+Fries',
    stock: 25,
    stallId: '1',
    customCategories: ['Sides'], // Replaced category
    isFavorite: false,
  ),
  MenuItem(
    id: '4',
    name: 'Chocolate Milkshake',
    description: 'Creamy chocolate milkshake with whipped cream',
    price: 80.00,
    imageUrl: 'https://placehold.co/600x400/D2E3C8/000000?text=Chocolate+Shake',
    stock: 12,
    stallId: '1',
    customCategories: ['Drinks'], // Replaced category
    isFavorite: true,
  ),
  MenuItem(
    id: '5',
    name: 'Fresh Orange Juice',
    description: 'Freshly squeezed orange juice',
    price: 70.00,
    imageUrl: 'https://placehold.co/600x400/8ECDDD/000000?text=Orange+Juice',
    stock: 20,
    stallId: '2',
    customCategories: ['Drinks'], // Replaced category
    isFavorite: false,
  ),
  MenuItem(
    id: '6',
    name: 'Fruit Smoothie',
    description: 'Mixed fruit smoothie with yogurt',
    price: 90.00,
    imageUrl: 'https://placehold.co/600x400/F6F4EB/000000?text=Fruit+Smoothie',
    stock: 10,
    stallId: '2',
    customCategories: ['Smoothies'], // Replaced category
    isFavorite: false,
  ),
  MenuItem(
    id: '7',
    name: 'Onion Rings',
    description: 'Battered and deep-fried onion rings',
    price: 65.00,
    imageUrl: 'https://placehold.co/600x400/FAD9A1/000000?text=Onion+Rings',
    stock: 18,
    stallId: '1',
    customCategories: ['Sides'], // Replaced category
    isFavorite: false,
  ),
  MenuItem(
    id: '8',
    name: 'Iced Tea',
    description: 'Refreshing classic iced tea',
    price: 40.00,
    imageUrl: 'https://placehold.co/600x400/C5DFF8/000000?text=Iced+Tea',
    stock: 30,
    stallId: '1',
    customCategories: ['Drinks'], // Replaced category
    isFavorite: false,
  ),
];