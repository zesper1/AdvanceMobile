import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panot/providers/seller_shop_provider.dart';
import 'package:panot/services/shop_services.dart';
import '../models/food_stall_model.dart';

// 1. Provider for the service dependency
// This assumes FoodStallService class exists and is defined.
final foodStallServiceProvider = Provider((ref) => ShopService());

// 2. The Asynchronous Notifier
class FoodStallNotifier extends AutoDisposeAsyncNotifier<List<FoodStall>> {
  
  // The build method replaces the constructor and handles the initial fetch
  // It runs automatically when the provider is first watched.
  @override
  Future<List<FoodStall>> build() async {
    // Call the service to fetch data from Supabase
    return ref.read(foodStallServiceProvider).fetchAllStalls();
  }

  // Toggles the favorite status of a specific food stall.
  // The stallId must be an integer, matching the model and DB id.
  Future<void> toggleFavorite(int stallId) async {
    // 1. Get the current list and the item to update
    final currentStalls = state.value;
    if (currentStalls == null) return;

    final stallIndex = currentStalls.indexWhere((stall) => stall.id == stallId);
    if (stallIndex == -1) return;
    
    final currentStall = currentStalls[stallIndex];
    final newFavoriteStatus = !currentStall.isFavorite;
    try {
        // 2. Perform the database update asynchronously
        await ref.read(foodStallServiceProvider).toggleFavoriteStatus(
            stallId, 
            newFavoriteStatus,
        );

        // 3. Update local state immediately for fast UI feedback
        final updatedStall = currentStall.copyWith(isFavorite: newFavoriteStatus);
        
        // Create a new list to trigger state change
        final newState = List<FoodStall>.from(currentStalls);
        newState[stallIndex] = updatedStall;

        state = AsyncValue.data(newState);
        
    } catch (e) {
        // Handle network/DB error (e.g., show an error snackbar in UI)
        // You might re-throw the error or log it.
        throw Exception('Failed to update favorite status: $e');
    }
  }

  // Search stalls by name or category (filters the currently loaded data)
  void searchStalls(String query) {
    state.whenData((stalls) {
      if (query.isEmpty || query == 'Looking for something?') {
        // Refetching is the cleanest way to reset the filtered state in an AsyncNotifier.
        ref.invalidateSelf();
      } else {
        final lowerCaseQuery = query.toLowerCase();
        final filteredStalls = stalls.where((stall) {
          return stall.name.toLowerCase().contains(lowerCaseQuery) ||
              stall.category.toLowerCase().contains(lowerCaseQuery);
        }).toList();
        
        state = AsyncValue.data(filteredStalls);
      }
    });
  }
}

// Provider to access the FoodStallNotifier (now an AutoDisposeAsyncNotifier)
final foodStallProvider =
    AutoDisposeAsyncNotifierProvider<FoodStallNotifier, List<FoodStall>>(() {
  return FoodStallNotifier();
});

// --- Derived Providers for UI Sections (Must handle AsyncValue<List<T>>) ---

// Provider to get only the list of favorite shops.
final favoriteShopsProvider = FutureProvider<List<FoodStall>>((ref) async {
  // 1. Watch the stream's future. This creates a dependency.
  // When the stream emits a new list of IDs, this provider will be re-executed.
  final favoriteIds = await ref.watch(favoriteShopIdsStreamProvider.future);

  // 2. Optimization: If the user has no favorites, return an empty list immediately
  // without making a database call.
  if (favoriteIds.isEmpty) {
    return [];
  }

  // 3. Get the shop service to perform the database query.
  final shopService = ref.watch(shopServiceProvider);

  // 4. Fetch only the stalls that match the live list of favorite IDs.
  // This requires a new method in your ShopService (see Step 2).
  return shopService.fetchAllStallsWithFavoriteStatus();
});

// Provider to get popular shops (e.g., rating > 4.0).
final popularShopsProvider = Provider<AsyncValue<List<FoodStall>>>((ref) {
  return ref.watch(foodStallProvider).whenData(
    (stalls) => stalls.where((stall) => stall.rating > 4.0).toList(),
  );
});

// Provider to get currently open shops.
final currentlyOpenShopsProvider = Provider<AsyncValue<List<FoodStall>>>((ref) {
  return ref.watch(foodStallProvider).whenData(
    (stalls) => stalls.where((stall) => stall.availability == AvailabilityStatus.Open).toList(),
  );
});

// Provider factory to filter stalls by a specific category.
final stallsByCategoryProvider =
    Provider.family<AsyncValue<List<FoodStall>>, String>((ref, category) {
  return ref.watch(foodStallProvider).whenData(
    (stalls) => stalls.where((stall) => stall.category == category).toList(),
  );
});

final favoriteShopIdsStreamProvider = StreamProvider<List<int>>((ref) {
  // Depends on the ShopService to get the stream method.
  final shopService = ref.watch(foodStallServiceProvider);
  return shopService.getFavoriteShopIdsStream();
});


// The List<FoodStall> _dummyData is removed.