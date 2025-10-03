// providers/menu_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/menu_model.dart';

class MenuNotifier extends StateNotifier<List<MenuItem>> {
  MenuNotifier() : super(_dummyMenuItems);

  void searchMenuItems(String query, String stallId) {
    if (query.isEmpty || query == 'Search menu...') {
      state = _dummyMenuItems.where((item) => item.stallId == stallId).toList();
    } else {
      final filteredItems = _dummyMenuItems.where((item) {
        return item.stallId == stallId && 
              (item.name.toLowerCase().contains(query.toLowerCase()) ||
               item.category.toLowerCase().contains(query.toLowerCase()) ||
               item.description.toLowerCase().contains(query.toLowerCase()));
      }).toList();
      state = filteredItems;
    }
  }

  void updateStock(String itemId, int newStock) {
    state = [
      for (final item in state)
        if (item.id == itemId)
          item.copyWith(stock: newStock)
        else
          item,
    ];
  }

  // NEW: Update menu item details
  void updateMenuItem(String itemId, MenuItem updatedItem) {
    state = [
      for (final item in state)
        if (item.id == itemId)
          updatedItem
        else
          item,
    ];
  }

  // NEW: Add new menu item
  void addMenuItem(MenuItem newItem) {
    state = [...state, newItem];
  }

  // NEW: Delete menu item
  void deleteMenuItem(String itemId) {
    state = state.where((item) => item.id != itemId).toList();
  }
}



final menuProvider = StateNotifierProvider<MenuNotifier, List<MenuItem>>((ref) {
  return MenuNotifier();
});

// Provider to get menu items by stall ID
final menuItemsByStallProvider = Provider.family<List<MenuItem>, String>((ref, stallId) {
  final allMenuItems = ref.watch(menuProvider);
  return allMenuItems.where((item) => item.stallId == stallId).toList();
});

// Dummy data
final List<MenuItem> _dummyMenuItems = [
  MenuItem(
    id: '1',
    name: 'Classic Burger',
    description: 'Juicy beef patty with fresh vegetables and special sauce',
    price: 12.99,
    imageUrl: 'https://placehold.co/600x400/FFF4E0/000000?text=Classic+Burger',
    stock: 15,
    category: 'Burgers',
    stallId: '1',
  ),
  MenuItem(
    id: '2',
    name: 'Cheese Burger',
    description: 'Classic burger with melted cheese and crispy bacon',
    price: 14.99,
    imageUrl: 'https://placehold.co/600x400/FFD9C0/000000?text=Cheese+Burger',
    stock: 8,
    category: 'Burgers',
    stallId: '1',
  ),
  MenuItem(
    id: '3',
    name: 'French Fries',
    description: 'Crispy golden fries with sea salt',
    price: 5.99,
    imageUrl: 'https://placehold.co/600x400/A2CDB0/000000?text=French+Fries',
    stock: 25,
    category: 'Sides',
    stallId: '1',
  ),
  MenuItem(
    id: '4',
    name: 'Chocolate Milkshake',
    description: 'Creamy chocolate milkshake with whipped cream',
    price: 6.99,
    imageUrl: 'https://placehold.co/600x400/D2E3C8/000000?text=Chocolate+Shake',
    stock: 12,
    category: 'Drinks',
    stallId: '1',
  ),
  MenuItem(
    id: '5',
    name: 'Fresh Orange Juice',
    description: 'Freshly squeezed orange juice',
    price: 4.99,
    imageUrl: 'https://placehold.co/600x400/8ECDDD/000000?text=Orange+Juice',
    stock: 20,
    category: 'Drinks',
    stallId: '2',
  ),
  MenuItem(
    id: '6',
    name: 'Fruit Smoothie',
    description: 'Mixed fruit smoothie with yogurt',
    price: 7.99,
    imageUrl: 'https://placehold.co/600x400/F6F4EB/000000?text=Fruit+Smoothie',
    stock: 10,
    category: 'Drinks',
    stallId: '2',
  ),
];