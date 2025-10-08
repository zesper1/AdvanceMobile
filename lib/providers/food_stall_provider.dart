import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/food_stall_model.dart';

// Manages the state of the food stalls list.
class FoodStallNotifier extends StateNotifier<List<FoodStall>> {
  FoodStallNotifier() : super(_dummyData);

  void toggleFavorite(String stallId) {
    state = [
      for (final stall in state)
        if (stall.id == stallId)
          FoodStall(
            id: stall.id,
            name: stall.name,
            imageUrl: stall.imageUrl,
            availability: stall.availability,
            openingTime: stall.openingTime,
            closingTime: stall.closingTime,
            category: stall.category,
            rating: stall.rating,
            description: stall.description,
            location: stall.location,
            isOpen: stall.isOpen,
            isFavorite: !stall.isFavorite,
            customCategories:
                stall.customCategories, // Preserve custom categories
          )
        else
          stall,
    ];
  }

  // Search stalls by name or category
  void searchStalls(String query) {
    if (query.isEmpty || query == 'Looking for something?') {
      state = _dummyData; // Reset to original data when search is cleared
    } else {
      final filteredStalls = _dummyData.where((stall) {
        return stall.name.toLowerCase().contains(query.toLowerCase()) ||
            stall.category.toLowerCase().contains(query.toLowerCase());
      }).toList();

      state = filteredStalls;
    }
  }
}

// Provider to access the FoodStallNotifier.
final foodStallProvider =
    StateNotifierProvider<FoodStallNotifier, List<FoodStall>>((ref) {
  return FoodStallNotifier();
});

// --- Derived Providers for UI Sections ---

// Provider to get only the list of favorite shops.
final favoriteShopsProvider = Provider<List<FoodStall>>((ref) {
  final allStalls = ref.watch(foodStallProvider);
  return allStalls.where((stall) => stall.isFavorite).toList();
});

// Provider to get popular shops (e.g., rating > 4.0).
final popularShopsProvider = Provider<List<FoodStall>>((ref) {
  final allStalls = ref.watch(foodStallProvider);
  return allStalls.where((stall) => stall.rating > 4.0).toList();
});

// Provider to get currently open shops.
final currentlyOpenShopsProvider = Provider<List<FoodStall>>((ref) {
  final allStalls = ref.watch(foodStallProvider);
  return allStalls
      .where((stall) => stall.availability == AvailabilityStatus.Open)
      .toList();
});

// Provider factory to filter stalls by a specific category.
final stallsByCategoryProvider =
    Provider.family<List<FoodStall>, String>((ref, category) {
  final allStalls = ref.watch(foodStallProvider);
  return allStalls.where((stall) => stall.category == category).toList();
});

// Dummy data for initial UI display.
final List<FoodStall> _dummyData = [
  FoodStall(
    id: '1',
    name: 'Crispy Corner',
    imageUrl: 'https://placehold.co/600x400/FFF4E0/000000?text=Crispy+Corner',
    availability: AvailabilityStatus.Open,
    openingTime: '08:00 AM',
    closingTime: '10:00 PM',
    category: 'Snack',
    rating: 4.5,
    customCategories: [
      'Fried Food',
      'Quick Snacks',
      'Student Favorites'
    ], // Added custom categories
  ),
  FoodStall(
    id: '2',
    name: 'The Juice Bar',
    imageUrl: 'https://placehold.co/600x400/D2E3C8/000000?text=Juice+Bar',
    availability: AvailabilityStatus.Open,
    openingTime: '09:00 AM',
    closingTime: '08:00 PM',
    category: 'Drinks',
    rating: 4.8,
    isFavorite: true,
    customCategories: [
      'Healthy Options',
      'Fresh Juice',
      'Smoothies'
    ], // Added custom categories
  ),
  FoodStall(
    id: '3',
    name: 'Mama\'s Kitchen',
    imageUrl: 'https://placehold.co/600x400/FFD9C0/000000?text=Mama\'s+Kitchen',
    availability: AvailabilityStatus.Closed,
    openingTime: '10:00 AM',
    closingTime: '09:00 PM',
    category: 'Meal',
    rating: 4.2,
    customCategories: [
      'Home Style',
      'Comfort Food',
      'Budget Meals'
    ], // Added custom categories
  ),
  FoodStall(
    id: '4',
    name: 'Quick Bites',
    imageUrl: 'https://placehold.co/600x400/A2CDB0/000000?text=Quick+Bites',
    availability: AvailabilityStatus.OnBreak,
    openingTime: '11:00 AM',
    closingTime: '11:00 PM',
    category: 'Snack',
    rating: 3.8,
    customCategories: [
      'Fast Food',
      'On-the-Go',
      'Late Night'
    ], // Added custom categories
  ),
  FoodStall(
    id: '5',
    name: 'Ocean Fresh',
    imageUrl: 'https://placehold.co/600x400/8ECDDD/000000?text=Ocean+Fresh',
    availability: AvailabilityStatus.Open,
    openingTime: '10:00 AM',
    closingTime: '09:00 PM',
    category: 'Meal',
    rating: 4.9,
    isFavorite: true,
    customCategories: [
      'Seafood',
      'Healthy',
      'Premium'
    ], // Added custom categories
  ),
  FoodStall(
    id: '6',
    name: 'Boba Bliss',
    imageUrl: 'https://placehold.co/600x400/F6F4EB/000000?text=Boba+Bliss',
    availability: AvailabilityStatus.Closed,
    openingTime: '12:00 PM',
    closingTime: '10:00 PM',
    category: 'Drinks',
    rating: 4.1,
    customCategories: [
      'Bubble Tea',
      'Dessert Drinks',
      'Asian Beverages'
    ], // Added custom categories
  ),
];
